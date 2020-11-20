//
//  StatusBarDisplayManager.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/17/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Cocoa

enum Icons {
    enum MainAppIcon {
        /// if true shows text
        static let showImage = true
        static let mainIconTitle = "🎥"
        static let mainIconImage: NSImage = ._camcorder
    }
    enum NoBootedSimulator {
        static let mainIconImage: NSImage = ._phoneNotAvailable
    }
    enum LoadingAnimation {
    static let timeDelay = 0.3
    static let cameraClick = ["📷", "📸"]
    static let redCircle = ["⭕️", "🔴"]
    static let redCircle1 = ["", "🔴"]
    static let plus = ["✢", "✣","✤", "✥", "✦"]
    static let arrow = ["↑", "→", "↓", "←"]
    static let globe = ["🌎", "🌍", "🌏"]
    static let iphone = ["📱", "📱", "📱"]
    static let weather = ["☀️", "🌤", "⛅️", "🌥", "☁️", "🌦", "🌧", "⛈","🌩", "🌨", "❄️", "🌪"]
    static let new = [""]
    static var current = cameraClick + cameraClick + iphone
    }
}

class StatusBarDisplayManager {
    static var shared: StatusBarDisplayManager!
    let statusDisplayButton: NSStatusBarButton
    var iconAnimator: IconAnimator

    init(statusDisplayButton: NSStatusBarButton) {
        self.statusDisplayButton = statusDisplayButton
        iconAnimator = IconAnimator(button: statusDisplayButton)
    }

    static func initailizeSingleton(statusDisplayButton: NSStatusBarButton) {
        StatusBarDisplayManager.shared = StatusBarDisplayManager(statusDisplayButton: statusDisplayButton)
    }
}

/// MARK: Public funcs
extension StatusBarDisplayManager {
    func displayAppIcon() {
        /// App icon being same as the ready for recording icon
        setBarToCamcoderImage()
        iconAnimator.stopAnimaton()
    }

    func readyForRecording() {
        iconAnimator.stopAnimaton()
        setBarToCamcoderImage()
    }

    func temporarilyDisplayCannotRecord() {
        setBarToNoBootedSimulator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.setBarToCamcoderImage()
        }
    }

    func currentlyRecording() {
        iconAnimator.animate(with: Icons.LoadingAnimation.current, timeInterval: Icons.LoadingAnimation.timeDelay)
    }
}

extension StatusBarDisplayManager {

    private func setBarToCamcoderImage() {
        if Icons.MainAppIcon.showImage {
            statusDisplayButton.image = Icons.MainAppIcon.mainIconImage
            statusDisplayButton.title = ""
        } else {
            statusDisplayButton.image = nil
            statusDisplayButton.title = Icons.MainAppIcon.mainIconTitle
        }
    }

    private func displayBlank() {
        statusDisplayButton.image = nil
        statusDisplayButton.title = ""
    }

    private func setBarToNoBootedSimulator() {
        statusDisplayButton.image = Icons.NoBootedSimulator.mainIconImage
        statusDisplayButton.title = ""
    }
}


