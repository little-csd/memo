//
//  RichTextEditorView.swift
//  memo
//
//  Created by stevecai on 2021/12/4.
//

import SwiftUI

struct RichTextEditorView: View {
    
    @Binding var showKeyboard: Bool
    @Binding var memoReferer: MemoReferer?
    
    @State private var openPhotoLibrary = false
    @State private var currentImageIDs: [String] = []
    
    @State private var showLabelEditorView = false
    @State private var selectedLabel = ""
    @State private var currentLabels: [String] = []
    
    @StateObject var richTextViewCoord = RichTextViewCoordinator()
    @StateObject var limitedTextViewCoord = LimitedTextViewCoord()
    @EnvironmentObject var tagViewModel: TagViewModel
    @EnvironmentObject var memoViewModel: MemoViewModel

    var body: some View {
        ZStack {
            if (showLabelEditorView) {
                LabelCreateView(showKeyboard: $showLabelEditorView,
                                selectedLabel: $selectedLabel,
                                currentLabels: $currentLabels,
                                limitedTextViewCoord: limitedTextViewCoord,
                                tagViewModel: tagViewModel)
                    .ignoresSafeArea(edges: .top)
            } else {
                VStack(spacing: 0) {
                    Color.grey92.frame(width: 36, height: 6)
                        .cornerRadius(CORNER_RADIUS)
                        .padding(.edge(top: 8, bottom: 12))
                    VStack(alignment: .leading, spacing: 12) {
                        if (memoReferer == nil) {
                            LabelView(selected: $showLabelEditorView,
                                      selectedLabel: $selectedLabel,
                                      currentLabels: $currentLabels,
                                      limitedTextViewCoord: limitedTextViewCoord)
                        }
                        ZStack(alignment: .topLeading) {
                            RichTextView(coordinator: richTextViewCoord, showKeyboard: $showKeyboard).frame(height: 80)
                            if (richTextViewCoord.isTextEmpty) {
                                Text("记录你的想法...").font(.system(size: 16)).foregroundColor(.grey70)
                            }
                        }
                    }.padding(.edge(leading: 24, bottom: 36, trailing: 24))
                    if (currentImageIDs.count > 0) {
                        ImagesRowView(currentImageIDs: $currentImageIDs)
                    }
                    HStack(spacing: 24) {
                        if (currentImageIDs.count < 5) {
                            Button {
                                openPhotoLibrary = true
                            } label: {
                                Image("EditorImg")
                            }
                        }
                        Button {
                            richTextViewCoord.clickBoldFont()
                        } label: {
                            Image("EditorBold").renderingMode(.template).foregroundColor(richTextViewCoord.isBold ? .blue96 : .grey58)
                        }
                        Button {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        } label: {
                            Image("EditorTodo").renderingMode(.template).foregroundColor(.grey58)
                        }
                        Button {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        } label: {
                            Image("EditorScan").renderingMode(.template).foregroundColor(.grey58)
                        }
                        Spacer()
                        Button {
                            if (richTextViewCoord.isTextEmpty) {
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                return
                            }
                            memoViewModel.newMemo(content: richTextViewCoord.data, labels: currentLabels, attachments: currentImageIDs, referer: memoReferer)
                            showKeyboard = false
                        } label: {
                            Text("保存")
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(Color.white)
                                .frame(height: 28)
                                .padding(.horizontal, 12)
                                .background(Color.blue96)
                                .cornerRadius(CORNER_RADIUS)
                        }
                    }
                    .padding(.edge(top: 8, leading: 24, bottom: 8, trailing: 24))
                    .background(Color.grey97)
                }
                .background(Color.white)
                .cornerRadius(CORNER_RADIUS, corners: [.topLeft, .topRight])
            }
        }
        .onDisappear {
            memoReferer = nil
        }
        .fullScreenCover(isPresented: $openPhotoLibrary) {
        } content: {
            ImagePicker { image in
                if let id = memoViewModel.saveImage(image) {
                    currentImageIDs.append(id)
                }
            }.ignoresSafeArea()
        }
    }
}
