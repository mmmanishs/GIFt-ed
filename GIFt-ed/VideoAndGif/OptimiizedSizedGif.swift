//
//  OptimumSizedGif.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/28/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class OptimiizedSizedGif {
    enum Peg {
        case fps(Int)
        case scale(Int)
    }
    let targetSize: Int
    let peg: Peg

    init(targetSize: Int, peg: Peg) {
        self.targetSize = targetSize
        self.peg = peg
    }

    func start() {
        switch peg {
        case .fps(let f):
            optimizeForConstantFps(for: f)
        case .scale(let _): break
//            optimizeScale(for: s)
        }
    }

    private func optimizeForConstantFps(for fps: Int) {

    }

    private func optimizeForConstantScale(for scale: Int) {
        
    }
}
