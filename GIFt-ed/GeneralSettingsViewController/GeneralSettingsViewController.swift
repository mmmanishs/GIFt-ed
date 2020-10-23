//
//  GeneralSettingsViewController.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/18/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Cocoa

class GeneralSettingsViewController: NSViewController {
    enum UserAction {
        case userTappedOnPopover, terminateAppTapped, popoverCurrentlyVisible, outputFolderPathUpdated
    }
    var preferences: UserPreferences {
        UserPreferences.retriveFromDisk()
    }
    var userActionCompletion: ((UserAction) -> ())?

    @IBOutlet var sliderGiphyFps: NSSlider! {
        didSet {
            sliderGiphyFps.integerValue = preferences.giphyFps
            sliderGiphyFps.isContinuous = true
        }
    }
    @IBOutlet var sliderGiphyScale: NSSlider! {
        didSet {
            sliderGiphyScale.integerValue = preferences.giphyScale
            sliderGiphyScale.isContinuous = true
        }
    }
    @IBOutlet var labelGiphyFps: NSTextField! {
        didSet {
            labelGiphyFps.stringValue = String(preferences.giphyFps)
        }
    }
    @IBOutlet var labelGiphyScale: NSTextField! {
        didSet {
            labelGiphyScale.stringValue = String(preferences.giphyScale)
        }
    }
    @IBOutlet var giphySettingsMessage: NSTextField! {
        didSet {
        }
    }
    @IBOutlet var outputFolderTextField: NSTextField! {
        didSet {
            outputFolderTextField.stringValue = preferences.outputFolderPath
        }
    }
    @IBOutlet var buttonAutoCreateGiphy: NSButton! {
        didSet {
            buttonAutoCreateGiphy.state = preferences.automaticallyCreateGiphyForRecording ? .on : .off
        }
    }
    @IBOutlet var buttonSendNotificationsForEvents: NSButton! {
        didSet {
            buttonSendNotificationsForEvents.state = preferences.sendNotificationsForEvents ? .on : .off
        }
    }
    @IBOutlet var buttonOpenOutputFolderAfterJobCompletion: NSButton! {
        didSet {
            buttonOpenOutputFolderAfterJobCompletion.state = preferences.openOutputFolderAfterJobCompletion ? .on : .off
        }
    }
    @IBOutlet var buttonOrganizeOutputFolderByDate: NSButton! {
        didSet {
            buttonOrganizeOutputFolderByDate.state = preferences.organizeOutputByDate ? .on : .off
        }
    }
    @IBOutlet var buttonUpdateOutputPath: NSButton! {
        didSet {
            buttonUpdateOutputPath.isHidden = true
            if let cell = buttonUpdateOutputPath.cell as? NSButtonCell {
                cell.imageDimsWhenDisabled = false
            }
        }
    }

    static func viewController(userActionCompletion: @escaping (UserAction) -> ()) -> GeneralSettingsViewController {
        let storyBoard = NSStoryboard(name: "Main", bundle: nil) 
        let vc = storyBoard.instantiateController(withIdentifier: "GeneralSettingsViewController") as! GeneralSettingsViewController
        vc.userActionCompletion = userActionCompletion
        return vc

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userActionCompletion?(UserAction.popoverCurrentlyVisible)
        outputFolderTextField.stringValue = preferences.outputFolderPath
        outputFolderTextField.resignFirstResponder()
        updateGiphyValueRangeSuggesstion()
        outputFolderTextField.delegate = self
    }

    override func mouseDown(with theEvent: NSEvent) {
        self.userActionCompletion?(UserAction.userTappedOnPopover)
    }
    
    @IBAction func buttonAutoCreateGiphyClicked(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let checkbox = sender as! NSButton
        if checkbox.state == .on {
            preferences.automaticallyCreateGiphyForRecording = true
        } else if checkbox.state == .off {
            preferences.automaticallyCreateGiphyForRecording = false
        }
        UserPreferences.saveToDisk(preferences)
    }


    @IBAction func buttonSendNotificationsForEventsClicked(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let checkbox = sender as! NSButton
        if checkbox.state == .on {
            preferences.sendNotificationsForEvents = true
        } else if checkbox.state == .off {
            preferences.sendNotificationsForEvents = false
        }
        UserPreferences.saveToDisk(preferences)
    }

    @IBAction func buttonOpenOutputFolderAfterJobCompletionClicked(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let checkbox = sender as! NSButton
        if checkbox.state == .on {
            preferences.openOutputFolderAfterJobCompletion = true
        } else if checkbox.state == .off {
            preferences.openOutputFolderAfterJobCompletion = false
        }
        UserPreferences.saveToDisk(preferences)
    }

    @IBAction func buttonOrganizeOutputFolderByDateClicked(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let checkbox = sender as! NSButton
        if checkbox.state == .on {
            preferences.organizeOutputByDate = true
        } else if checkbox.state == .off {
            preferences.organizeOutputByDate = false
        }
        UserPreferences.saveToDisk(preferences)
    }

    @IBAction func buttonTerminateAppClicked(_ sender: Any) {
        self.userActionCompletion?(UserAction.terminateAppTapped)
    }

