//
//  LabelView.swift
//  memo
//
//  Created by stevecai on 2021/12/25.
//

import SwiftUI

struct LabelView: View {
    
    @Binding var selected: Bool
    @Binding var selectedLabel: String
    @Binding var currentLabels: [String]
    @ObservedObject var limitedTextViewCoord: LimitedTextViewCoord
    
    var body: some View {
        HStack (spacing: 8) {
            ForEach(currentLabels, id: \.self) { label in
                Button {
                    selected = true
                    selectedLabel = label
                    limitedTextViewCoord.text = label
                } label: {
                    Text("#\(label)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue96)
                        .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Color.grey97)
                        .cornerRadius(CORNER_RADIUS)
                }
            }
            if (currentLabels.count < 2) {
                Button {
                    selected = true
                    selectedLabel = ""
                    limitedTextViewCoord.text = ""
                } label: {
                    Group {
                        if (currentLabels.count > 0) {
                            Image(systemName: "plus")
                                .frame(width: 8, height: 8)
                                .padding(.all, 8)
                        }
                        if (currentLabels.count == 0) {
                            Text("#点击添加")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue96)
                                .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                    .background(Color.grey97)
                    .cornerRadius(CORNER_RADIUS)
                }
            }
        }
    }
}
