//
//  VideoToGifConverter.swift
//  GIFt-ed
//
//  Created by Singh, Manish on 9/17/20.
//  Copyright © 2020 Manish Singh. All rights reserved.
//

import Foundation

class VideoToGifConverter {
    private var ffmpeg_executable: String {
        return Bundle.main.path(forResource: "ffmpeg", ofType: nil)!
    }

    let moviePath: String
    let outputPath: String
    let giphyFps: Int
    let giphyScale: Int

    init(moviePath: String, giphyFps: Int, giphyScale: Int, outputPath: String? = nil) {
        self.moviePath = moviePath
        if let op = outputPath {
        self.outputPath = op
        } else {
            self.outputPath = moviePath.withFileTypeUpdatedTo(type: "gif")
        }
        self.giphyFps = giphyFps
        self.giphyScale = giphyScale
    }

    func convertToGif(completionHandler: (() -> ())? = nil) {
        /// https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/
        let exec = "\(ffmpeg_executable) -i \"\(moviePath)\" -filter_complex \"[0:v] fps=\(giphyFps),scale=\(giphyScale):-1,split [a][b];[a] palettegen [p];[b][p] paletteuse\" \"\(outputPath)\""
        FilePathManager().desktopExec.write(data: Data(exec.utf8))
        TimeExecution.start(description: "gif timer")
        _ = "sh \(FilePathManager().desktopExec)".runAsCommand() { process in
            TimeExecution.stop(description: "gif timer")
            completionHandler?()
        }
        FilePathManager().desktopExec.write(data: Data("temp-file-for-ios-sim-recorder".utf8))
    }
}

