//
//  UserMessagePopupViewController.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/30/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Cocoa

class UserMessagePopupViewController: NSViewController {

    @IBOutlet var messageLabel: NSTextField!
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.stringValue = message
    }
    
}
