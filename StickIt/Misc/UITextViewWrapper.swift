//
//  UITextViewWrapper.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/25/25.
//
// This is so I can determine where to inject new text. This may not be needed.
// See https://stackoverflow.com/questions/71367100/how-do-i-get-the-position-of-the-cursor-of-texteditor-in-swiftui for more.

import UIKit
import SwiftUI

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var selectedRange: NSRange
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator

        textView.isEditable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        if nil != onDone {
            textView.returnKeyType = .done
        }

        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if textView.text != self.text {
            textView.text = self.text
        }
        if textView.selectedRange != selectedRange {
            textView.selectedRange = selectedRange
        }
        if textView.window != nil, !textView.isFirstResponder {
            textView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, selection: $selectedRange, height: $calculatedHeight, onDone: onDone)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var selection: Binding<NSRange>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
    
        init(text: Binding<String>,selection: Binding<NSRange>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.selection = selection
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            UITextViewWrapper.recalculateHeight(view: textView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    
        func textViewDidChangeSelection(_ textView: UITextView) {
            selection.wrappedValue = textView.selectedRange
        }
    
    }
}

struct UIKitTextView: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    @Binding private var selectedRange: NSRange

    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "", text: Binding<String>, selectedRange: Binding<NSRange>, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._selectedRange = selectedRange
        self.onCommit = onCommit
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, selectedRange: $selectedRange, calculatedHeight: $dynamicHeight)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}
