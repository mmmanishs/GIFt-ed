//
//  MenuDescriptor.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/1/20.
//

import Foundation

struct MenuDescriptor: Codable {
    static var writeToDesktop = false
    static var stopRecordingIsEnabled = false
    var items: [Item]
    // MARK: - Item
    struct Item: Codable, Equatable {
        let element: Element
        var isEnabled: Bool

        // MARK: - Element
        struct Element: Codable, Equatable {
            let key, params: String
            var approvedKey: ApprovedKey {
                return ApprovedKey(rawValue: key) ?? .unknown
            }
            enum CodingKeys: String, CodingKey {
                case key, params
            }
            // should be unique
            enum ApprovedKey: String {
                case cacheFrequentlyAccessedDevices = "cache-recently-accessed-devices"
                case convertGifToVideo = "convert-gif-to-video"
                case divider = "divider"
                case simulators = "list-of-simulators"
                case stopVideoCature = "stop-video-cature"
                case startVideoCature = "start-video-cature"
                case videoCaptureSettings = "video-Capture-Settings"
                case quit = "quit"
                case unknown
            }
        }
    }

    func printAllKeys() {
        items.forEach {
            print($0.element.key)
        }
    }
}

extension MenuDescriptor: CustomStringConvertible {
    var description: String {
        return "recording: \(getFirstItem(for: .startVideoCature)?.isEnabled), stop recording: \(getFirstItem(for: .stopVideoCature)?.isEnabled)"
    }
}

extension MenuDescriptor {
    func getFirstItem(for key: Item.Element.ApprovedKey) -> Item? {
        items.filter {
            $0.element.approvedKey == key
        }.first
    }

    func getItems(for key: Item.Element.ApprovedKey) -> [Item] {
        items.filter {
            $0.element.approvedKey == key
        }
    }

    mutating func update(item: Item) -> MenuDescriptor {
        if let index = items.firstIndex(where: {$0.element.approvedKey == item.element.approvedKey}) {
            items[index] = item
        }
        return self
    }
}

extension MenuDescriptor {
    static func load(overridePersistedState: Bool = false)-> MenuDescriptor {
        var jsonData: Data
        if !overridePersistedState,
           let preferencesData = UserDefaults.standard.data(forKey: "menu-descriptor") {
            jsonData = preferencesData
        } else {
            /// This data has to be there, or else the app crahes
            jsonData = try! Data.init(contentsOf: Bundle.main.url(forResource: "menu-descriptor-origins", withExtension: "json")!)
        }
        let menuDescriptor = try! JSONDecoder().decode(MenuDescriptor.self, from: jsonData)
        return menuDescriptor
    }

    static func delete() {
        UserDefaults.standard.removeObject(forKey: "menu-descriptor")
    }

    func persistToDisk() {
        do {
            let encoded = try JSONEncoder().encode(self)
            UserDefaults.standard.setValue(encoded, forKey: "menu-descriptor")
            "/Users/manishsingh/Desktop/user-pref.log".write(data: encoded)
        } catch let e {
            print(e)
        }
    }
}
