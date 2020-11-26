//
//  MenuItemDefinition.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/26/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

extension NSMenuItem {
    /// These options will be displayed when the app icon is clicked
    static var markup: [NSMenuItem] {
        return [
            .simulatorTitle,
            .recordSimulator,
            .stopRecordingSimualtor,
            .openOutputFolder,
            .settings,
            .dividerLine,
            .gifFromVideos,
            .dividerLine,
            .dividerLine,
            .exit
        ]
    }
}

extension NSMenuItem {
    static var selector = #selector(MainMenu.functionalityRouter(_:))
    static var simulatorTitle: NSMenuItem {
        let item = NSMenuItem(title: "Simulators", action: selector, keyEquivalent: "")
        item.submenu = SimulatorSubMenuProvider.simulatorMenus()
        item.image = ._buildApps
        item.indentationLevel = 0
        item.toolTip = "Choose an option below"
        return item
    }

    static var recordSimulator: NSMenuItem {
        let item = NSMenuItem(title: "Start Video Capture", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._cameraReel
        item.identifier = .record
        item.toolTip = "This will record the video of your currently booted simulator"
        return item
    }

    static var stopRecordingSimualtor: NSMenuItem {
        let item = NSMenuItem(title: "Stop Video Capture", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.identifier = .stopRecording
        item.image = ._stopRecording
        item.isHidden = true
        item.toolTip = "This will stop recording the video of your currently booted simulator. The output will be saved in the defined output folder"
        return item
    }

    static var gifFromVideos: NSMenuItem {
        let item = NSMenuItem(title: "Convert Vidoes to GIF", action: selector, keyEquivalent: "")
        item.image = ._gif
        item.identifier = .giffromvidoes
        item.toolTip = "Make Gif from vidoes"
        return item
    }

    static var settings: NSMenuItem {
        let item = NSMenuItem(title: "Settings..", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._settingsFineTune
        item.identifier = .settings
        item.toolTip = "Settings specific to recording simulator videos."
        return item
    }

    static var openOutputFolder: NSMenuItem {
        let outputPath = UserPreferences.retriveFromDisk().outputFolderPath
        let item = NSMenuItem(title: "(Output Folder) \(outputPath)", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._openFolder
        item.identifier = .openOutputFolder
        item.toolTip = "This is your output folder where your recordings will be saved. \nTip: Choose something other than your Desktop folder to reduce clutter."
        return item
    }

    static var exit: NSMenuItem {
        let item = NSMenuItem(title: "Quit", action: #selector(MainMenu.functionalityRouter(_:)), keyEquivalent: "")
        item.identifier = .exit
        item.toolTip = "Thanks for using this app."
        return item
    }

    static var dividerLine: NSMenuItem {
        return NSMenuItem.separator()
    }
}

extension NSUserInterfaceItemIdentifier {
    static let record: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("record")
    static let stopRecording: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("stopRecording")
    static let screenshot: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("screenshot")
    static let settings: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("settings")
    static let giffromvidoes: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("giffromvidoes")
    static let simulators: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("simulators")
    static let openOutputFolder: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("openOutputFolder")
    static let exit: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("exit")

    static func simulatorIdentifier(identifier: String) -> NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier("simulators.device.\(identifier)")
    }
}
