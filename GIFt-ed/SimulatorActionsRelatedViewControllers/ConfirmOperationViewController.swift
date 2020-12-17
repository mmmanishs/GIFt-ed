//
//  ConfirmOperationViewController.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/4/20.
//

import Cocoa

class ConfirmOperationViewController: NSViewController, NSTextFieldDelegate {
    var completionHandler: ((Bool) -> ())?
    var viewModel: ViewModel!
    @IBOutlet weak var mainDescription: NSTextField! {
        didSet {
            mainDescription.isSelectable = true
        }
    }
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var footnote: NSTextField! {
        didSet {
            footnote.isSelectable = true
        }
    }
    @IBOutlet weak var rightArrow: NSTextField!
    @IBOutlet weak var confirmTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.stringValue = viewModel.headerPreExecution
        mainDescription.stringValue = viewModel.mainDescription
        footnote.stringValue = viewModel.footNote
        confirmTextField.placeholderString = "type '\(viewModel.confirmText)'"
        originalLocation = rightArrow.frame

    }

    override func viewDidAppear() {
        super.viewDidAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateView(view: self.rightArrow)
        }
    }
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField.stringValue == viewModel.confirmText {
            headerLabel.stringValue = viewModel.headerPostExecution
            confirmTextField.isHidden = true
            completionHandler?(true)
        }
    }

    var originalLocation: CGRect!
    var rightArrowToggle = false
    func animateView(view: NSView) {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            rightArrow.frame =  rightArrow.frame.moveY(by: 2 * (rightArrowToggle ? 1 : -1))
            rightArrowToggle.toggle()
        }, completionHandler: { [self] in
            animateView(view: view)
        })
    }
}

extension ConfirmOperationViewController {
    static func viewController(viewModel: ViewModel, completionHandler: ((Bool) -> ())?) -> ConfirmOperationViewController {
        let vc = ConfirmOperationViewController(nibName: "ConfirmOperationViewController", bundle: nil)
        vc.viewModel = viewModel
        vc.completionHandler = completionHandler
        return vc
    }

    struct ViewModel {
        let headerPreExecution: String
        let headerPostExecution: String
        let mainDescription: String
        let footNote: String
        let confirmText: String
    }
}


extension ConfirmOperationViewController.ViewModel {
    static func deleteDevice(device: Simulator.Device) -> ConfirmOperationViewController.ViewModel {
        return ConfirmOperationViewController.ViewModel(headerPreExecution: "Delete?",
                                                 headerPostExecution: "Deleted",
                                                 mainDescription: device.nameAndRuntime,
                                                 footNote: device.udid,
                                                 confirmText: "confirm"
        )
    }

    static func deleteApp(identifier: DeviceAppIdentiferParser) -> ConfirmOperationViewController.ViewModel {

        // TODO
        let device = AppInMemoryCaches.cachedSystemInfo!.getDevice(for: identifier.udid)!
        return ConfirmOperationViewController.ViewModel(headerPreExecution: "Delete?",
                                                 headerPostExecution: "Deleted",
                                                 mainDescription: identifier.appName,
                                                 footNote: "Installed on \(device.nameAndRuntime)",
                                                 confirmText: "confirm"
        )
    }
}

extension NSRect {
    func moveY(by point: CGFloat) -> NSRect {
        return NSRect(x: origin.x, y: origin.y + point, width: size.width, height: size.height)
    }
}
