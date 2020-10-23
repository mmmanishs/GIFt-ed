//
//  AppDelegate.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 7/7/19.
//  Copyright © 2019 Manish Singh. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainEventHandler: MainEventHandler?
    var videoAndGifManager = VideoAndGifManager()
    var mainMenu = MainMenu()
    static var statusItem: NSStatusItem!

    private var statusDisplayButton: NSStatusBarButton {
        return AppDelegate.statusItem?.button ?? NSStatusBarButton()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /// Startup code
        AppDelegate.statusItem = NSStatusBar.system.statusItem(withLength: -1)
        StatusBarDisplayManager.initailizeSingleton(statusDisplayButton: statusDisplayButton)
        UserPreferences.retriveFromDisk().outputFolderPath.tryToCreateFolderIfItDoesNotAlreadyExist()

        /// Start displaying app icon
        StatusBarDisplayManager.shared.displayAppIcon()


        mainEventHandler = MainEventHandler()

        if FeatureFlag.isMainMenuEnabled {
            mainMenu.start { menu in
                AppDelegate.statusItem.menu = menu
            }
        }
        if let button = AppDelegate.statusItem.button {
            button.action = #selector(self.userAction(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp, .mouseEntered, .directTouch, .mouseExited, .pressure, .beginGesture])
        }
    }

    @objc func userAction(sender: NSStatusItem) {
        let event = NSApp.currentEvent!
        mainEventHandler?.respondTo(event: event.type)
    }
}


/*
 1. output folder does not update
 2. the icons does not change on simulator not found
 3.
 */
