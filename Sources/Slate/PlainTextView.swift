import SwiftUI
import AppKit

/// NSTextView wrapper: plain text only, no smart substitutions, native find bar and undo.
struct PlainTextView: NSViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var wrap: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        let tv = scroll.documentView as! NSTextView
        tv.delegate = context.coordinator
        tv.isRichText = false
        tv.importsGraphics = false
        tv.allowsUndo = true
        tv.usesFindBar = true
        tv.isIncrementalSearchingEnabled = true
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticDashSubstitutionEnabled = false
        tv.isAutomaticTextReplacementEnabled = false
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isAutomaticLinkDetectionEnabled = false
        tv.isContinuousSpellCheckingEnabled = false
        tv.textColor = .textColor
        tv.backgroundColor = .textBackgroundColor
        tv.insertionPointColor = .textColor
        tv.textContainerInset = NSSize(width: 10, height: 10)
        tv.string = text
        apply(fontSize: fontSize, wrap: wrap, to: scroll)
        DispatchQueue.main.async { tv.window?.makeFirstResponder(tv) }
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        context.coordinator.parent = self
        let tv = scroll.documentView as! NSTextView
        if tv.string != text { tv.string = text }
        apply(fontSize: fontSize, wrap: wrap, to: scroll)
    }

    private func apply(fontSize: CGFloat, wrap: Bool, to scroll: NSScrollView) {
        let tv = scroll.documentView as! NSTextView
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        if tv.font != font { tv.font = font }

        scroll.hasHorizontalScroller = !wrap
        tv.isHorizontallyResizable = !wrap
        tv.textContainer?.widthTracksTextView = wrap
        if wrap {
            tv.textContainer?.size.width = scroll.contentSize.width
        } else {
            tv.textContainer?.size = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                            height: CGFloat.greatestFiniteMagnitude)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PlainTextView
        init(_ parent: PlainTextView) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            if parent.text != tv.string { parent.text = tv.string }
        }
    }
}
