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
            setStartRecordingVisible()
        case .recording:
            setStartStopVisible()
        }
    }

    private mutating func setStartRecordingVisible() {
        var menuDescriptor = MenuDescriptor.load()

        guard var recordItem = menuDescriptor.getFirstItem(for: .startVideoCature) else { return }
        recordItem.isEnabled = true
        _ = menuDescriptor.update(item: recordItem)

        guard var stopRecord = menuDescriptor.getFirstItem(for: .stopVideoCature) else { return }
        stopRecord.isEnabled = false
        _ = menuDescriptor.update(item: stopRecord)

        menuDescriptor.persistToDisk()
    }

    private mutating func setStartStopVisible() {
        var menuDescriptor = MenuDescriptor.load()

        guard var recordItem = menuDescriptor.getFirstItem(for: .startVideoCature) else { return }
        recordItem.isEnabled = false
        _ = menuDescriptor.update(item: recordItem)

        guard var stopRecord = menuDescriptor.getFirstItem(for: .stopVideoCature) else { return }
        stopRecord.isEnabled = true
        _ = menuDescriptor.update(item: stopRecord)

        menuDescriptor.persistToDisk()
    }

}
