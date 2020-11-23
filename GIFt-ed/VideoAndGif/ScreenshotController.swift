//
//  ScreenshotController.swift
//  Sims
//
//  Created by Singh, Manish on 4/2/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

//class ScreenshotController {
//    func takeScreenShot() {
//        let bootedDevices = Simulator.getSystemInfo().bootedDevices
//        guard !bootedDevices.isEmpty else {
//            StatusBarDisplayManager.shared.temporarilyDisplayCannotRecord()
//            return
//        }
//        let device = bootedDevices[0]
//
//        DispatchQueue.global().async {
//            let screenShotCommand = "xcrun simctl io \(device.udid) screenshot --type=png --mask=black \(FilePathManager().outputSavePath(for: device))"
//            _ = screenShotCommand.runAsCommand()
//        }
//    }
//}
