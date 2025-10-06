# Menucord

A lightweight macOS menu bar app that displays your Discord notification count directly in the menu bar.

![alt text](https://github.com/tejasannap/Menucord/blob/main/images/menu.png? "Menucord")

Once running, the app will:
- Display 💬 0 when you have no notifications
- Display 💬 2 when you have 2 unread notifications
- Update automatically every 2 seconds (interval adjustment TBD)
- Display an Error if Discord is not detected

![alt text](https://github.com/tejasannap/Menucord/blob/main/images/discordError.png? "Menucord Error")


## How It Works

This app uses macOS's private Launch Services API to read Discord's dock badge label. This is the same badge count you see on Discord's dock icon. 

The app queries Launch Services every 2 seconds to check for badge updates, making it lightweight and efficient.


## To Do
- Interval adjustment menu
- Custom Icon?
- Ensure CPU/RAM/Power usage is not insane 
