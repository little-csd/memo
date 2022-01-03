//
//  LabelCreateView.swift
//  memo
//
//  Created by stevecai on 2021/12/25.
//

import SwiftUI

struct LabelCreateView: View {
    
    @Binding var showKeyboard: Bool
    
    @Binding var selectedLabel: String
    @Binding var currentLabels: [String]

    @ObservedObject var limitedTextViewCoord: LimitedTextViewCoord
    @ObservedObject var tagViewModel: TagViewModel
    
    private func onComplete() {
        if (limitedTextViewCoord.text.count > 10) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        } else {
            let tag = limitedTextViewCoord.text
            // 标签使用了不允许的名字或者新建了空的标签，给出警告
            if (tag == "全部标签" || tag == "未分类" || (tag.isEmpty && selectedLabel.isEmpty) || currentLabels.contains(tag)) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                return
            }
            withAnimation {
                if (!selectedLabel.isEmpty) {
                    currentLabels.removeAll { $0 == selectedLabel }
                }
                if (!tag.isEmpty) {
                    tagViewModel.newTag(tag: tag)
                    currentLabels.append(tag)
                }
                showKeyboard = false
                limitedTextViewCoord.text = ""
                selectedLabel = ""
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.1)
            VStack(spacing: 0) {
                Text(selectedLabel.isEmpty ? "新建标签" : "编辑标签")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.black01)
                    .padding(.vertical, 18)
                HStack {
                    LimitedTextView(isFocused: $showKeyboard, coordinator: limitedTextViewCoord)
                        .frame(height: 20)
                        .foregroundColor(.black01)
                        .padding(.edge(top: 8, leading: 12, bottom: 8))
                    Text("\(limitedTextViewCoord.text.count)/10")
                        .font(.system(size: 15))
                        .foregroundColor(limitedTextViewCoord.text.count <= 10 ? .grey80 : .red02)
                        .padding(.all, 8)
                }.background(Color.grey97)
                    .cornerRadius(CORNER_RADIUS)
                    .padding(.edge(leading: 9, bottom: 18, trailing: 9))
                Color.grey80.frame(height: 0.5)
                HStack {
                    Button {
                        withAnimation {
                            showKeyboard = false
                        }
                    } label: {
                        Spacer()
                        Text("取消")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.grey58)
                        Spacer()
                    }
                    Color.grey80.frame(width: 0.5)
                    Button(action: onComplete) {
                        Spacer()
                        Text("完成")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.blue96)
                        Spacer()
                    }
                }.frame(height: 48)
            }
            .frame(width: 264)
            .background(Color.white)
            .cornerRadius(CORNER_RADIUS)
            .padding(.bottom, 132)
            
            if (tagViewModel.recentTags.count > 0) {
                ZStack(alignment: .leading) {
                    Color.grey97.frame(height: 46)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(tagViewModel.recentTags, id: \.self) { tag in
                                Button {
                                    limitedTextViewCoord.text = tag
                                } label: {
                                    Text(tag)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue96)
                                        .padding(.init(top: 5, leading: 12, bottom: 5, trailing: 12))
                                }

                            }
                        }
                        .background(Color.white)
                        .cornerRadius(CORNER_RADIUS_S)
                        .padding(.horizontal, 18)
                    }
                }
            }
        }.onAppear {
            limitedTextViewCoord.onComplete = onComplete
        }.onDisappear {
            limitedTextViewCoord.onComplete = nil
        }
    }
}
