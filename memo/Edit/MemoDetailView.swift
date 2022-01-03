//
//  MemoDetailView.swift
//  memo
//
//  Created by stevecai on 2021/12/18.
//

import SwiftUI

struct MemoDetailView: View {
    @State var chain: MemoChain
    @State var memoIndex: Int
    var initializeIndex: Int
    
    @StateObject var richTextViewCoord = RichTextViewCoordinator()
    @StateObject var limitedTextViewCoord = LimitedTextViewCoord()
    @EnvironmentObject var tagViewModel: TagViewModel
    @EnvironmentObject var memoViewModel: MemoViewModel
    @ObservedObject var keyboardState = KEYBOARD
    
    @State private var openPhotoLibrary = false
    @State private var currentImageIDs: [String] = []
    
    @State private var showLabelEditorView = false
    @State private var selectedLabel = ""
    @State private var currentLabels: [String] = []
    
    @Environment(\.presentationMode) var presentation
    
    init(chain: MemoChain, memoIndex: Int) {
        _memoIndex = State(initialValue: memoIndex)
        _chain = State(initialValue: chain)
        _currentLabels = State(initialValue: chain.tags)
        
        let memo = chain.memos[memoIndex]
        _currentImageIDs = State(initialValue: memo.attachments)
        
        let coord = RichTextViewCoordinator(data: memo.content)
        _richTextViewCoord = StateObject(wrappedValue: coord)
        
        self.initializeIndex = memoIndex
    }
    
    func updateDataByIndex(index: Int) {
        chain.memos[memoIndex].content = richTextViewCoord.data
        chain.memos[memoIndex].attachments = currentImageIDs
        
        memoIndex = index
        richTextViewCoord.updateData(data: chain.memos[index].content)
        currentImageIDs = chain.memos[index].attachments
    }
    
    // "引用来源" 这一行
    var refererSourceView: some View {
        HStack(spacing: 0) {
            if (memoIndex != chain.memos.count - 1) { // 不是最后一个，显示 "引用来源"
                HStack(spacing: 6) {
                    Text("引用来源")
                        .font(.system(size: 14))
                        .foregroundColor(.blue96)
                    Image("RefererFrom")
                }
                .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(Color.grey98)
                .cornerRadius(CORNER_RADIUS)
                .onTapGesture {
                    updateDataByIndex(index: memoIndex+1)
                }
            } else {
                LabelView(selected: $showLabelEditorView,
                          selectedLabel: $selectedLabel,
                          currentLabels: $currentLabels,
                          limitedTextViewCoord: limitedTextViewCoord)
            }
            Spacer()
            Text(DATE_FORMATTER.string(from: chain.memos[memoIndex].time))
                .foregroundColor(.grey58)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 24)
    }
    
    // "被引用至" 这一行
    var refererTargetView: some View {
        HStack(spacing: 6) {
            Text("被引用至")
                .font(.system(size: 14))
                .foregroundColor(.blue96)
            Image("RefererTo")
        }
        .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
        .background(Color.grey98)
        .cornerRadius(CORNER_RADIUS)
        .padding(.horizontal, 24)
        .onTapGesture {
            updateDataByIndex(index: memoIndex-1)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 6)
                refererSourceView
                ZStack(alignment: .topLeading) {
                    RichTextView(coordinator: richTextViewCoord)
                    if (richTextViewCoord.isTextEmpty) {
                        Text("记录你的想法...").font(.system(size: 16)).foregroundColor(.grey70)
                    }
                }.padding(.init(top: 12, leading: 24, bottom: 18, trailing: 24))
                if (memoIndex > 0) {
                    refererTargetView
                    Spacer(minLength: 18)
                }
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
                        if (keyboardState.keyboardIsHidden) {
                            chain.memos[memoIndex].content = richTextViewCoord.data
                            chain.memos[memoIndex].attachments = currentImageIDs
                            chain.tags = currentLabels
                            memoViewModel.saveChain(chain: chain)
                            presentation.dismiss()
                        } else {
                            richTextViewCoord.closeKeyboard()
                        }
                    } label: {
                        Text(keyboardState.keyboardIsHidden ? "保存" : "完成")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(Color.white)
                            .frame(height: 28)
                            .padding(.horizontal, 12)
                            .background(Color.blue96)
                            .cornerRadius(CORNER_RADIUS)
                    }
                }
                .padding(.edge(top: 8, leading: 24, bottom: 8, trailing: 24))
                .background(Color.grey97.ignoresSafeArea(edges: .bottom))
            }
            .background(Color.white)
            .disabled(showLabelEditorView)
            if (showLabelEditorView) {
                LabelCreateView(showKeyboard: $showLabelEditorView,
                                selectedLabel: $selectedLabel,
                                currentLabels: $currentLabels,
                                limitedTextViewCoord: limitedTextViewCoord,
                                tagViewModel: tagViewModel)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .onDisappear {
            if let chain = memoViewModel.model.memoChains.first(where: { $0.id == chain.id }) {
                self.chain = chain
                self.memoIndex = initializeIndex
                richTextViewCoord.updateData(data: chain.memos[initializeIndex].content)
                currentLabels = chain.tags
                currentImageIDs = chain.memos[initializeIndex].attachments
            }
        }
        .fullScreenCover(isPresented: $openPhotoLibrary) {
        } content: {
            ImagePicker { image in
                if let id = memoViewModel.saveImage(image) {
                    currentImageIDs.append(id)
                }
            }.ignoresSafeArea()
        }
        .navigationBarTitleView(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                chain.memos[memoIndex].content = richTextViewCoord.data
                chain.memos[memoIndex].attachments = currentImageIDs
                chain.tags = currentLabels
                memoViewModel.saveChain(chain: chain)
                presentation.wrappedValue.dismiss()
            }, label: {
                Image("MemoDetailBack")
            }),
            trailing: Button(action: {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }, label: {
                Image("MemoDetailMore")
            }))
    }
}
