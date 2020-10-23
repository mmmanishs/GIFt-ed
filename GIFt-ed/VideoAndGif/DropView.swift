import Cocoa

class DropView: NSView {

    var filePath: String?
    var expectedExt: [String] = []  //file extensions allowed for Drag&Drop (example: "jpg","png","docx", etc..)
    var fileDropppedHandler: (([String]) -> ())? /// Use this to get the dropped files
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor

        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }

    func setAcceptableFileExtensions(extensions: [String]) {
        self.expectedExt = extensions
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

        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.expectedExt {
            if ext.lowercased() == suffix {
                return true
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
