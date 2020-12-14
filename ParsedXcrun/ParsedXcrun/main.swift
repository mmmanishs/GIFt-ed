//
//  main.swift
//  ParsedXcrun
//
//  Created by Manish Singh on 11/20/20.
//

import Foundation


func main() {

    let systemInfo = SystemInfo()
    systemInfo.allDevices.forEach {
        print($0.runTimeResolvedToNearestDecimalNumber)
    }


//    let rootPath = systemInfo.topMostBootedDevice
//    let apps = SandboxInspector(rootPath: rootPath).inspect()
//    print(apps[0].bundleIdentifier)

    dispatchMain()
}


main()


