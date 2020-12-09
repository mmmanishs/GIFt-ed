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
    print(rootPath)
    rootPath.openFolder()

    print(rootPath.foldersAtPath)

    dispatchMain()
}


main()


struct SandboxApp {
    let rootPath: String
    let name: String
}
