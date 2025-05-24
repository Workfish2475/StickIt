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
    
    @AppStorage("textColor") private var textColor: TextColor = .system
    @Environment(\.colorScheme) private var scheme
    
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var selectedRange: NSRange
    @Binding var calculatedHeight: CGFloat
    var color: Color
    
    var inputAccessoryView: UIView?
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
        
        textView.inputAccessoryView = inputAccessoryView
        
        
        if textColor == .system {
            if scheme == .dark {
                textView.textColor = .white
            } else {
                textView.textColor = .black
            }
        } else {
            textView.textColor = UIColor(textColor.color)
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
        
        textView.inputAccessoryView?.backgroundColor = UIColor(color).withAlphaComponent(0.7)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, selection: $selectedRange, height: $calculatedHeight, onDone: onDone)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height
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
    private var keyboardToolbar: AnyView?

    @Binding private var text: String
    @Binding private var selectedRange: NSRange
    private var color: Color
    
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 500
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "", text: Binding<String>, selectedRange: Binding<NSRange>, onCommit: (() -> Void)? = nil, keyboardToolbar: AnyView? = nil, color: Color) {
        self.placeholder = placeholder
        self._text = text
        self._selectedRange = selectedRange
        self.onCommit = onCommit
        self.color = color
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        self.keyboardToolbar = keyboardToolbar
        
    }

    var body: some View {
        UITextViewWrapper(
            text: self.internalText,
            selectedRange: $selectedRange,
            calculatedHeight: $dynamicHeight,
            color: color,
            inputAccessoryView: keyboardToolbar.map {
                let hosting = UIHostingController(rootView: $0)
                hosting.view.translatesAutoresizingMaskIntoConstraints = false
                hosting.view.heightAnchor.constraint(equalToConstant: 44).isActive = true
                return hosting.view
            },
            onDone: onCommit
        )
        .frame(minHeight: dynamicHeight, maxHeight: .infinity)
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

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
