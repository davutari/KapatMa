#include "DDCHelper.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/i2c/IOI2CInterface.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <stdlib.h>
#include <string.h>

// MARK: - IOKit Service Helpers

/// Find the IODisplayConnect service matching a CGDirectDisplayID
static io_service_t findDisplayService(CGDirectDisplayID displayID) {
    uint32_t vendor = CGDisplayVendorNumber(displayID);
    uint32_t model  = CGDisplayModelNumber(displayID);
    uint32_t serial = CGDisplaySerialNumber(displayID);

    io_iterator_t iter;
    if (IOServiceGetMatchingServices(kIOMainPortDefault,
                                     IOServiceMatching("IODisplayConnect"),
                                     &iter) != kIOReturnSuccess) {
        return IO_OBJECT_NULL;
    }

    io_service_t service;
    while ((service = IOIteratorNext(iter)) != IO_OBJECT_NULL) {
        CFDictionaryRef info = IODisplayCreateInfoDictionary(service, kIODisplayOnlyPreferredName);
        if (info) {
            uint32_t v = 0, m = 0, s = 0;
            CFNumberRef ref;

            ref = CFDictionaryGetValue(info, CFSTR(kDisplayVendorID));
            if (ref) CFNumberGetValue(ref, kCFNumberSInt32Type, &v);

            ref = CFDictionaryGetValue(info, CFSTR(kDisplayProductID));
            if (ref) CFNumberGetValue(ref, kCFNumberSInt32Type, &m);

            ref = CFDictionaryGetValue(info, CFSTR(kDisplaySerialNumber));
            if (ref) CFNumberGetValue(ref, kCFNumberSInt32Type, &s);

            CFRelease(info);

            if (v == vendor && m == model && s == serial) {
                IOObjectRelease(iter);
                return service; // caller must IOObjectRelease
            }
        }
        IOObjectRelease(service);
    }

    IOObjectRelease(iter);
    return IO_OBJECT_NULL;
}

/// Walk up from IODisplayConnect to its parent framebuffer for I2C access
static io_service_t findFramebuffer(CGDirectDisplayID displayID) {
    io_service_t displayService = findDisplayService(displayID);
    if (displayService == IO_OBJECT_NULL) return IO_OBJECT_NULL;

    io_service_t parent = IO_OBJECT_NULL;
    kern_return_t kr = IORegistryEntryGetParentEntry(displayService, kIOServicePlane, &parent);
    IOObjectRelease(displayService);

    return (kr == kIOReturnSuccess) ? parent : IO_OBJECT_NULL;
}

// MARK: - DDC/CI Protocol

bool DDCReadBrightness(CGDirectDisplayID displayID,
                       uint16_t * _Nonnull currentValue,
                       uint16_t * _Nonnull maxValue) {
    io_service_t fb = findFramebuffer(displayID);
    if (fb == IO_OBJECT_NULL) return false;

    IOItemCount busCount = 0;
    if (IOFBGetI2CInterfaceCount(fb, &busCount) != kIOReturnSuccess || busCount == 0) {
        IOObjectRelease(fb);
        return false;
    }

    for (IOItemCount bus = 0; bus < busCount; bus++) {
        io_service_t interface = IO_OBJECT_NULL;
        if (IOFBCopyI2CInterfaceForBus(fb, (IOOptionBits)bus, &interface) != kIOReturnSuccess)
            continue;

        IOI2CConnectRef connect = NULL;
        if (IOI2CInterfaceOpen(interface, kNilOptions, &connect) != kIOReturnSuccess) {
            IOObjectRelease(interface);
            continue;
        }

        // DDC/CI Get VCP Feature — VCP code 0x10 (Brightness)
        uint8_t sendData[5];
        sendData[0] = 0x51;  // source address
        sendData[1] = 0x82;  // length: 0x80 | 2
        sendData[2] = 0x01;  // Get VCP Feature opcode
        sendData[3] = 0x10;  // VCP code: luminance
        sendData[4] = 0x6E ^ 0x51 ^ 0x82 ^ 0x01 ^ 0x10; // checksum

        uint8_t replyData[12];
        memset(replyData, 0, sizeof(replyData));

        IOI2CRequest request;
        memset(&request, 0, sizeof(request));
        request.sendAddress          = 0x6E;
        request.sendTransactionType  = kIOI2CSimpleTransactionType;
        request.sendBuffer           = (vm_address_t)sendData;
        request.sendBytes            = sizeof(sendData);
        request.minReplyDelay        = 30000; // 30 ms
        request.replyAddress         = 0x6F;
        request.replyTransactionType = kIOI2CSimpleTransactionType;
        request.replyBuffer          = (vm_address_t)replyData;
        request.replyBytes           = sizeof(replyData);

        IOReturn result = IOI2CSendRequest(connect, kNilOptions, &request);
        IOI2CInterfaceClose(connect, kNilOptions);
        IOObjectRelease(interface);

        if (result == kIOReturnSuccess && request.result == kIOReturnSuccess) {
            // VCP Reply: [src, len, 0x02, result, vcp, type, maxH, maxL, curH, curL, chk]
            if (replyData[2] == 0x02 && replyData[3] == 0x00) {
                *maxValue     = ((uint16_t)replyData[6] << 8) | replyData[7];
                *currentValue = ((uint16_t)replyData[8] << 8) | replyData[9];
                if (*maxValue == 0) *maxValue = 100;
                IOObjectRelease(fb);
                return true;
            }
        }
    }

    IOObjectRelease(fb);
    return false;
}

