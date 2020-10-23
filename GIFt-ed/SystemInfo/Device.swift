//
//  Device.swift
//  Sims
//
//  Created by Singh, Manish on 5/2/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import SwiftUI

extension Simulator {
    struct Device: Codable, Hashable {
        let state: DeviceState
        let isAvailable: Bool?
        let name, udid: String
        let availabilityError: AvailabilityError?
        var uniqueIdentifier: String { udid }
        var _runtime: String?
        var runtime: String {
            return  _runtime!
        }

        var family: Family {
            return Family(name)
        }

//        var deviceImage: Image {
//            if name.contains("iPhone") {
//                return Image("iphone")
//            } else if name.contains("iPad") {
//                return Image("ipad")
//            } else if name.contains("Apple Watch") {
//                return Image("applewatch")
//            }  else if name.contains("Apple TV") {
//                return Image("appletv")
//            }
//            return Image("iphone")
//        }

        var searchDescription: String {
            return "\(state.rawValue) \(name), \(uniqueIdentifier), \(runtimeFormatted)".lowercased()
        }
    }
}

extension Simulator.Device {
    var runtimeFormatted: String {
        var value = runtime.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
        value.replaceSubrange(value.firstIndex(of: "-")!...value.firstIndex(of: "-")!, with: " ")
        value.replaceSubrange(value.firstIndex(of: "-")!...value.firstIndex(of: "-")!, with: ".")
        return value
    }
}


extension Simulator.Device {
    enum Family: Int {
        case iPhone = 0
        case iPad
        case appleWatch
        case appleTv
        case others

        init(_ s: String) {
            switch true {
            case s.contains("iPhone"):
                self = .iPhone
            case s.contains("iPad"):
                self = .iPad
            case s.contains("Apple Watch"):
                self = .appleWatch
            case s.contains("Apple TV"):
                self = .appleTv
            case s.contains("iPhone"):
                self = .iPhone
            default:
                self = .others
            }
        }
    }
}
