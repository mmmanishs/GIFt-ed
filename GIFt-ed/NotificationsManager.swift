//
//  NotificationsManager.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/18/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class NotificationsManager: NSObject, NSUserNotificationCenterDelegate {
    func postStartingRecording(device: Simulator.Device, outputFolder: String) {
        let notification = NSUserNotification()
        notification.title = "Recording \(device.name)"
        notification.subtitle = "\(device.udid)"
        let identifier = .record_user_notification_identifier + Date.currenttimeStampAndDateString
        notification.identifier = identifier
        notification.userInfo = [.output_folder_path : outputFolder]
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }

    func postUnableToRecord() {
        let notification = NSUserNotification()
        notification.title = "No booted Simulator"
        let identifier = Date.currenttimeStampAndDateString
        notification.identifier = identifier
        notification.subtitle = "Please open a simulator which you want to record"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }

    func postFinishedRecord(outputPath: String, outputFolder: String) {
        let notification = NSUserNotification()
        notification.title = "Finished"
        notification.subtitle = "Saved recording at \(outputPath)"
        let identifier = .record_user_notification_identifier + Date.currenttimeStampAndDateString
        notification.identifier = identifier
        notification.userInfo = [.output_folder_path : outputFolder]
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if let identifier = notification.identifier,
            identifier.contains(String.record_user_notification_identifier),
            let outputFolderPath = notification.userInfo?[.output_folder_path] as? String {
            outputFolderPath.openFolder()
        }
    }
}

fileprivate extension String {
    static var record_user_notification_identifier: String { "record_user_notification_identifier" }
    static var output_folder_path: String { "output_folder_path" }
}