bool DDCWriteBrightness(CGDirectDisplayID displayID, uint16_t value) {
    io_service_t fb = findFramebuffer(displayID);
    if (fb == IO_OBJECT_NULL) return false;

    IOItemCount busCount = 0;
    if (IOFBGetI2CInterfaceCount(fb, &busCount) != kIOReturnSuccess || busCount == 0) {
        IOObjectRelease(fb);
        return false;
    }

    for (IOItemCount bus = 0; bus < busCount; bus++) {
        io_service_t interface = IO_OBJECT_NULL;
        if (IOFBCopyI2CInterfaceForBus(fb, (IOOptionBits)bus, &interface) != kIOReturnSuccess)
            continue;

        IOI2CConnectRef connect = NULL;
        if (IOI2CInterfaceOpen(interface, kNilOptions, &connect) != kIOReturnSuccess) {
            IOObjectRelease(interface);
            continue;
        }

        // DDC/CI Set VCP Feature — VCP code 0x10 (Brightness)
        uint8_t hi = (value >> 8) & 0xFF;
        uint8_t lo = value & 0xFF;

        uint8_t sendData[7];
        sendData[0] = 0x51;  // source address
        sendData[1] = 0x84;  // length: 0x80 | 4
        sendData[2] = 0x03;  // Set VCP Feature opcode
        sendData[3] = 0x10;  // VCP code: luminance
        sendData[4] = hi;    // value high byte
        sendData[5] = lo;    // value low byte
        sendData[6] = 0x6E ^ 0x51 ^ 0x84 ^ 0x03 ^ 0x10 ^ hi ^ lo; // checksum

        IOI2CRequest request;
        memset(&request, 0, sizeof(request));
        request.sendAddress          = 0x6E;
        request.sendTransactionType  = kIOI2CSimpleTransactionType;
        request.sendBuffer           = (vm_address_t)sendData;
        request.sendBytes            = sizeof(sendData);
        request.replyTransactionType = kIOI2CNoTransactionType;

        IOReturn result = IOI2CSendRequest(connect, kNilOptions, &request);
        IOI2CInterfaceClose(connect, kNilOptions);
        IOObjectRelease(interface);

        if (result == kIOReturnSuccess) {
            IOObjectRelease(fb);
            return true;
        }
    }

    IOObjectRelease(fb);
    return false;
}

char * _Nullable DDCGetDisplayName(CGDirectDisplayID displayID) {
    io_service_t service = findDisplayService(displayID);
    if (service == IO_OBJECT_NULL) return NULL;

    CFDictionaryRef info = IODisplayCreateInfoDictionary(service, kIODisplayOnlyPreferredName);
    IOObjectRelease(service);
    if (!info) return NULL;

    CFDictionaryRef names = CFDictionaryGetValue(info, CFSTR(kDisplayProductName));
    if (!names || CFDictionaryGetCount(names) == 0) {
        CFRelease(info);
        return NULL;
    }

    const void *values[1];
    CFDictionaryGetKeysAndValues(names, NULL, values);
    CFStringRef nameStr = (CFStringRef)values[0];

    CFIndex length  = CFStringGetLength(nameStr);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = (char *)malloc((size_t)maxSize);

    if (buffer && CFStringGetCString(nameStr, buffer, maxSize, kCFStringEncodingUTF8)) {
        CFRelease(info);
        return buffer; // caller must free()
    }

    free(buffer);
    CFRelease(info);
    return NULL;
}
