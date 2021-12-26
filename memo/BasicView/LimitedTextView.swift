//
//  LimitedTextView.swift
//  memo
//
//  Created by stevecai on 2021/12/4.
//

import SwiftUI
import SwiftUIX

fileprivate func createHint(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFont(ofSize: 15)
    label.textColor = Color.grey80.toUIColor()
    return label
}

struct LimitedTextView: UIViewRepresentable {
    
    @Binding var isFocused: Bool
    @StateObject var coordinator: LimitedTextViewCoord
    
    func makeCoordinator() -> LimitedTextViewCoord {
        return coordinator
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView(frame: .zero)
        
        view.backgroundColor = Color.grey97.toUIColor()
        view.font = UIFont.systemFont(ofSize: 15)
        
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets.zero
        view.textColor = Color.black01.toUIColor()
        view.delegate = context.coordinator
        view.text = context.coordinator.text
        
        let label = context.coordinator.hint
        label.sizeToFit()
        label.frame = CGRect(x: 3, y: 0, width: label.frame.width, height: label.frame.height)
        if (view.text.isEmpty) {
            view.addSubview(label)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if (isFocused && !uiView.isFirstResponder) {
//            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
//            }
        } else if (!isFocused && uiView.isFirstResponder) {
//            DispatchQueue.main.async {
                uiView.resignFirstResponder()
//            }
        }
        if (uiView.text != context.coordinator.text) {
            uiView.text = context.coordinator.text
        }
    }
}

class LimitedTextViewCoord: NSObject, UITextViewDelegate, ObservableObject {
    
    @Published var text: String = "" {
        didSet {
            if (!text.isEmpty) {
                hint.removeFromSuperview()
            }
        }
    }
    let hint = createHint("输入名称")
    
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
        print("text view text changed to \(text)")
        if (text.isEmpty) {
            textView.addSubview(hint)
        }
    }
}
