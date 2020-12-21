//
//  RecordingResultViewController.swift
//  GIFt-ed
//
//  Created by Manish Singh on 12/16/20.
//

import Cocoa
// Open in new window feature
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

    @IBOutlet weak var buttonOpenInAWindow: NSButton! {
        didSet {
            buttonOpenInAWindow.set(text: buttonOpenInAWindow.title, textColor: .systemBlue)
            buttonOpenInAWindow.isHidden = viewModel.isShowingInAWindow
        }
    }

    @IBOutlet weak var buttonClose: NSButton! {
        didSet {
            buttonClose.set(text: buttonClose.title, textColor: .systemBlue)
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


    @IBOutlet weak var buttonQuickLookMovie: NSButton! {
        didSet {
            buttonQuickLookMovie.isHidden = viewModel.moviePath.isEmpty
            buttonQuickLookMovie.set(text: "Quick Look", textColor: .systemBlue)
        }
    }

    @IBOutlet weak var buttonQuickLookGif: NSButton! {
        didSet {
            buttonQuickLookGif.isHidden = viewModel.gifPath.isEmpty
            buttonQuickLookGif.set(text: "Quick Look", textColor: .systemBlue)
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
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
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

    @IBAction func buttonQuickLookMovieTapped(_ sender: Any) {
        DispatchQueue.global().async {
            _ = "qlmanage -p '\(self.viewModel.moviePath)'".runAsCommand()
        }
    }

    @IBAction func buttonQuickLookGIFTapped(_ sender: Any) {
        DispatchQueue.global().async {
            _ = "qlmanage -p '\(self.viewModel.gifPath)'".runAsCommand()
        }
    }

    @IBAction func buttonOpenInAWindowTapped(_ sender: Any) {
        self.presentAsModalWindow(self)
        MainPopover.shared.dismissPopover()
        view.window?.title = "\(viewModel.deviceName) video capture results.."
        buttonOpenInAWindow.isHidden = true
        buttonClose.isHidden = true
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
        var isShowingInAWindow = false
    }

    static func viewController(deviceName: String, moviePath: String, gifPath: String, outputFolderPath: String) -> RecordingResultViewController {
        let vm = ViewModel(deviceName: deviceName, moviePath: moviePath, gifPath: gifPath, outputFolderPath: outputFolderPath)
        let vc = RecordingResultViewController(nibName: "RecordingResultViewController", bundle: nil)
        vc.viewModel = vm
        return vc
    }
}
