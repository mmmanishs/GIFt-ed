//
//  Simulator.swift
//  ParsedXcrun
//
//  Created by Manish Singh on 11/20/20.
//

import Foundation

// MARK: - SimulatorEnvironment
struct Simulator: Codable {
    let devices: [String: [Device]] /// Key value type

    // MARK: - Device
    struct Device: Codable {
        let availabilityError: String?
        let dataPath, logPath, udid: String
        let isAvailable: Bool
        let deviceTypeIdentifier: String?
        let state: State
        let name: String

        var nameNoSpaces: String {
            name.replacingOccurrences(of: " ", with: "_")
        }

        var nameAndRuntime: String {
            return "\(name) (\(runTimePretty))"
        }

        var nameAndRuntimeNoSpaces: String {
            return "\(nameNoSpaces)_\(runTimePrettyNoSpaces)"
        }
        /// Extra added properties
        var runTime: String! = ""
        var runTimePretty: String {
            Simulator.prettyRuntime(from: runTime)
        }
        var runTimePrettyNoSpaces: String {
            Simulator.prettyRuntimeNoSpaces(from: runTime)
        }
        var family: Family {
            return Family(name)
        }

        enum State: String, Codable {
            case booted = "Booted"
            case booting = "Booting"
            case creating = "Creating"
            case shutdown = "Shutdown"
            case shutingDown = "Shutting Down"
        }
    }
}

extension Simulator.Device {
    enum Appearence: String {
        case light = "light\n",
             dark = "dark\n",
             unknown
    }

    func fetchAppearence(completion: @escaping (Appearence) ->()) {
        DispatchQueue.global().async {
            completion(Appearence(rawValue: "xcrun simctl ui \(udid) appearance".runAsCommand()) ?? .unknown)
        }
    }
}

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
}

extension Simulator.Device {
    enum Family: Int, CustomStringConvertible {
        var description: String {
            switch self {
            case .iPhone:
                return "iPhone"
            case .iPad:
                return "iPad"
            case .appleWatch:
                return "appleWatch"
            case .appleTv:
                return "appleTv"
            case .others:
                return "others"
            }
        }

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

extension Simulator {
    static func prettyRuntime(from runTime: String) -> String {
        let pretty1 = runTime.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
        var array = Array(pretty1)
        if let firstOccurence = array.firstIndex(of: "-") {
            array.remove(at: firstOccurence)
            array.insert(" ", at: firstOccurence)
        }
        let pretty2 = String(array)
        let pretty3 = pretty2.replacingOccurrences(of: "-", with: ".")
        return pretty3
    }

    static func prettyRuntimeNoSpaces(from runTime: String) -> String {
        let pretty1 = runTime.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
        var array = Array(pretty1)
        if let firstOccurence = array.firstIndex(of: "-") {
            array.remove(at: firstOccurence)
            array.insert("_", at: firstOccurence)
        }
        let pretty2 = String(array)
        let pretty3 = pretty2.replacingOccurrences(of: "-", with: "_")
        return pretty3
    }
}