    @IBAction func buttonOpenOutputFolderClicked(_ sender: Any) {
        preferences.outputFolderPath.openFolder()
        userActionCompletion?(UserAction.userTappedOnPopover)
    }

    @IBAction func buttonSaveChangesToOutputPathClicked(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        var isDir: ObjCBool = true
        let cleanPath = outputFolderTextField.stringValue.cleanedLastBackSlashInPath
        if FileManager.default.fileExists(atPath: cleanPath, isDirectory: &isDir) {
            preferences.outputFolderPath = cleanPath
            UserPreferences.saveToDisk(preferences)
            MainMenuViewModel.shared.updateOutputPath()
            showPathIsSavedMessage()
            self.userActionCompletion?(UserAction.outputFolderPathUpdated)
        } else {
            /// Try to create directory
            do {
                try FileManager.default.createDirectory(atPath: cleanPath, withIntermediateDirectories: true, attributes: nil)
                preferences.outputFolderPath = cleanPath
                UserPreferences.saveToDisk(preferences)
                MainMenuViewModel.shared.updateOutputPath()
                showPathIsCreatedMessage()
                self.userActionCompletion?(UserAction.outputFolderPathUpdated)
            } catch {
                /// Else revert back to old path
                outputFolderTextField.stringValue = preferences.outputFolderPath
                showPathUpdatedFailed()
            }
        }
    }

    func showPathIsSavedMessage() {
        buttonUpdateOutputPath.set(text: "✅", textColor: .black)
        buttonUpdateOutputPath.isBordered = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buttonUpdateOutputPath.isHidden = true
            self.buttonUpdateOutputPath.isEnabled = true
            self.buttonUpdateOutputPath.isBordered = true
        }
    }

    func showPathIsCreatedMessage() {
        buttonUpdateOutputPath.set(text: "✅ Created", textColor: .black)
        buttonUpdateOutputPath.isBordered = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buttonUpdateOutputPath.isHidden = true
            self.buttonUpdateOutputPath.isEnabled = true
            self.buttonUpdateOutputPath.isBordered = true
        }
    }

    func showPathUpdatedFailed() {
        buttonUpdateOutputPath.set(text: "🚫 Invalid", textColor: .black)
        buttonUpdateOutputPath.isBordered = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.buttonUpdateOutputPath.isHidden = true
            self.buttonUpdateOutputPath.isEnabled = true
            self.buttonUpdateOutputPath.isBordered = true
        }
    }


    @IBAction func sliderGiphyFpsValueChanged(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let slider = sender as! NSSlider
        preferences.giphyFps = slider.integerValue
        labelGiphyFps.stringValue = String(slider.integerValue)
        UserPreferences.saveToDisk(preferences)
        updateGiphyValueRangeSuggesstion()
    }

    @IBAction func sliderGiphyScaleValueChanged(_ sender: Any) {
        var preferences = UserPreferences.retriveFromDisk()
        let slider = sender as! NSSlider
        preferences.giphyScale = slider.integerValue
        labelGiphyScale.stringValue = String(slider.integerValue)
        UserPreferences.saveToDisk(preferences)
        updateGiphyValueRangeSuggesstion()
    }

    func updateGiphyValueRangeSuggesstion() {
        var warning = ""
        if preferences.giphyFps < 8 {
            warning += GeneralSettingsViewController.lowFpsWarning
            warning += " "
        }
        if preferences.giphyFps > 20 {
            warning += GeneralSettingsViewController.highFpsWarning
            warning += " "
        }
        if preferences.giphyScale < 200 {
            warning += GeneralSettingsViewController.lowScaleWarning
            warning += " "
        }
        if preferences.giphyScale > 700 {
            warning += GeneralSettingsViewController.highScaleWarning
            warning += " "
        }
        giphySettingsMessage.stringValue = warning
    }
}

extension GeneralSettingsViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let textfield = obj.object as! NSTextField
        if textfield === outputFolderTextField {
            let preferences = UserPreferences.retriveFromDisk()
            let newPath = textfield.stringValue.cleanedLastBackSlashInPath
            if preferences.outputFolderPath != newPath {
                buttonUpdateOutputPath.isHidden = false
                buttonUpdateOutputPath.set(text: "unsaved changes", textColor: .red)
            } else {
                buttonUpdateOutputPath.isHidden = true
            }
        }
    }
}

/// Giphy size warning message
extension GeneralSettingsViewController {
    static let lowFpsWarning = "Lower fps usually may cause gif to be jerkier but lower overall size."
    static let lowScaleWarning = "Lower scale may cause gif to be lower resolution but lower overall size."
    static let highFpsWarning = "Higher fps usually may make gif more smoother, but with higher overall size."
    static let highScaleWarning = "Higher scale usually may make gif more clearer, but with higher overall size."
}

extension NSButton {
    func set(text: String, textColor: NSColor) {
        let myAttribute = [ NSAttributedString.Key.foregroundColor: textColor ]
        let myAttrString = NSAttributedString(string: text, attributes: myAttribute)
        attributedTitle = myAttrString
    }
}
