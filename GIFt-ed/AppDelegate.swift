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
    var mainMenuManager = MainMenuManager()
    static var statusItem: NSStatusItem!

    private var statusDisplayButton: NSStatusBarButton {
        return AppDelegate.statusItem?.button ?? NSStatusBarButton()
    }

    func checkAndPerformAppUpdateActions() {
        let newAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if let oldAppversion = UserDefaults.standard.object(forKey: "appversion") as? String {
            if newAppVersion != oldAppversion {
                MenuDescriptor.load(overridePersistedState: true).persistToDisk()
            }
        } else {
            MenuDescriptor.load(overridePersistedState: true).persistToDisk()
        }
        UserDefaults.standard.set(newAppVersion, forKey: "appversion")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkAndPerformAppUpdateActions()
        if ProcessInfo().environment.keys.contains("shouldOverideLocalMenuCache") {
            let shouldOverideLocalMenuCache = ProcessInfo().environment["shouldOverideLocalMenuCache"] == "true"
            MenuDescriptor.load(overridePersistedState: shouldOverideLocalMenuCache).persistToDisk()
        } else {
            MenuDescriptor.load(overridePersistedState: false).persistToDisk()
        }

        /// Startup code
        AppDelegate.statusItem = NSStatusBar.system.statusItem(withLength: -1)
        StatusBarDisplayManager.initailizeSingleton(statusDisplayButton: statusDisplayButton)
        UserPreferences.retriveFromDisk().outputFolderPath.tryToCreateFolderIfItDoesNotAlreadyExist()
        cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])

        /// Start displaying app icon
        StatusBarDisplayManager.shared.displayAppIcon()


        mainEventHandler = MainEventHandler()
        AppDelegate.statusItem.menu = NSMenu()
        AppDelegate.statusItem.menu?.delegate = mainMenuManager
        if FeatureFlag.isMainMenuEnabled {
            mainMenuManager.start { menuItems in
                AppDelegate.statusItem.menu?.items = menuItems
            }
        }
        if let button = AppDelegate.statusItem.button {
            button.action = #selector(self.userAction(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp, .mouseEntered, .directTouch, .mouseExited, .pressure, .beginGesture])
        }
        DispatchQueue.global().async {
            print("cumulativeTimeForScanningAppSandbox: \(AppMenuProvider.cumulativeTimeForScanningAppSandbox)")
        }
    }

    @objc func userAction(sender: NSStatusItem) {
        let event = NSApp.currentEvent!
        mainEventHandler?.respondTo(event: event.type)
    }
}
