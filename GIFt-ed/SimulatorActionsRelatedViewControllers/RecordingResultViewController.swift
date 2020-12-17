//
//  RecordingResultViewController.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/16/20.
//

import Cocoa

class RecordingResultViewController: NSViewController {
    private var viewModel: ViewModel!
    @IBOutlet weak var heading: NSTextField! {
        didSet {
            heading.stringValue = viewModel.deviceName
        }
    }

    @IBOutlet weak var moviePath: NSTextField! {
        didSet {
            moviePath.isHidden = viewModel.moviePath.isEmpty
            moviePath.stringValue = viewModel.moviePath
        }
    }

    @IBOutlet weak var gifPath: NSTextField! {
        didSet {
            gifPath.isHidden = viewModel.gifPath.isEmpty
            gifPath.stringValue = viewModel.gifPath
        }
    }

    @IBOutlet weak var buttonOutputFolder: NSButton! {
        didSet {
            buttonOutputFolder.set(text: viewModel.outputFolderPath, textColor: .systemBlue)
        }
    }

    @IBOutlet weak var buttonFinderMovie: NSButton! {
        didSet {
            buttonFinderMovie.isHidden = viewModel.moviePath.isEmpty
            buttonFinderMovie.set(text: "Finder", textColor: .systemBlue)
        }
    }

    @IBOutlet weak var buttonFinderGif: NSButton! {
        didSet {
            buttonFinderGif.isHidden = viewModel.gifPath.isEmpty
            buttonFinderGif.set(text: "Finder", textColor: .systemBlue)
        }
    }

    @IBOutlet weak var movieSize: NSTextField! {
        didSet {
            movieSize.stringValue = viewModel.movieSize
        }
    }
    @IBOutlet weak var gifSize: NSTextField! {
        didSet {
            gifSize.stringValue = viewModel.gifSize
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonOpenOutputFolderTapped(_ sender: Any) {
        viewModel.outputFolderPath.openFolder()
    }

    @IBAction func buttonFinderMovieTapped(_ sender: Any) {
        viewModel.moviePath.openFinderAndSelectFile()
    }

    @IBAction func buttonFinderGIFTapped(_ sender: Any) {
        viewModel.gifPath.openFinderAndSelectFile()
    }

    @IBAction func buttonCloseTapped(_ sender: Any) {
        MainPopover.shared.dismissPopover()
    }
}

extension RecordingResultViewController {
    struct ViewModel {
        let deviceName: String
        let moviePath: String
        let gifPath: String
        let outputFolderPath: String
        var movieSize: String {
            moviePath.humanReadableFileSize
        }
        var gifSize: String {
            gifPath.humanReadableFileSize
        }
    }

    static func viewController(deviceName: String, moviePath: String, gifPath: String, outputFolderPath: String) -> RecordingResultViewController {
        let vm = ViewModel(deviceName: deviceName, moviePath: moviePath, gifPath: gifPath, outputFolderPath: outputFolderPath)
        let vc = RecordingResultViewController(nibName: "RecordingResultViewController", bundle: nil)
        vc.viewModel = vm
        return vc
    }
}
