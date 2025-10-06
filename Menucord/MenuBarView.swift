//
//  MenuBarView.swift
//  Menucord
//
//  Created by Tejas Annapareddy on 10/5/25.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var monitor: DiscordMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button("Open Discord") {
                monitor.openDiscord()
            }
            .keyboardShortcut("d")
            
            Button("Refresh") {
                monitor.checkNotifications()
            }
            .keyboardShortcut("r")
            
            Divider()
            
            Button("About") {
                showAbout()
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(4)
    }
    
    func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Discord Notification Monitor"
        alert.informativeText = "Displays Discord notification count in menu bar using Accessibility API"
        alert.alertStyle = .informational
        alert.runModal()
    }
}
