#ifndef DDCHelper_h
#define DDCHelper_h

#include <CoreGraphics/CoreGraphics.h>
#include <stdbool.h>
#include <stdint.h>

/// Read current and maximum brightness values via DDC/CI (VCP code 0x10)
/// @param displayID The CGDirectDisplayID of the external monitor
/// @param currentValue Output: current brightness value
/// @param maxValue Output: maximum brightness value
/// @return true if the DDC read was successful
bool DDCReadBrightness(CGDirectDisplayID displayID,
                       uint16_t * _Nonnull currentValue,
                       uint16_t * _Nonnull maxValue);

/// Set brightness via DDC/CI (VCP code 0x10)
/// @param displayID The CGDirectDisplayID of the external monitor
/// @param value The raw brightness value to set (0 to maxValue)
/// @return true if the DDC write was successful
bool DDCWriteBrightness(CGDirectDisplayID displayID, uint16_t value);

/// Get the product name of a display via IOKit registry
/// @param displayID The CGDirectDisplayID
/// @return Display name string (caller must free), or NULL on failure
char * _Nullable DDCGetDisplayName(CGDirectDisplayID displayID);

#endif
