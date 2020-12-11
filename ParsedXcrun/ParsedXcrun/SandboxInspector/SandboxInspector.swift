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

        print(rootPath.foldersAtPath)
        return []
    }
}

extension String {
    var foldersAtPath: [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: self) else { return nil}

        let fileManager = FileManager.default
        var output = [String]()
        for path in paths {
            let fullPath = (self as NSString).appendingPathComponent(path)
            var isDir: ObjCBool = ObjCBool(false)
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) {
                output.append(fullPath)
            }
        }
        return output
    }
}

