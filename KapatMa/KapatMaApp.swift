//
//  KapatMaApp.swift
//  KapatMa
//
//  Created by DavutARI on 14.02.2026.
//

import SwiftUI
import CoreData

@main
struct KapatMaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
