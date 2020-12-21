//
//  AppDelegate.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 7/7/19.
//  Copyright © 2019 Manish Singh. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
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

        /// Synchronous refresh
        AppInMemoryCaches.refreshCachedSystemInfo()

        /// Asynchronous recurring refresh
        AppInMemoryCaches.refreshSimulatorCacheData(every: 7)

        /// Start displaying app icon
        StatusBarDisplayManager.shared.displayAppIcon()

        AppDelegate.statusItem.menu = NSMenu()
        AppDelegate.statusItem.menu?.delegate = mainMenuManager
        if FeatureFlag.isMainMenuEnabled {
            mainMenuManager.start { menuItems in
                AppDelegate.statusItem.menu?.items = menuItems
            }
        }
    }
}
