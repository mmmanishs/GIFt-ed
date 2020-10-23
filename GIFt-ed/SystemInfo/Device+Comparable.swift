//
//  Device+Comparable.swift
//  Sims
//
//  Created by Singh, Manish on 5/4/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

extension Simulator.Device: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return !(lhs.family.rawValue < rhs.family.rawValue)
    }

    func isGreaterEqualTo(device: Simulator.Device) -> Bool {
        print("\(name) >= \(device.name)")
        switch true {
        case family == .iPhone:
            print("1" + "true")
            return true
        case family == .iPad:
            print("2 \(device.family != .iPhone)")
            return device.family != .iPhone
        case family == .appleWatch:
            print("3 \(device.family != .iPhone || device.family != .iPad)")
            return device.family != .iPhone || device.family != .iPad
        case family == .appleTv:
            print("4 \(device.family != .iPhone || device.family != .iPad || device.family != .appleWatch)")
            return device.family != .iPhone || device.family != .iPad || device.family != .appleWatch
        default:
            print("5 false")
            return false
        }
    }

    func sortDeviceVersion(lhs: Simulator.Device, rhs: Simulator.Device) -> Bool {

        return true
    }

    func sortRunTime(lhs: Simulator.Device, rhs: Simulator.Device) -> Bool {

        return true
    }

}
