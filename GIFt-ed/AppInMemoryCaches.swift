//
//  AppInMemoryCaches.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/13/20.
//

import Foundation

enum AppInMemoryCaches {
    static var cachedSystemInfo: SystemInfo?
    static var appMenuProviderBag = [String : AppMenuProvider]()
}
