//
//  UserMessagePopup.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/30/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

class UserMessagePopup {
    static let shared: UserMessagePopup = {
        let controller = UserMessagePopup()
        return controller
    }()

    private var viewController: NSViewController?

    func show(message: String, for duration: TimeInterval = 2.0) {
        let storyBoard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateController(withIdentifier: "UserMessagePopupViewController") as! UserMessagePopupViewController
        vc.message = message
        viewController = vc
        MainPopover.shared.showInPopover(viewController: vc)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            MainPopover.shared.dismissPopover()
        }
    }
}
