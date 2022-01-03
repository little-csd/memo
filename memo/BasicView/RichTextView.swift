//
//  RichTextView.swift
//  memo
//
//  Created by stevecai on 2021/12/4.
//

import SwiftUI

fileprivate let normalFont = UIFont.systemFont(ofSize: 16)
fileprivate let boldFont = UIFont.boldSystemFont(ofSize: 16)
fileprivate let normalColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)

struct RichTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @ObservedObject var coordinator: RichTextViewCoordinator
    @Binding var showKeyboard: Bool
    let enableKeyboardControl: Bool
    
    init(coordinator: RichTextViewCoordinator) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
        _showKeyboard = Binding(get: {
            false
        }, set: { v in            
        })
        enableKeyboardControl = false
    }
    
    init(coordinator: RichTextViewCoordinator, showKeyboard: Binding<Bool>) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
        _showKeyboard = showKeyboard
        enableKeyboardControl = true
    }
    
    func makeCoordinator() -> RichTextViewCoordinator {
        coordinator
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        
        view.font = normalFont
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets.zero
        view.delegate = context.coordinator
        view.attributedText = context.coordinator.data
        context.coordinator.view = view
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if enableKeyboardControl && showKeyboard != uiView.isFirstResponder {
            if (showKeyboard) {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }
        coordinator.updateView(uiView)
    }
}

class RichTextViewCoordinator: NSObject, UITextViewDelegate, ObservableObject {
    
    @Published private(set) var isTextEmpty = true
    @Published private(set) var isBold = false
    
    private(set) var data: NSAttributedString = .init(string: "")
    weak var view: UITextView?
    
    override init() {
    }
    
    init(data: NSAttributedString) {
        self.data = data
        isTextEmpty = data.string.isEmpty
        // TODO: fix font
    }
    
    private func textViewIsBold(_ textView: UITextView) -> Bool {
        return textView.font?.fontName.contains("bold") ?? false
    }
    
    func clickBoldFont() {
        isBold = !isBold
    }
    
    func closeKeyboard() {
        if let view = view {
            if (view.isFirstResponder) {
                view.resignFirstResponder()
            }
        }
    }
    
    func updateData(data: NSAttributedString) {
        if let view = view {
            view.attributedText = data
            isTextEmpty = data.string.isEmpty
            self.data = data
        }
    }
    
    fileprivate func updateView(_ textView: UITextView) {
        let range = textView.selectedRange
        if (range.length > 0) {
            let curIsBold = textViewIsBold(textView)
            if (curIsBold != isBold) {
                let s = textView.attributedText.mutableCopy() as! NSMutableAttributedString
                s.addAttribute(.font, value: isBold ? boldFont : normalFont, range: range)
                textView.attributedText = s
                textView.selectedRange = NSRange.init(location: range.location + range.length, length: 0)
            }
            data = textView.attributedText
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let curIsBold = textViewIsBold(textView)
        if (curIsBold != isBold) {
            let s = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            s.insert(text.withAttributed(font: isBold ? boldFont : normalFont, color: normalColor), at: range.location)
            textView.attributedText = s
            textView.selectedRange = NSRange.init(location: range.location + text.count, length: 0)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.isEmpty != isTextEmpty) {
            isTextEmpty = !isTextEmpty
        }
        isBold = textViewIsBold(textView)
        data = textView.attributedText.copy() as! NSAttributedString
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        isBold = textViewIsBold(textView)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        print("should begin editing")
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("did begin editing")
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        print("should end editing")
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
//        print("did end editing")
    }
}
