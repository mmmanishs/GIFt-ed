//
//  MenuFunctionalityInvoker.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/24/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

class MenuFunctionalityInvoker {
    weak var delegate: MainMenuUpdation?
    private let videoAndGifManager: VideoAndGifManager
    private let mainEventHandler: MainEventHandler?

    init() {
        videoAndGifManager = VideoAndGifManager()
        mainEventHandler = MainEventHandler()
        videoAndGifManager.eventNotifierHandler = { event in
            MainMenuViewModel.shared.update(for: event)
            self.delegate?.updateMenu()
        }
    }

    func startRecording() {
        videoAndGifManager.respondToClickEvent()
    }

    func stopRecording() {
        videoAndGifManager.respondToClickEvent()
    }

    func openOutputFolder() {
        UserPreferences.retriveFromDisk().outputFolderPath.openFolder()
    }

    func showSettings() {
        mainEventHandler?.showPopover(sender: nil)
    }

    func takeScreenshot() {
//        ScreenshotController().takeScreenShot()
    }

    func showStandAloneVideoToGifConverter() {
        MainPopover.shared.showInPopover(viewController: StandAloneVideoAndGifConverter.viewController, behavior: .semitransient)
    }

}

