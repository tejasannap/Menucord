# Menucord

A lightweight macOS menu bar app that displays your Discord notification count directly in the menu bar.

Once running, the app will:
- Display 💬 0 when you have no notifications
- Display 💬 5 when you have 5 unread notifications
- Update automatically every 2 seconds (interval adjustment TBD)


## How It Works

This app uses macOS's private Launch Services API to read Discord's dock badge label. This is the same badge count you see on Discord's dock icon. 

The app queries Launch Services every 2 seconds to check for badge updates, making it lightweight and efficient.
