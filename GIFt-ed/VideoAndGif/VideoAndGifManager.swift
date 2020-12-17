//
//  VideoAndGifManager.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/17/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Cocoa

class VideoAndGifManager {
    enum RecorderState {
        case readyToRecord, recording, couldNotPreviouslyRecord, stopped
    }

    private var deviceBeingRecorded: Simulator.Device?
    private var simulatorVideoRecordController = SimulatorVideoRecordController()
    private var videoToGifConverter: VideoToGifConverter?
    private let notificationsManager = NotificationsManager()
    private var statusItem: NSStatusItem?
    private var currentOutputFilePath: String?
    private var recorderState: RecorderState = .readyToRecord {
        didSet {
            eventNotifierHandler?(recorderState)
        }
    }
    private var videoPath: String?
    private var preferences: UserPreferences {
        UserPreferences.retriveFromDisk()
    }
    private var shouldPostNotification: Bool {
        return preferences.sendNotificationsForEvents
    }
    var eventNotifierHandler: ((RecorderState)-> ())?

    func respondToClickEvent() {
        /// Transition from a previous state to next state
        switch recorderState {
        case .readyToRecord:
            startRecordSession()
        case .recording:
            stopRecordSession()
        case .couldNotPreviouslyRecord:
            startRecordSession()
        case .stopped:
            startRecordSession()
        }
    }

    private func startRecordSession() {
        AppInMemoryCaches.refreshCachedSystemInfo()
        guard let bootedDevice = AppInMemoryCaches.cachedSystemInfo?.topMostBootedDevice else {
            StatusBarDisplayManager.shared.temporarilyDisplayCannotRecord()
            UserMessagePopup.shared.show(message: "No booted simulator found. Please open a simulator to enable recording")
            currentOutputFilePath = nil
            recorderState = .couldNotPreviouslyRecord
            return
        }
        deviceBeingRecorded = bootedDevice
        UserMessagePopup.shared.show(message: "\(bootedDevice.nameAndRuntime) <...Recording...>")
        let videoPath = FilePathManager().outputSavePath(for: bootedDevice)
        currentOutputFilePath = videoPath
        self.videoPath = videoPath
        StatusBarDisplayManager.shared.currentlyRecording()
        simulatorVideoRecordController.startRecording(videoPath: videoPath)
        if shouldPostNotification {
            let preferences = UserPreferences.retriveFromDisk()
            notificationsManager.postStartingRecording(device: bootedDevice, outputFolder: preferences.outputFolderPath)
        }
        recorderState = .recording
    }

    private func stopRecordSession() {
        // Ready for recording again
        StatusBarDisplayManager.shared.readyForRecording()
        simulatorVideoRecordController.stopRecording()
        guard let videoPath = videoPath,
              let device = deviceBeingRecorded else {
            return
        }
        // Convert video to Gif
        if preferences.automaticallyCreateGiphyForRecording {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let gifPath = videoPath.withFileTypeUpdatedTo(type: "gif")
                self.videoToGifConverter = VideoToGifConverter(moviePath: videoPath,
                                                               giphyFps: self.preferences.giphyFps,
                                                               giphyScale: self.preferences.giphyScale,
                                                               gifSavePath: gifPath)
                self.videoToGifConverter?.convertToGif {
                    DispatchQueue.main.async {
                        let resultVC = RecordingResultViewController.viewController(deviceName: device.nameAndRuntime,
                                                                                    moviePath: videoPath,
                                                                                    gifPath: gifPath,
                                                                                    outputFolderPath: FilePathManager().outputSaveFolderPath(for: device))
                        MainPopover.shared.showInPopover(viewController: resultVC, behavior: .applicationDefined)
                    }
                }
            }
        } else {
            let resultVC = RecordingResultViewController.viewController(deviceName: device.nameAndRuntime, moviePath: videoPath, gifPath: "", outputFolderPath: FilePathManager().outputSaveFolderPath(for: device))
            MainPopover.shared.showInPopover(viewController: resultVC, behavior: .applicationDefined)
        }
        let preferences = UserPreferences.retriveFromDisk()
        if let cpath = currentOutputFilePath,
            shouldPostNotification {
            notificationsManager.postFinishedRecord(outputPath: cpath, outputFolder: preferences.outputFolderPath)
        }
        if preferences.openOutputFolderAfterJobCompletion {
            FilePathManager().outputSaveFolderPath(for: device).openFolder()
        }
        recorderState = .stopped
    }
}

extension String {
    func openFolder() {
        DispatchQueue.global().async {
            _ = "open '\(self)'".runAsCommand()
        }
    }

    func openFinderAndSelectFile() {
        DispatchQueue.global().async {
            _ = "open -R '\(self)'".runAsCommand()
        }
    }
}
