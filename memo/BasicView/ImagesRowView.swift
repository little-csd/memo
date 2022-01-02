//
//  ImagesRowView.swift
//  memo
//
//  Created by stevecai on 2021/12/25.
//

import SwiftUI

struct ImagesRowView: View {
    
    @Binding var currentImageIDs: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(0..<currentImageIDs.count, id: \.self) { idx in
                    ZStack(alignment: .topTrailing) {
                        ImageWithPreview(image: UIImage(uuid: currentImageIDs[idx]))
                        Button {
                            currentImageIDs.remove(at: idx)
                        } label: {
                            Image("RemoveImage")
                                .padding(.edge(top: 4, trailing: 4))
                        }
                    }
                }
            }
        }.padding(.edge(leading: 24, bottom: 18, trailing: 24))
    }
}
