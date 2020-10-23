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
        let bootedDevices = Simulator.getSystemInfo().bootedDevices
        guard !bootedDevices.isEmpty else {
            StatusBarDisplayManager.shared.temporarilyDisplayCannotRecord()
            UserMessagePopup.shared.show(message: "No booted simulator found. Please open a simulator to enable recording")
            currentOutputFilePath = nil
            recorderState = .couldNotPreviouslyRecord
            return
        }
        let device = bootedDevices[0]
        let videoPath = FilePathManager().outputSavePath(for: device)
        currentOutputFilePath = videoPath
        self.videoPath = videoPath
        StatusBarDisplayManager.shared.currentlyRecording()
        simulatorVideoRecordController.startRecording(videoPath: videoPath)
        if shouldPostNotification {
            let preferences = UserPreferences.retriveFromDisk()
            notificationsManager.postStartingRecording(device: device, outputFolder: preferences.outputFolderPath)
        }
        recorderState = .recording
    }

    private func stopRecordSession() {
        // Ready for recording again
        StatusBarDisplayManager.shared.readyForRecording()
        simulatorVideoRecordController.stopRecording()
        
        // Convert video to Gif
        if preferences.automaticallyCreateGiphyForRecording,
            let videoPath = videoPath {
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.videoToGifConverter = VideoToGifConverter(moviePath: videoPath, giphyFps: self.preferences.giphyFps, giphyScale: self.preferences.giphyScale)
                self.videoToGifConverter?.convertToGif()
            }
        }
        let preferences = UserPreferences.retriveFromDisk()
        if let cpath = currentOutputFilePath,
            shouldPostNotification {
            notificationsManager.postFinishedRecord(outputPath: cpath, outputFolder: preferences.outputFolderPath)
        }
        if preferences.openOutputFolderAfterJobCompletion {
            preferences.outputFolderPath.openFolder()
        }
        recorderState = .stopped
    }
}

extension String {
    func openFolder() {
        DispatchQueue.global().async {
            _ = "open \(self)".runAsCommand()
        }
    }
}
