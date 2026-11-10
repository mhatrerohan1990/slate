import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct EditorView: View {
    @Binding var text: String
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("wordWrap") private var wordWrap = true
    @AppStorage("appearance") private var appearance = Appearance.system.rawValue

    var body: some View {
        PlainTextView(text: $text, fontSize: fontSize, wrap: wordWrap)
            .frame(minWidth: 320, minHeight: 200)
            .preferredColorScheme((Appearance(rawValue: appearance) ?? .system).scheme)
    }
}

@main
struct SlateApp: App {
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("wordWrap") private var wordWrap = true
    @AppStorage("appearance") private var appearance = Appearance.system.rawValue

    var body: some Scene {
        DocumentGroup(newDocument: TextDoc()) { file in
            EditorView(text: file.$document.text)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Button("Save As…") {
                    NSApp.sendAction(#selector(NSDocument.saveAs(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .printItem) {
                Button("Print…") {
                    NSApp.sendAction(#selector(NSView.printView(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("p", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { Text($0.label).tag($0.rawValue) }
                }
                Toggle("Word Wrap", isOn: $wordWrap)
                Divider()
                Button("Bigger") { fontSize = min(fontSize + 1, 72) }
                    .keyboardShortcut("+", modifiers: .command)
                Button("Smaller") { fontSize = max(fontSize - 1, 8) }
                    .keyboardShortcut("-", modifiers: .command)
                Button("Actual Size") { fontSize = 14 }
                    .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}
