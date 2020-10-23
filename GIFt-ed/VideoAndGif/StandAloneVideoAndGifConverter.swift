//
//  StandAloneVideoAndGifConverter.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 10/1/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

class StandAloneVideoAndGifConverter: NSViewController {
    var isGifCreated = false
    var latestGifPath = ""
    var preferences: UserPreferences {
        UserPreferences.retriveFromDisk()
    }

    @IBOutlet var spinner: NSProgressIndicator! {
        didSet {
            spinner.isHidden = true
            spinner.startAnimation(self)
        }
    }
    @IBOutlet var sliderGiphyFps: NSSlider! {
        didSet {
            sliderGiphyFps.integerValue = preferences.giphyFpsFromVideos
            sliderGiphyFps.isContinuous = true
        }
    }

    @IBOutlet var sliderGiphyScale: NSSlider! {
        didSet {
            sliderGiphyScale.integerValue = preferences.giphyScaleFromVideos
            sliderGiphyScale.isContinuous = true
        }
    }

    @IBOutlet var labelGiphyFps: NSTextField! {
        didSet {
            labelGiphyFps.stringValue = String(preferences.giphyFpsFromVideos)
        }
    }

    @IBOutlet var labelGiphyScale: NSTextField! {
        didSet {
            labelGiphyScale.stringValue = String(preferences.giphyScaleFromVideos)
        }
    }

    @IBOutlet var labelGifCreatedSize: NSTextField!


    @IBOutlet var buttonCreate: NSButton!
    @IBOutlet var labelDroppedFile: NSTextField!

    @IBOutlet var fileDropView: DropView! {
        didSet {
            isGifCreated = false
            fileDropView.wantsLayer = true
            fileDropView.layer?.backgroundColor = .clear
            fileDropView.setAcceptableFileExtensions(extensions: ["mov", "mp4"])
            fileDropView.fileDropppedHandler = { files in
                self.labelDroppedFile.stringValue = files[0]
                self.buttonCreate.isEnabled = true
            }
        }
    }

    @IBAction func sliderGiphyFpsValueChanged(_ sender: Any) {
        readyToMakeGif()
        var preferences = UserPreferences.retriveFromDisk()
        let slider = sender as! NSSlider
        preferences.giphyFpsFromVideos = slider.integerValue
        labelGiphyFps.stringValue = String(slider.integerValue)
        UserPreferences.saveToDisk(preferences)
    }

    @IBAction func sliderGiphyScaleValueChanged(_ sender: Any) {
        readyToMakeGif()
        var preferences = UserPreferences.retriveFromDisk()
        let slider = sender as! NSSlider
        preferences.giphyScaleFromVideos = slider.integerValue
        labelGiphyScale.stringValue = String(slider.integerValue)
        UserPreferences.saveToDisk(preferences)
    }

    @IBAction func buttonCreateGifFromClicked(_ sender: Any) {
        if isGifCreated {
            DispatchQueue.global().async {
                _ = "qlmanage -p '\(self.latestGifPath)'".runAsCommand()
            }
        } else {
            startedMakingGif()
            let preferences = UserPreferences.retriveFromDisk()
            let filepath = self.labelDroppedFile.stringValue
            latestGifPath = filepath.getPathToSave(toType: "gif")
            DispatchQueue.global().async {
                let v2g = VideoToGifConverter(moviePath: filepath,
                                              giphyFps: preferences.giphyFpsFromVideos,
                                              giphyScale: preferences.giphyScaleFromVideos,
                                              outputPath: self.latestGifPath)
                v2g.convertToGif {
                    self.finishedMakingGif()
                }
            }
        }
    }

    @IBAction func buttonCloseClicked(_ sender: Any) {
        MainPopover.shared.dismissPopover()
    }

    override func mouseDown(with theEvent: NSEvent) {
        MainPopover.shared.dismissPopover()
    }

    func startedMakingGif() {
        buttonCreate.isHidden = true
        spinner.isHidden = false
        self.labelGifCreatedSize.stringValue = ""
    }

    func finishedMakingGif() {
        isGifCreated = true
        DispatchQueue.main.async {
            self.buttonCreate.isHidden = false
            self.buttonCreate.title = "✅"
            self.spinner.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.buttonCreate.title = "Quick Look"
            }
            self.labelGifCreatedSize.stringValue = "Gif size: \(self.latestGifPath.humanReadableFileSizeFromBash)"
        }
    }

    func readyToMakeGif() {
        buttonCreate.title = "Create Gif"
        isGifCreated = false
    }
}

extension StandAloneVideoAndGifConverter {
    static var viewController: StandAloneVideoAndGifConverter {
        let storyBoard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateController(withIdentifier: "StandAloneVideoAndGifConverter") as! StandAloneVideoAndGifConverter
        return vc
    }
}
