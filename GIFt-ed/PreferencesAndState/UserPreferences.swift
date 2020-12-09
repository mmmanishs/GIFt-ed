//
//  UserPreferences.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/18/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

struct UserPreferences: Codable {
    var automaticallyCreateGiphyForRecording: Bool
    var sendNotificationsForEvents: Bool
    var organizeOutputByDate: Bool
    var openOutputFolderAfterJobCompletion: Bool
    var giphyFps: Int
    var giphyScale: Int
    var giphyFpsFromVideos: Int
    var giphyScaleFromVideos: Int
    var outputFolderPath: String
}

extension UserPreferences {
    /// Default User Preference.
    static var `default` = UserPreferences(automaticallyCreateGiphyForRecording: true,
                                           sendNotificationsForEvents: true,
                                           organizeOutputByDate: true,
                                           openOutputFolderAfterJobCompletion: true,
                                           giphyFps: 15,
                                           giphyScale: 400,
                                           giphyFpsFromVideos: 15,
                                           giphyScaleFromVideos: 400,
                                           outputFolderPath: "\(DiskPath.desktop)/SimRecordings")

    static func saveToDisk(_ userPreferences: UserPreferences) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(userPreferences) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "preferences")
            defaults.synchronize()
        }
    }

    static func retriveFromDisk() -> UserPreferences {
        let defaults = UserDefaults.standard
        if let preferencesData = defaults.object(forKey: "preferences") as? Data {
            let decoder = JSONDecoder()
            if let preferences = try? decoder.decode(UserPreferences.self, from: preferencesData) {
                return preferences
            }
        }
        return UserPreferences.default
    }
}
