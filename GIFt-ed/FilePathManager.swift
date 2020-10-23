//
//  FilePathManager.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/17/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class FilePathManager {
    var preferences: UserPreferences {
        UserPreferences.retriveFromDisk()
    }

    var desktopExec: String {
        let path = "\(DiskPath.desktop)/.isr.sh"
        return path
    }
    /// Handle error if folder does not exists
    func outputSavePath(for simulator: Simulator.Device) -> String {
        let d = simulator
        var outputDirectory = ""
        if preferences.organizeOutputByDate {
            outputDirectory = createFolderByTodaysDateIfItDoesNotExists(at: preferences.outputFolderPath) ?? preferences.outputFolderPath
        } else {
            outputDirectory = preferences.outputFolderPath
        }

        let filename = "\(d.name) [\(Date.currenttimeStampAndDateString)]"
        let path = "\(outputDirectory)/\(filename).mov"

        let pathMinusSpaces = path.replacingOccurrences(of: " ", with: "_")
        return pathMinusSpaces
    }

    private func createFolderByTodaysDateIfItDoesNotExists(at outputPath: String) -> String? {
        let createPath = "\(outputPath)/\(Date.currentDateString)"
        do {
            try FileManager.default.createDirectory(atPath: createPath, withIntermediateDirectories: true, attributes: nil)
            return createPath
        }
        catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
        return nil
    }
}

enum DiskPath {
    static var desktop: String {
        return (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
    }

    static var bundle: String {
        return Bundle.main.resourcePath!
    }
}

extension Date {
    static var currenttimeStampAndDateString: String {
        let calanderDate = Calendar.current.dateComponents([.day, .year, .month, .hour, .second, .minute], from: Date())
        let monthName = String(Array(Array(DateFormatter().monthSymbols[calanderDate.month! - 1])[0...2]))
        let dateString = "(\(calanderDate.hour!).\(calanderDate.minute!).\(calanderDate.second!)),(\(monthName)-\(calanderDate.day!))"
        return dateString
    }

    static var currentDateString: String {
        let calanderDate = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        let monthName = String(Array(Array(DateFormatter().monthSymbols[calanderDate.month! - 1])[0...2]))
        let dateString = "\(monthName)-\(calanderDate.day!)-\(calanderDate.year!)"
        return dateString
    }
}

extension String {
    var doesFolderExistsAtThisPath: Bool {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: cleanedLastBackSlashInPath, isDirectory: &isDir)
    }

    var doesFileExistsAtThisPath: Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: cleanedLastBackSlashInPath, isDirectory: &isDir)
    }

    func getPathToSave(toType type: String) -> String {
        var newPath = self.stripFileExtension
        var counter = 1
        while "\(newPath).\(type)".doesFileExistsAtThisPath {
            newPath = "\(newPath)-\(counter)"
            counter += 1
        }
        return "\(newPath).\(type)"
    }


    func createFolder() -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: cleanedLastBackSlashInPath, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }

    func tryToCreateFolderIfItDoesNotAlreadyExist() {
        if !doesFolderExistsAtThisPath {
            _ = createFolder()
        }
    }
    
    var cleanedLastBackSlashInPath: String {
        var a = Array(self)
        if a.last == #"/"# {
            a.removeLast()
        }
        return String(a)
    }
}

extension String {
    func write(data: Data) {
        let filePathUrl = URL(string: "file://" + self)!
        try? data.write(to: filePathUrl)
    }

    func withFileTypeUpdatedTo(type: String) -> String {
        let path = stripFileExtension
        return "\(path).\(type)"
    }

    var stripFileExtension: String {
        var components = self.components(separatedBy: ".")
        guard components.count > 1 else { return self }
        components.removeLast()
        return components.joined(separator: ".")
    }
}

extension String {
    var humanReadableFileSizeFromBash: String {
        let size = "du -sh '\(self)' | cut -f1".runAsCommand()
        return size
    }

    var humanReadableFileSize: String {
        let size = Double(fileSize)
        switch true {
        case size < 1024.0:
            return "\(size) bytes"
        case size > 1024.0 && size < (1024.0 * 1024.0):
            return "\((size / 1024.0).roundToPlaces(2)) KB(s)"
        case size > (1024.0 * 1024.0) && size < (1024.0 * 1024.0 * 1024):
            return "\((size / (1024.0 * 1024.0)).roundToPlaces(2)) MB(s)"
        default:
            return "too large"
        }
    }

    var fileSize: UInt64 {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: self)
            return attr[FileAttributeKey.size] as! UInt64
        } catch {
            print("Error: \(error)")
        }
        return 0
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
