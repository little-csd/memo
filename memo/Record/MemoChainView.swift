//
//  MemoChainView.swift
//  memo
//
//  Created by stevecai on 2021/11/21.
//

import SwiftUI

struct MemoChainView: View {
    
    @EnvironmentObject var memoViewModel: MemoViewModel
    
    var chain: MemoChain
    
    @Binding var popupSheet: Bool
    @Binding var referer: MemoReferer?
    @State var jumpToDetail: [Bool] = Array(repeating: false, count: 200)
    
    func getCorners(idx: Int, count: Int) -> UIRectCorner {
        if (idx == 0) {
            return [.topLeft, .topRight]
        } else if (idx == count - 1) {
            return [.bottomLeft, .bottomRight]
        } else {
            return []
        }
    }
    
    // context menu 里面 button 响应
    func exec(_ task: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.milliseconds(500))) {
            withAnimation {
                task()
            }
        }
    }
    
    // chain 上的第一个 memo
    func buildFirstView(content: NSAttributedString, tags: [String], time: Date, showPinIcon: Bool, showFoldIcon: Bool) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center, spacing: 0) {
                if (showPinIcon) {
                    Image("PinMain").padding(.leading, 6)
                }
                
                Text(tags.reduce(String.init(), { partialResult, item in
                    if (partialResult.isEmpty) {
                        return "#" + item;
                    } else {
                        return partialResult + " #" + item;
                    }
                })).foregroundColor(.blue96)
                    .font(.system(size: 12))
                    .padding(.leading, showPinIcon ? 0 : 24)
                Spacer()
                Text(DATE_FORMATTER.string(from: time))
                    .foregroundColor(.grey58)
                    .font(.system(size: 12))
                    .padding(.trailing, showFoldIcon ? 0 : 24)
                
                if (showFoldIcon) {
                    Button {
                        memoViewModel.changeFoldState(id: chain.id, isFold: false)
                    } label: {
                        Image("Expand").padding(.trailing, 6)
                    }
                }
            }
            .frame(height: 30)
            .padding(.top, 6)
            VStack(alignment: .leading, spacing: 12) {
                Text(content)
                if (chain.memos[0].attachments.count > 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(chain.memos[0].attachments, id: \.self) { uuid in
                                ImageWithPreview(image: UIImage(uuid: uuid))
                            }
                        }
                    }
                }
            }.padding(.init(top: 0, leading: 24, bottom: 32, trailing: 24))
        }
    }
    
    func buildMemoView(idx: Int) -> some View {
        Group {
            if (idx == 0) {
                buildFirstView(
                    content: chain.memos[0].content,
                    tags: chain.tags,
                    time: chain.memos[0].time,
                    showPinIcon: chain.isPined,
                    showFoldIcon: chain.memos.count > 1 && chain.isFold
                )
            } else if (idx == chain.memos.count - 1) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(chain.memos[idx].content)
                        if (chain.memos[idx].attachments.count > 0) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 7) {
                                    ForEach(chain.memos[idx].attachments, id: \.self) { uuid in
                                        ImageWithPreview(image: UIImage(uuid: uuid))
                                    }
                                }
                            }
                        }
                    }.padding(.init(top: 33, leading: 24, bottom: 8, trailing: 24))
                    HStack {
                        Spacer()
                        Button {
                            memoViewModel.changeFoldState(id: chain.id, isFold: true)
                        } label: {
                            Image("Unexpand").padding([.bottom, .trailing], 6)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 0) {
                        Text(chain.memos[idx].content)
                        Spacer(minLength: 0)
                    }
                    if (chain.memos[idx].attachments.count > 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                ForEach(chain.memos[idx].attachments, id: \.self) { uuid in
                                    ImageWithPreview(image: UIImage(uuid: uuid))
                                }
                            }
                        }
                    }
                }
                .padding(.init(top: 33, leading: 24, bottom: 32, trailing: 24))
            }
        }.background(Color.white)
    }
    
    func buildMenuItem(at index: Int) -> some View {
        VStack {
            if (index == 0) {
                Button {
                    exec {
                        let pinState = chain.isPined
                        memoViewModel.changePinState(id: chain.id, isPined: !pinState)
                    }
                } label: {
                    Text(chain.isPined ? "取消置顶" : "置顶")
                }
                Text("分享")
            }
            Button {
                exec {
                    popupSheet = true
                    referer = MemoReferer(chainId: chain.id, memoIndex: index)
                }
            } label: {
                Text("引用")
            }
            Divider()
            if #available(iOS 15.0, *) {
                Button(role: .destructive) {
                    exec {
                        memoViewModel.removeMemo(index, at: chain)
                    }
                } label: {
                    Text("从列表中删除")
                }
            } else {
                Button {
                    exec {
                        memoViewModel.removeMemo(index, at: chain)
                    }
                } label: {
                    Text("从列表中删除")
                }
            }
        }
    }
    
    var body: some View {
        Group {
            if (chain.memos.count == 1 || chain.isFold) {
                buildMemoView(idx: 0)
                    .cornerRadius(CORNER_RADIUS)
                    .navigate(to: MemoDetailView(chain: chain, memoIndex: 0), when: $jumpToDetail[0])
                    .onTapGesture {
                        jumpToDetail[0] = true
                    }
                    .contextMenu {
                        buildMenuItem(at: 0)
                    }
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(chain.memos.indices, id: \.self) { idx in
                        buildMemoView(idx: idx)
                            .cornerRadius(CORNER_RADIUS, corners: getCorners(idx: idx, count: chain.memos.count))
                            .navigate(to: MemoDetailView(chain: chain, memoIndex: idx), when: $jumpToDetail[idx])
                            .onTapGesture {
                                jumpToDetail[idx] = true
                            }
                            .contextMenu {
                                buildMenuItem(at: idx)
                            }
                    }
                }
            }
        }
    }
}
