//
//  OpenURLViewController.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/11/20.
//

import Cocoa

class OpenURLViewController: NSViewController, NSTextFieldDelegate {
    static func display(for device: Simulator.Device) {
        let vc = OpenURLViewController(nibName: "OpenURLViewController", bundle: nil)
        vc.device = device
        vc.presentAsModalWindow(vc)
    }
    var device: Simulator.Device!
    @IBOutlet weak var deviceName: NSTextField! {
        didSet {
            deviceName.stringValue = device.nameAndRuntime
        }
    }

    @IBOutlet weak var openURLButton: NSButton!
    @IBOutlet weak var urlTextField: NSTextField! {
        didSet {
            if let urlString = UserDefaults.standard.value(forKey: "last-used-url-string") as? String {
                urlTextField.stringValue = urlString
            }
        }
    }

    @IBOutlet weak var deviceUdid: NSTextField! {
        didSet {
            deviceUdid.stringValue = device.udid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Open URL in Simulator Safari"
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        if let returnInt = obj.userInfo?["NSTextMovement"] as? Int,
           returnInt == NSReturnTextMovement {
            openURL()
        }
    }

    @IBAction func openURLButtonClicked(_ sender: Any) {
        openURL()
    }

    func openURL() {
        DeviceWorker(udid: self.device.udid, action: .openURL).openURL(urlString: urlTextField.stringValue)
        if !urlTextField.stringValue.isEmpty {
            UserDefaults.standard.setValue(urlTextField.stringValue, forKey: "last-used-url-string")
        }
    }
}
