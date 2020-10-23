//
//  MainMenuViewModel.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/24/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

struct MainMenuViewModel {
    static var shared: MainMenuViewModel!
    var menuItems: [NSMenuItem]!

    static func initailizeSingleton() {
        MainMenuViewModel.shared = MainMenuViewModel()
        MainMenuViewModel.shared.menuItems = MainMenuViewModel.launchMenuItems()
    }

    private static func launchMenuItems() -> [NSMenuItem] {
        return NSMenuItem.markup
    }

    mutating func record(isEnabled: Bool) {
        if let index = menuItems.firstIndex(where: { $0.identifier == .record } ) {
            let newItem = menuItems[index]
            newItem.isEnabled = isEnabled
        }
    }

    mutating func updateOutputPath() {
        if let index = menuItems.firstIndex(where: { $0.identifier == .openOutputFolder } ) {
            let newItem = menuItems[index]
            let outputPath = UserPreferences.retriveFromDisk().outputFolderPath
            newItem.title = "📂 \(outputPath)"
            newItem.toolTip = "Open \(outputPath)"
        }
    }

    mutating func update(for state: VideoAndGifManager.RecorderState) {
        switch state {
        case .couldNotPreviouslyRecord, .readyToRecord, .stopped:
            setRecord(isHidden: false)
            setStopRecording(isHidden: true)
        case .recording:
            setRecord(isHidden: true)
            setStopRecording(isHidden: false)
        }
    }

    private mutating func setRecord(isHidden: Bool) {
        if let index = menuItems.firstIndex(where: { $0.identifier == .record } ) {
            let newItem = menuItems[index]
            newItem.isHidden = isHidden
        }
    }

    private mutating func setStopRecording(isHidden: Bool) {
        if let index = menuItems.firstIndex(where: { $0.identifier == .stopRecording } ) {
            let newItem = menuItems[index]
            newItem.isHidden = isHidden
        }
    }

}
