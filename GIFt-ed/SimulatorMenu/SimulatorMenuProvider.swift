//
//  SimulatorMenuProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 11/25/20.
//

import AppKit

class SimulatorMenuProvider {
    var selector = #selector(MainMenuManager.functionalityRouter(_:))
    var appMenuProviderBag = [String : AppMenuProvider]()
    var simulatorMenu: NSMenu {
        let menu = NSMenu(title: "Simulators")
        menu.items = simulatorMenuItems
        return menu
    }
    private var simulatorMenuOptionsProvider: SimulatorMenuOptionsProvider?
    private var simulatorMenuItems: [NSMenuItem] {
        guard let runtimeAndDevics = cachedSystemInfo?.simulator?.devices else {
            return []
        }
        return runtimeAndDevics.map { nugget in
            let menuItem: NSMenuItem
            if isAnyBooted(nugget.value) {
                menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
                menuItem.attributedTitle = Simulator.prettyRuntime(from: nugget.key).boldAttributedString(size: 14)
            } else {
                menuItem = NSMenuItem(title: Simulator.prettyRuntime(from: nugget.key), action: nil, keyEquivalent: "")
            }
            let subMenu = NSMenu(title: "")
            subMenu.items = nugget.value.map { device in
                return menuItemShortName(for: device)
            }
            menuItem.submenu = subMenu
            return menuItem
        }
    }

    func isAnyBooted(_ devices: [Simulator.Device]) -> Bool {
        for device in devices {
            if device.state == .booted { return true }
        }
        return false
    }

    func menuItem(for deviceID: String) -> NSMenuItem? {
        guard let device = cachedSystemInfo?.getDevice(for: deviceID) else { return nil }
        return menuItem(for: device)
    }

    func menuItemShortName(for device: Simulator.Device) -> NSMenuItem {
        let item: NSMenuItem
        if device.state == .booted {
            item = NSMenuItem(title: device.name, action: selector, keyEquivalent: "")
            item.attributedTitle = device.name.boldAttributedString(size: 14)
        } else {
            item = NSMenuItem(title: device.name, action: selector, keyEquivalent: "")
        }
        item.identifier = .simulatorIdentifier(identifier: "\(device.udid)|\(DeviceWorker.Action.boot.rawValue)")
        item.submenu = getMenu(for: device)
        return item
    }

    func menuItem(for device: Simulator.Device) -> NSMenuItem {
        let item: NSMenuItem
        if device.state == .booted {
            item = NSMenuItem(title: device.nameAndRuntime, action: selector, keyEquivalent: "")
            item.attributedTitle = device.nameAndRuntime.boldAttributedString(size: 14)
        } else {
            item = NSMenuItem(title: device.nameAndRuntime, action: selector, keyEquivalent: "")
        }
        item.identifier = .simulatorIdentifier(identifier: "\(device.udid)|\(DeviceWorker.Action.boot.rawValue)")
        item.submenu = getMenu(for: device)
        return item
    }

    func getMenu(for device: Simulator.Device) -> NSMenu {
        let optionsProvider = SimulatorMenuOptionsProvider(device.udid, selector: selector)
        simulatorMenuOptionsProvider = optionsProvider
        var appMenuProvider: AppMenuProvider
        if let provider = appMenuProviderBag[device.udid] {
            appMenuProvider = provider
        } else {
            appMenuProvider = AppMenuProvider(device, selector: selector)
        }
        let menu = NSMenu(title: "")
        menu.addItem(appMenuProvider.installedApps)
        menu.addItem(optionsProvider.openURLWindow)
        if device.state == .shutdown {
            menu.addItem(optionsProvider.bootMenuItem)
        }
        if device.state == .booted {
            menu.addItem(optionsProvider.shutDownMenuItem)
            menu.addItem(optionsProvider.restartMenuItem)
        }
        menu.addItem(optionsProvider.toggleLightDarkMode)
        menu.addItem(NSMenuItem.dividerLine)
        menu.addItem(optionsProvider.copyUdid)
        menu.addItem(NSMenuItem.dividerLine)
        menu.addItem(optionsProvider.openDeviceDataItem)
        menu.addItem(optionsProvider.appSandboxRootFolder)
        menu.addItem(NSMenuItem.dividerLine)
        menu.addItem(optionsProvider.resetKeyChain)
        menu.addItem(optionsProvider.erase)
        menu.addItem(NSMenuItem.dividerLine)
        menu.addItem(optionsProvider.deleteDevice)
        
        return menu
    }
}

extension String {
    func boldAttributedString(size: CGFloat)-> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: size)])
        return attributedString
    }

    func attributedString(color: NSColor)-> NSAttributedString {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor : color])
        return attributedString
    }
}
