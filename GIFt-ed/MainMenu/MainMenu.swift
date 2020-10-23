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
        MainMenuViewModel.shared.menuItems.forEach { $0.target = self }
        menu.items = MainMenuViewModel.shared.menuItems
        menu.delegate = self
        return menu
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
        default: break
            /// Do nothing
        }
    }
}
extension MainMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        MainPopover.shared.dismissPopover()
//        MainMenuViewModel.shared.record(isEnabled: Simulator.getSystemInfo().isAnyBootedSimulatorPresent)
    }

    func menuDidClose(_ menu: NSMenu) {

    }
}
