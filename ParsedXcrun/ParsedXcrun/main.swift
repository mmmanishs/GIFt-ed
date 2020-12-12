//
//  main.swift
//  ParsedXcrun
//
//  Created by Manish Singh on 11/20/20.
//

import Foundation


func main() {

    let systemInfo = SystemInfo()

    let rootPath = systemInfo.topMostBootedDevice!.appsSandboxRootPath


    let apps = SandboxInspector(rootPath: rootPath).inspect()

    print(apps[0].bundleIdentifier)

    dispatchMain()
}


main()


