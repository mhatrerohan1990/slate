import SwiftUI
import UniformTypeIdentifiers

/// A plain-text document. Always UTF-8 on save; falls back to Latin-1 on open.
struct TextDoc: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .text] }
    static var writableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        if let s = String(data: data, encoding: .utf8) {
            text = s
        } else if let s = String(data: data, encoding: .isoLatin1) {
            text = s
        } else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
