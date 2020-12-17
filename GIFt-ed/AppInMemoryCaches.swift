//
//  AppInMemoryCaches.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/13/20.
//

import Foundation

enum AppInMemoryCaches {
    static var cachedSystemInfo: SystemInfo?
    private static var isRefreshing: Bool = false
    private static var timer: Timer?
    private static var lastRefreshDate: Date?
    private static var refreshCounter = 0

    static func refreshCachedSystemInfo() {
        guard !isRefreshing else {
            return
        }
        if let lastRefreshDate = lastRefreshDate {
            if Date().timeIntervalSince(lastRefreshDate) < 1 { return }
        }
        isRefreshing = true
        print("Refreshing Data")
        AppInMemoryCaches.cachedSystemInfo = SystemInfo(allowedTypes: [.iOS])
        lastRefreshDate = Date()
        isRefreshing = false
    }

    static func refreshSimulatorCacheData(every seconds: TimeInterval) {
        AppInMemoryCaches.timer?.invalidate()
        AppInMemoryCaches.timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { timer in
            DispatchQueue.global().async {
                AppInMemoryCaches.refreshCachedSystemInfo()
                refreshCounter += 1
                print("Refreshing. \(refreshCounter)")
            }
        }
        AppInMemoryCaches.timer?.fire()
    }
}
