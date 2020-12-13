//
//  MainMenu.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/24/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

extension NSNotification.Name {
    static let updateMainMenu: NSNotification.Name =  NSNotification.Name(rawValue: "updateMainMenu")
}

class MainMenuManager: NSObject {
    private let videoAndGifManager: VideoAndGifManager
    private let mainEventHandler: MainEventHandler?
    private var mainMenuViewModel: MainMenuViewModel
    private let mainMenuProvider: MainMenuProvider
    override init() {
        videoAndGifManager = VideoAndGifManager()
        mainEventHandler = MainEventHandler()
        mainMenuViewModel = MainMenuViewModel()
        mainMenuProvider = MainMenuProvider()
        super.init()
    }
    
    func start(updateHandler: ([NSMenuItem]) -> ()) {
        updateViewMenuViewModel()
        updateHandler(mainMenuViewModel.menuItems)
        videoAndGifManager.eventNotifierHandler = { [self] event in
            self.mainMenuViewModel.update(for: event)
        }
    }

    func recursivelySetTarget(menuItems :[NSMenuItem]) {
        menuItems.forEach { item in
            item.target = self
            if item.hasSubmenu,
               let subMenuItems = item.submenu?.items {
                recursivelySetTarget(menuItems: subMenuItems)
            }
        }
    }

    func updateViewMenuViewModel() {
        mainMenuViewModel.menuItems = mainMenuProvider.fetchMenuItems()
        recursivelySetTarget(menuItems: mainMenuViewModel.menuItems)
    }

    @objc func functionalityRouter(_ sender: Any?) {
        let menuItem = sender as! NSMenuItem
        guard let identifier = menuItem.identifier else { return }
        switch identifier {
        case .record:
            videoAndGifManager.respondToClickEvent()
        case .stopRecording:
            videoAndGifManager.respondToClickEvent()
        case .settings:
            mainEventHandler?.showPopover(sender: nil)
        case .openOutputFolder:
            UserPreferences.retriveFromDisk().outputFolderPath.openFolder()
        case .screenshot:
            break
        case .giffromvidoes:
            MainPopover.shared.showInPopover(viewController: StandAloneVideoAndGifConverter.viewController, behavior: .semitransient)
        case .credits:
            MainPopover.shared.showInPopover(viewController: CreditsViewController.viewController, behavior: .semitransient)
        case .exit:
            objc_terminate()
        default:
            if identifier.rawValue.contains("simulators.device.") {
                let demarcatedIdentifier = identifier.rawValue.replacingOccurrences(of: "simulators.device.", with: "")
                let udid = demarcatedIdentifier.components(separatedBy: "|")[0]
                let actionIdentifier = demarcatedIdentifier.components(separatedBy: "|")[1]
                let action  = DeviceWorker.Action(rawValue: actionIdentifier)
                switch action {
                case .delete:
                    if let device = AppInMemoryCaches.cachedSystemInfo?.getDevice(for: udid) {
                        MainPopover.shared.showInPopover(viewController: ConfirmDeletionOfDeviceViewController.viewController(for: device), behavior: .transient)
                    }
                case .openURL:
                    if let device = AppInMemoryCaches.cachedSystemInfo?.getDevice(for: udid) {
                        OpenURLViewController.display(for: device)
                    }
                default:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        DeviceWorker(udid: udid, action: DeviceWorker.Action(rawValue: actionIdentifier) ?? .unknown).execute() {_ in
                            AppInMemoryCaches.cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])
                        }
                    }
                }
                if DeviceWorker.Action(rawValue: actionIdentifier) == .boot {
                    MainMenuManager.saveToRecentlyAccessedDevice(udid: udid)
                }
            } else if identifier.rawValue.contains("installed-apps"),
                      let deviceAppIdentiferParser = DeviceAppIdentiferParser(identifier.rawValue) {
                DeviceAppWorker(deviceAppIdentiferParser).execute()
            }
        }
    }

    static func saveToRecentlyAccessedDevice(udid: String) {
        var menuDescriptor = MenuDescriptor.load()
        // Get all the matching items
        var items = MenuDescriptor.load().items

        let newItem = MenuDescriptor.Item(element: MenuDescriptor.Item.Element(key: "cache-recently-accessed-devices",
                                                                               params: udid),
                                          isEnabled: true)

        if items.contains(where: {$0 == newItem}) {
            return
        }
        if let lastIndex = items.lastIndex(where: { $0.element.approvedKey == .cacheFrequentlyAccessedDevices }) {
            items.remove(at: lastIndex)
        }

        if let firstIndex = items.firstIndex(where: { $0.element.approvedKey == .cacheFrequentlyAccessedDevices }) {
            items.insert(newItem, at: firstIndex)
        }

        menuDescriptor.items = items
        menuDescriptor.persistToDisk()
    }
}
extension MainMenuManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        MainPopover.shared.dismissPopover()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        DispatchQueue.global().async {
            AppInMemoryCaches.cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])
        }
        AppInMemoryCaches.cachedSystemInfo?.bootedDevices.map{$0.udid}.forEach(MainMenuManager.saveToRecentlyAccessedDevice(udid:))
        updateViewMenuViewModel()
        menu.items = mainMenuViewModel.menuItems
    }
}
