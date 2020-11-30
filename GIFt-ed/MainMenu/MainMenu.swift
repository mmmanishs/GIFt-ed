//
//  MainMenu.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/24/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

protocol MainMenuUpdation: class {
    func updateMenu()
}

extension NSNotification.Name {
    static let updateMainMenu: NSNotification.Name =  NSNotification.Name(rawValue: "updateMainMenu")
}
class MainMenu: NSObject, MainMenuUpdation {
    let menuFunctionalityInvoker = MenuFunctionalityInvoker()
    var updateHandler: ((NSMenu) -> ())?

    func start(updateHandler: @escaping (NSMenu) -> ()) {
        self.updateHandler = updateHandler
        menuFunctionalityInvoker.delegate = self
        MainMenuViewModel.initailizeSingleton()
        updateHandler(getMenu())
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: .updateMainMenu, object: nil)
    }

    private func getMenu() -> NSMenu {
        let menu = NSMenu()
        recursivelySetTarget(menuItems: MainMenuViewModel.shared.menuItems)
        menu.items = MainMenuViewModel.shared.menuItems
        menu.delegate = self
        return menu
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

    @objc func updateMenu() {
        updateHandler?(getMenu())
    }

    @objc func functionalityRouter(_ sender: Any?) {
        let menuItem = sender as! NSMenuItem
        guard let identifier = menuItem.identifier else { return }
        switch identifier {
        case .record:
            menuFunctionalityInvoker.startRecording()
        case .stopRecording:
            menuFunctionalityInvoker.stopRecording()
        case .settings:
            menuFunctionalityInvoker.showSettings()
        case .openOutputFolder:
            menuFunctionalityInvoker.openOutputFolder()
        case .screenshot:
            menuFunctionalityInvoker.takeScreenshot()
        case .giffromvidoes:
            menuFunctionalityInvoker.showStandAloneVideoToGifConverter()
        case .exit:
            objc_terminate()
        default:
            if identifier.rawValue.contains("simulators.device.") {
                let demarcatedIdentifier = identifier.rawValue.replacingOccurrences(of: "simulators.device.", with: "")
                let udid = demarcatedIdentifier.components(separatedBy: "|")[0]
                let actionIdentifier = demarcatedIdentifier.components(separatedBy: "|")[1]
                DeviceWorker(udid: udid, action: DeviceWorker.Action(actionIdentifier: actionIdentifier)).execute()
            }
        }
    }
}
extension MainMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        MainPopover.shared.dismissPopover()
    }

    func menuDidClose(_ menu: NSMenu) {

    }
}
