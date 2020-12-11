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


    print(SandboxInspector(rootPath: rootPath).inspect().count)

    dispatchMain()
}


main()


struct SandboxApp {
    let rootPath: String
    let name: String
}
