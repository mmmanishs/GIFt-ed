//
//  MainEventHandler.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/18/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Cocoa

class MainEventHandler {
    private let videoAndGifManager = VideoAndGifManager()

    func respondTo(event: NSEvent.EventType) {
        if FeatureFlag.isMainMenuEnabled {
            MainPopover.shared.dismissPopover()
        } else {
            switch event {
            case .leftMouseUp:
                if !MainPopover.shared.popoverIsCurrentlyVisible {
                    videoAndGifManager.respondToClickEvent()
                } else {
                    MainPopover.shared.dismissPopover()
                }
            case .rightMouseUp:
                showPopover(sender: nil)
            default:
                print("#########Unhandled user action########")
            }
        }
    }

    func showPopover(sender: Any?) {
        MainPopover.shared.showInPopover(viewController: GeneralSettingsViewController.viewController { userAction in
            MainPopover.shared.dismissPopover()
            switch userAction {
            case .terminateAppTapped:
                objc_terminate()
            case .outputFolderPathUpdated:
                NotificationCenter.default.post(name: .updateMainMenu, object: nil)
            default: break
            }
        })
    }
}
