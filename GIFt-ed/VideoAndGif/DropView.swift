import Cocoa

class DropView: NSView {
    enum FileType {
        case folder
        case fileExtension([String])
    }

    var filePath: String?
    var fileType: FileType = .fileExtension([])  //file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)
    var fileDropppedHandler: (([String]) -> ())? /// Use this to get the dropped files
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }

    func setAcceptableFileExtensions(fileType: FileType) {
        self.fileType = fileType
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) {
            self.layer?.backgroundColor = NSColor.green.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }

    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String
        else { return false }
        switch fileType {
        case .folder:
            break
        case .fileExtension(let expectedExt):
            let suffix = URL(fileURLWithPath: path).pathExtension
            for ext in expectedExt {
                if ext.lowercased() == suffix {
                    return true
                }
            }
        }
        return false
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let paths = pasteboard as? [String]
        else { return false }
        fileDropppedHandler?(paths)
        return true
    }
}
