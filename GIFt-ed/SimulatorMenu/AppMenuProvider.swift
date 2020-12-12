//
//  AppMenuProvider.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/11/20.
//

import AppKit

class AppMenuProvider {
    private let device: Simulator.Device
    private var selector: Selector

    init(_ device: Simulator.Device, selector: Selector) {
        self.device = device
        self.selector = selector
    }

    var installedApps: NSMenuItem {
        let menuItem = NSMenuItem(title: "Installed Apps", action: selector, keyEquivalent: "")
        menuItem.identifier = .simulatorIdentifier(identifier: "installed-apps")

        let menu = NSMenu(title: "")
        menuItem.submenu = menu
        menu.items = [.menuItem(with: "loading...", color: .lightGray)]

        DispatchQueue.global().async {
            let appItems = SandboxInspector(rootPath: self.device.appsSandboxRootPath).inspect().map {self.getMenuItem(for: $0)}
            if appItems.isEmpty {
                menu.items = [.menuItem(with: "no installed apps", color: .lightGray)]
            } else {
                menu.items = appItems
            }
        }

        return menuItem
    }

    func getMenuItem(for sandboxApp: SandboxApp) -> NSMenuItem {
        let menuItem = NSMenuItem(title: sandboxApp.name, action: selector, keyEquivalent: "")
        return menuItem
    }
}

extension NSMenuItem {
    static func menuItem(with title: String, color: NSColor = .black) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.attributedTitle = title.attributedString(color: color)
        return menuItem
    }
}
