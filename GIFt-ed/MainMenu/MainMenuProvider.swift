//
//  MenuItemDefinition.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/26/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

class MainMenuProvider {
    let simulatorMainMenuShortcutProvider = SimulatorMenuProvider()
    let simulatorMenuProvider = SimulatorMenuProvider()
    var selector = #selector(MainMenuManager.functionalityRouter(_:))
    var menuItemDictionary: [String: NSMenuItem] {
        return [
            "list-of-simulators": simulator,
            "start-video-cature": recordSimulator,
            "stop-video-cature": stopRecordingSimualtor,
            "open-output-folder": openOutputFolder,
            "video-capture-settings": settings,
            "convert-gif-to-video": gifFromVideos,
            "divider": NSMenuItem.dividerLine,
            "credits": credits,
            "quit": exit,
        ]
    }

    func fetchMenuItems() -> [NSMenuItem] {
        let menuDescriptor = MenuDescriptor.load()
        var menuMarkup = [NSMenuItem]()
        for item in menuDescriptor.items where item.isEnabled {
            switch item.element.key {
            case "cache-recently-accessed-devices":
                let deviceID = item.element.params
                if let item = simulatorMainMenuShortcutProvider.menuItem(for: deviceID) {
                    menuMarkup.append(item)
                }
            default:
                if let descriptorItem = menuItemDictionary[item.element.key] {
                    menuMarkup.append(descriptorItem)
                }
            }
        }
        return menuMarkup
    }

    var simulator: NSMenuItem {
        let item = NSMenuItem(title: "Simulators", action: selector, keyEquivalent: "")
        item.submenu = simulatorMenuProvider.simulatorMenu
        item.image = ._buildApps
        item.indentationLevel = 0
        item.identifier = .simulators
        item.toolTip = "Choose an option below"
        return item
    }

    var recordSimulator: NSMenuItem {
        let item = NSMenuItem(title: "Start Video Capture of a booted device", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._cameraReel
        item.identifier = .record
        item.toolTip = "This will record the video of your currently booted simulator. Have only once device open while recording. If multiple devices are present it will choose a random one."
        return item
    }

    var stopRecordingSimualtor: NSMenuItem {
        let item = NSMenuItem.menuItem(with: "Stop Video Capture", color: .systemRed)
        item.action = selector
        item.indentationLevel = 3
        item.identifier = .stopRecording
        item.image = ._stopRecording
        item.toolTip = "This will stop recording the video of your currently booted simulator. The output will be saved in the defined output folder"
        return item
    }

    var gifFromVideos: NSMenuItem {
        let item = NSMenuItem(title: "Convert Vidoes to GIF", action: selector, keyEquivalent: "")
        item.image = ._gif
        item.identifier = .giffromvidoes
        item.toolTip = "Make Gif from vidoes"
        return item
    }

    var settings: NSMenuItem {
        let item = NSMenuItem(title: "Settings for the device video capture..", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._settingsFineTune
        item.identifier = .settings
        item.toolTip = "Settings specific to recording simulator videos."
        return item
    }

    var openOutputFolder: NSMenuItem {
        let outputPath = UserPreferences.retriveFromDisk().outputFolderPath
        let item = NSMenuItem(title: "(Output Folder) \(outputPath)", action: selector, keyEquivalent: "")
        item.indentationLevel = 3
        item.image = ._openFolder
        item.identifier = .openOutputFolder
        item.toolTip = "This is your output folder where your recordings will be saved. \nTip: Choose something other than your Desktop folder to reduce clutter."
        return item
    }

    var exit: NSMenuItem {
        let item = NSMenuItem(title: "Quit", action: #selector(MainMenuManager.functionalityRouter(_:)), keyEquivalent: "")
        item.identifier = .exit
        item.toolTip = "Thanks for using this app."
        return item
    }

    var credits: NSMenuItem {
        let item = NSMenuItem(title: "Credits", action: #selector(MainMenuManager.functionalityRouter(_:)), keyEquivalent: "")
        item.identifier = .credits
        return item
    }
}

extension NSMenuItem {
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
    static let credits: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("credits")

    static func simulatorIdentifier(identifier: String) -> NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier("simulators.device.\(identifier)")
    }
}
