//
//  BottomSheet.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

struct BottomSheetModifier<Child>: AnimatableModifier
    where Child: View {
    
    @Binding var enableModifier: Bool
    var sheetBuilder: () -> Child
    
    var offsetY: CGFloat = 0
    var animatableData: CGFloat {
        get { offsetY }
        set { offsetY = newValue }
    }
    let maxOffsetHeight = UIScreen.main.bounds.height
    
    init(enable: Binding<Bool>, sheet: @escaping () -> Child) {
        _enableModifier = enable
        sheetBuilder = sheet
        offsetY = enable.wrappedValue ? 0 : maxOffsetHeight
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content.disabled(enableModifier)
            if (offsetY != maxOffsetHeight) {
                Color.black.opacity(0.36).onTapGesture {
                    withAnimation {
                        enableModifier = false
                    }
                }.ignoresSafeArea()
                sheetBuilder()
                    .offset(y: offsetY)
                    .zIndex(1)
//                VStack(spacing: 12) {
//                    Color.grey92.frame(width: 36, height: 6)
//                        .cornerRadius(CORNER_RADIUS)
//                        .padding(.top, 8)
//                    sheetBuilder()
//                }.background(Color.white)
//                .cornerRadius(CORNER_RADIUS, corners: [.topLeft, .topRight])
//                .offset(y: offsetY)
//                .zIndex(1)
            }
        }
    }
}

extension View {
    func bottomSheet<Content>(_ enableModifier: Binding<Bool>, @ViewBuilder sheet: @escaping () -> Content) -> some View
    where Content: View {
        self.modifier(BottomSheetModifier(enable: enableModifier, sheet: sheet))
    }
}
