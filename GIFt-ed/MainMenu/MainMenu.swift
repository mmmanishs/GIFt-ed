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
var cachedSystemInfo: SystemInfo?

class MainMenu: NSObject {
    private let videoAndGifManager: VideoAndGifManager
    private let mainEventHandler: MainEventHandler?
    
    override init() {
        videoAndGifManager = VideoAndGifManager()
        mainEventHandler = MainEventHandler()
        videoAndGifManager.eventNotifierHandler = { event in
            MainMenuViewModel.shared.update(for: event)
        }
        super.init()
    }
    
    func start(updateHandler: ([NSMenuItem]) -> ()) {
        MainMenuViewModel.initailizeSingleton()
        updateViewMenuViewModel()
        updateHandler(MainMenuViewModel.shared.menuItems)
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
        let menuDescriptor = MenuDescriptor.load()
        print(menuDescriptor.description)
        MainMenuViewModel.shared.menuItems = NSMenuItem.menuItems(from: menuDescriptor)
        recursivelySetTarget(menuItems: MainMenuViewModel.shared.menuItems)
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
        case .exit:
            objc_terminate()
        default:
            if identifier.rawValue.contains("simulators.device.") {
                let demarcatedIdentifier = identifier.rawValue.replacingOccurrences(of: "simulators.device.", with: "")
                let udid = demarcatedIdentifier.components(separatedBy: "|")[0]
                let actionIdentifier = demarcatedIdentifier.components(separatedBy: "|")[1]
                DeviceWorker(udid: udid, action: DeviceWorker.Action(rawValue: actionIdentifier) ?? .unknown).execute()
                if DeviceWorker.Action(rawValue: actionIdentifier) == .boot {
                    MainMenu.saveToRecentlyAccessedDevice(udid: udid)
                }
            }
        }
    }

    static func saveToRecentlyAccessedDevice(udid: String) {
        var menuDescriptor = MenuDescriptor.load()
        // Get all the matching items
        menuDescriptor.printAllKeys()
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
        menuDescriptor.printAllKeys()

    }
}
extension MainMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        MainPopover.shared.dismissPopover()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])
        cachedSystemInfo?.bootedDevices.map{$0.udid}.forEach(MainMenu.saveToRecentlyAccessedDevice(udid:))
        updateViewMenuViewModel()
        menu.items = MainMenuViewModel.shared.menuItems
    }
}
