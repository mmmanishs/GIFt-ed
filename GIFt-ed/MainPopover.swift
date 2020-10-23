//
//  MainPopover.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/27/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit


/// Use this class's singleton to show any viewController in a popover
class MainPopover {
    private var popover: NSPopover?
    var popoverIsCurrentlyVisible = false
    static let shared: MainPopover = {
        let popover = MainPopover()
        return popover
    }()

    func showInPopover(viewController: NSViewController, behavior: NSPopover.Behavior = .transient) {
        let popover = NSPopover()
        popover.behavior = behavior
        if let button = AppDelegate.statusItem.button {
            popover.contentViewController = viewController
            self.popoverIsCurrentlyVisible = true
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentSize = viewController.view.bounds.size
        }
        self.popover = popover
    }

    @objc func dismissPopover() {
        popover?.performClose(nil)
        popoverIsCurrentlyVisible = false
    }
}
