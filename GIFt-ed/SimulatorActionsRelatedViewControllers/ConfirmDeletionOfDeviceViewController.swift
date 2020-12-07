//
//  ConfirmDeletionOfDeviceViewController.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/4/20.
//

import Cocoa

class ConfirmDeletionOfDeviceViewController: NSViewController, NSTextFieldDelegate {
    var device: Simulator.Device!
    @IBOutlet weak var deviceName: NSTextField! {
        didSet {
            deviceName.isSelectable = true
        }
    }
    @IBOutlet weak var headerLabel: NSTextField!

    @IBOutlet weak var udid: NSTextField! {
        didSet {
            deviceName.isSelectable = true
        }
    }
    @IBOutlet weak var confirmTextField: NSTextField!
    static func viewController(for device: Simulator.Device) -> ConfirmDeletionOfDeviceViewController {
        let vc = ConfirmDeletionOfDeviceViewController(nibName: "ConfirmDeletionOfDeviceViewController", bundle: nil)
        vc.device = device
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceName.stringValue = device.nameAndRuntime
        udid.stringValue = device.udid
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
          if textField.stringValue == "confirm" {
            DispatchQueue.global().async {
                DeviceWorker(udid: self.device.udid, action: .delete).execute() {_ in 
                    cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])
                }
            }
            headerLabel.stringValue = "Deleted"
            confirmTextField.isHidden = true
          }
      }
}
