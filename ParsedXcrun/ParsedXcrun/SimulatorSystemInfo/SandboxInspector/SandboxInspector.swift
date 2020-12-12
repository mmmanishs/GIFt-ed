//
//  SandboxInspector.swift
//  ParsedXcrun
//
//  Created by Manish Singh on 12/8/20.
//

import Foundation

class SandboxInspector {
    let rootPath: String

    init(rootPath: String) {
        self.rootPath = rootPath
    }

    func inspect() -> [SandboxApp] {
        guard let sandboxes = rootPath.foldersAtPath,
              !sandboxes.isEmpty else {
            return []
        }
        var sandboxApps = [SandboxApp]()
        for sandbox in sandboxes {
            let apps = sandbox.containedFiles(type: "app")
            if apps.count == 1 { /// We do not know what to make of sandbox containing multiple apps, sp skipping that for now
                let app = apps[0]
                let info_plists = app.containedFiles(name: "Info.plist")
                if info_plists.count == 1 { /// We do not know what to make of sandbox containing multiple plists, sp skipping that for now
                    let info_plist = info_plists[0]
                    if let sandboxApp = getSanboxApp(from: info_plist, rootPath: sandbox) {
                        sandboxApps.append(sandboxApp)
                    }
                }
            }
        }
        return sandboxApps
    }

    private func getSanboxApp(from plist: String, rootPath: String) -> SandboxApp? {
        let dict = NSDictionary(contentsOfFile: plist)!
        guard let name = dict["CFBundleName"] as? String,
              let bundleIdentifier = dict["CFBundleIdentifier"] as? String else {
            return nil
        }
        return SandboxApp(rootPath: rootPath, plistPath: plist, bundleIdentifier: bundleIdentifier, name: name, iconPath: nil)
    }
}

extension String {
    var foldersAtPath: [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: self) else {
            return nil
        }
        let fileManager = FileManager.default
        var output = [String]()
        for path in paths {
            let fullPath = (self as NSString).appendingPathComponent(path)
            var isDir: ObjCBool = ObjCBool(true)
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) && fullPath.fileType != "DS_Store" {
                output.append(fullPath)
            }
        }
        return output
    }

    func containedFiles(type: String) -> [String] {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: self) else {
            return []
        }
        let fileManager = FileManager.default
        var output = [String]()
        for path in paths {
            let fullPath = (self as NSString).appendingPathComponent(path)
            var isDir: ObjCBool = ObjCBool(false)
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir),
               let fileType = fullPath.fileType,
               fileType == type {
                output.append(fullPath)
            }
        }
        return output
    }

    func containedFiles(name: String) -> [String] {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: self) else {
            return []
        }
        let fileManager = FileManager.default
        var output = [String]()
        for path in paths {
            let fullPath = (self as NSString).appendingPathComponent(path)
            var isDir: ObjCBool = ObjCBool(false)
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir),
               let filName = fullPath.fileName,
               filName == name {
                output.append(fullPath)
            }
        }
        return output
    }

    var fileType: String? {
        return components(separatedBy: ".").last
    }

    var fileName: String? {
        return components(separatedBy: "/").last
    }

}

struct SandboxApp: Codable, Equatable {
    let rootPath: String
    let plistPath: String
    let bundleIdentifier: String
    let name: String
    let iconPath: String?
}

func undefined<T>()-> T {
    return assertionFailure("Please define") as! T
}
