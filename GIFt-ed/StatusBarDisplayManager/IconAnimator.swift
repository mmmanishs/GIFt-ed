//
//  IconAnimator.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/25/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import AppKit

class IconAnimator {
    private var timer: Timer?
    let button: NSButton
    private var counter = 0
    private var maxCount = 0

    init(button: NSButton) {
        self.button = button
    }

    func animate(with strings:[String], timeInterval: TimeInterval = 0.5) {
        maxCount = strings.count
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { t in
            self.button.image = nil
            self.button.title = strings[self.counter]
            self.counter += 1
            if self.counter == self.maxCount {
                self.counter = 0
            }
        }
        timer?.fire()
    }

    func animate(with images: [NSImage], timeInterval: TimeInterval = 0.5) {
        maxCount = images.count
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { t in
            self.button.image = images[self.counter]
            self.button.title = ""
            self.counter += 1
            if self.counter == self.maxCount {
                self.counter = 0
            }
        }
        timer?.fire()
    }

    func stopAnimaton() {
        timer?.invalidate()
        timer = nil
    }
}
