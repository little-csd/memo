//
//  ImageWithPreview.swift
//  memo
//
//  Created by stevecai on 2021/12/6.
//

import SwiftUI

struct ImageWithPreview: View {
    
    let image: UIImage?
    @State var isClicked = false
    
    var body: some View {
        if (image != nil) {
            Button {
                isClicked = true
            } label: {
                Image(uiImage: image!)
                    .centerCropped()
                    .frame(width: IMAGE_SIZE, height: IMAGE_SIZE)
                    .fullScreenCover(isPresented: $isClicked) {
                    } content: {
                        ZStack {
                            Color.black01.ignoresSafeArea()
                            Image(uiImage: image!)
                                .resizable()
                                .scaledToFit()
                        }.onTapGesture {
                            isClicked = false
                        }
                    }
            }
        }
        if (image == nil) {
            Image("EditorImg")
                .centerCropped()
                .frame(width: IMAGE_SIZE, height: IMAGE_SIZE)
        }
    }
}
