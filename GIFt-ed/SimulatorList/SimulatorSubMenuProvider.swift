//
//  SimulatorSubMenuProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/25/20.
//

import AppKit

class SimulatorSubMenuProvider {
    static var selector = #selector(MainMenu.functionalityRouter(_:))
    static func simulatorMenus() -> NSMenu {
        let menu = NSMenu(title: "Simulators")
        menu.items = getSimulatorMenuItems()
        return menu
    }

    static private func getSimulatorMenuItems() -> [NSMenuItem] {
        guard let runtimeAndDevics = SystemInfo().simulator?.devices else {
            return []
        }
        return runtimeAndDevics.map { nugget in
            let menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
            let subMenu = NSMenu(title: "qwqw")
            subMenu.items = nugget.value.map { device in
                let item = NSMenuItem(title: device.name, action: selector, keyEquivalent: "")
                item.identifier = .simulatorIdentifier(identifier: device.udid)
                return item
            }
            menuItem.submenu = subMenu
            return menuItem
        }
    }
}
