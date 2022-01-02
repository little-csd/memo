//
//  RecordView.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

struct RecordView: View {
    
    @EnvironmentObject var memoViewModel: MemoViewModel
    
    @State var isExpandLabels = false
    @State var selectedLabel = "所有标签"
    @Binding var popupSheet: Bool
    @Binding var referer: MemoReferer?
    
    var bottomOffset: CGFloat
    
    var topIconView: some View {
        HStack {
            Button {
                print("tap menu")
            } label: {
                Image("MenuMain").frame(width: 30, height: 30).padding(.all, 10)
            }
            Spacer()
            Button {
                print("tap search")
            } label: {
                Image("MenuSearch").frame(width: 30, height: 30).padding(.all, 10)
            }
        }
    }
    
    @ViewBuilder
    func labelItemBuilder(txt: String) -> some View {
        Text(txt == "所有标签" ? txt : "#\(txt)")
            .font(.system(size: 15, weight: selectedLabel == txt ? .bold : .regular, design: .default))
            .foregroundColor(selectedLabel == txt ? .white : .grey58).fixedSize()
            .padding(.init(top: 7.5, leading: 12, bottom: 7.5, trailing: 12))
            .background(selectedLabel == txt ? Color.blue96 : Color.grey97)
            .cornerRadius(CORNER_RADIUS)
            .onTapGesture {
                selectedLabel = txt
            }
    }
    
    var labelsView: some View {
        HStack(alignment: .top, spacing: 0) {
            FlexView(data: memoViewModel.tags, spacing: 12.0, alignment: .leading, isExpand: $isExpandLabels, content: labelItemBuilder)
            Button {
                self.isExpandLabels = !self.isExpandLabels
            } label: {
                if self.isExpandLabels {
                    Image("Unexpand")
                } else {
                    Image("Expand")
                }
            }
        }
        .padding(.init(top: 12, leading: 18, bottom: 11, trailing: 6))
        .background(Color.white)
        .cornerRadius(CORNER_RADIUS)
        .padding(.bottom, 16)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topIconView
            labelsView
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(memoViewModel.getFilteredChains(target: selectedLabel)) { chain in
                        MemoChainView(chain: chain, popupSheet: $popupSheet, referer: $referer)
                    }
                }
                Spacer(minLength: bottomOffset)
            }
        }
        .padding(.edge(top: 40, leading: 8, trailing: 8))
    }
}
