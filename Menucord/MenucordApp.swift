//
//  MenucordApp.swift
//  Menucord
//
//  Created by Tejas Annapareddy on 10/5/25.
//

import SwiftUI
import AppKit
//import SwiftData

@main
struct MenucordApp: App {
    @StateObject private var monitor = DiscordMonitor()
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: monitor)
        } label: {
            if monitor.isRunning {
                Label("Discord", systemImage: "message.badge")
                Text("\(monitor.notificationCount)")
            } else {
                Label("Discord Not Running", systemImage: "exclamationmark.message")
            }
        }
    }
}
