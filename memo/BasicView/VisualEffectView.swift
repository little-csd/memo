//
//  VisualEffectView.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    
    var color: UIColor?
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
        if (color != nil) {
            uiView.backgroundColor = color
        }
    }
}
