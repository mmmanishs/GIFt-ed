//
//  TimeExecution.swift
//  etools
//
//  Created by Singh, Manish on 1/13/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class TimeExecution {
    static var startTime: CFAbsoluteTime = CFAbsoluteTime(floatLiteral: 0.0)
    static func timeExecution(description: String, code: () -> ()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        code()
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        print("\(description) (time taken): \(elapsedTime) seconds")
    }

    static func start(description: String) {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    static func stop(description: String) -> Double {
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        return elapsedTime
    }
}
