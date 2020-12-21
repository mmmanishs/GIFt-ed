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
    private var mainMenuViewModel: MainMenuViewModel
    private let mainMenuProvider: MainMenuProvider
    override init() {
        videoAndGifManager = VideoAndGifManager()
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
            showSettings()
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
                        let viewModel = ConfirmOperationViewController.ViewModel.deleteDevice(device: device)
                        let confirmVC = ConfirmOperationViewController.viewController(viewModel: viewModel) {_ in
                            DeviceWorker(udid: device.udid, action: .delete).execute()
                        }
                        MainPopover.shared.showInPopover(viewController: confirmVC, behavior: .transient)
                    }
                case .openURL:
                    if let device = AppInMemoryCaches.cachedSystemInfo?.getDevice(for: udid) {
                        OpenURLViewController.display(for: device)
                    }
                default:
                    MainMenuManager.saveToRecentlyAccessedDevice(udid: udid)
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        DeviceWorker(udid: udid, action: DeviceWorker.Action(rawValue: actionIdentifier) ?? .unknown).execute() {_ in
                            AppInMemoryCaches.refreshCachedSystemInfo()
                        }
                    }
                }
//                if DeviceWorker.Action(rawValue: actionIdentifier) == .boot {
//                    MainMenuManager.saveToRecentlyAccessedDevice(udid: udid)
//                }
            } else if identifier.rawValue.contains("installed-apps"),
                      let deviceAppIdentiferParser = DeviceAppIdentiferParser(identifier.rawValue) {
//                MainMenuManager.saveToRecentlyAccessedDevice(udid: deviceAppIdentiferParser.udid)
                DispatchQueue.global().async {
                    DeviceAppWorker(deviceAppIdentiferParser).execute()
                }
            }
        }
    }

    func showSettings() {
        MainPopover.shared.showInPopover(viewController: GeneralSettingsViewController.viewController { userAction in
            MainPopover.shared.dismissPopover()
            switch userAction {
            case .terminateAppTapped:
                objc_terminate()
            case .outputFolderPathUpdated:
                NotificationCenter.default.post(name: .updateMainMenu, object: nil)
            default: break
            }
        })
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
            AppInMemoryCaches.refreshCachedSystemInfo()
        }
        AppInMemoryCaches.cachedSystemInfo?.bootedDevices.map{$0.udid}.forEach(MainMenuManager.saveToRecentlyAccessedDevice(udid:))
        updateViewMenuViewModel()
        menu.items = mainMenuViewModel.menuItems
    }
}
