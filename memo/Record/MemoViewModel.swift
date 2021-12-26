//
//  MemoViewModel.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

class MemoViewModel: ObservableObject {
    @Published var model: MemoModel
    
    var tags: [String] {
        get {
            var tags = Set<String>()
            var arr: [String] = []
            arr.append("所有标签")
            model.memoChains.forEach { chain in
                chain.tags.forEach { s in
                    if (!tags.contains(s)) {
                        tags.insert(s)
                        arr.append(s)
                    }
                }
            }
            arr.append("未分类")
            return arr
        }
    }
    
    func getFilteredChains(target: String) -> [MemoChain] {
        var arr: [MemoChain] = []
        for idx in model.memoChains.indices {
            let chain = model.memoChains[idx]
            if (target == "所有标签" ||
                (target == "未分类" && chain.tags.isEmpty) ||
                (chain.tags.contains(where: { $0 == target }))) {
                arr.append(chain)
            }
        }
        return arr
    }
    
    // 计算每个 attachment 出现次数，确定是否可以删除
    private func computeAttachmentCounts() -> [String : Int] {
        var m: [String : Int] = [:]
        for chain in model.memoChains {
            for memo in chain.memos {
                for attachment in memo.attachments {
                    if let x = m[attachment] {
                        m[attachment] = x + 1
                    } else {
                        m[attachment] = 1
                    }
                }
            }
        }
        return m
    }
    
    func changeFoldState(id: UUID, isFold: Bool) {
        for idx in model.memoChains.indices {
            if (model.memoChains[idx].id == id) {
                model.memoChains[idx].isFold = isFold
                model.saveChain(model.memoChains[idx])
            }
        }
    }
    
    func changePinState(id: UUID, isPined: Bool) {
        for idx in model.memoChains.indices {
            if (model.memoChains[idx].id == id) {
                model.memoChains[idx].isPined = isPined
                model.saveChain(model.memoChains[idx])
            }
        }
        model.reorderChains()
    }
    
    func removeMemo(_ index: Int, at chain: MemoChain) {
        if (chain.memos.count == 1) {
            model.memoChains.removeAll { $0.id == chain.id }
            model.saveChainIDs()
        } else {
            let idx = model.memoChains.firstIndex { $0.id == chain.id } ?? 0
            model.memoChains[idx].memos.remove(at: index)
            model.saveChain(model.memoChains[idx])
        }
    }
    
    func saveImage(_ image: UIImage) -> String? {
        if let jpegImage = image.jpegData(compressionQuality: 0.9) {
            let id = UUID().uuidString
            let path = URL_DOC.appendingPathComponent(IMAGES_PATH_PREFIX, isDirectory: true).appendingPathComponent(id)
            if let _ = try? jpegImage.write(to: path, options: .atomic) {
                return id
            }
        }
        return nil
    }
    
    func newMemo(content: NSAttributedString, labels: [String], attachments: [String], referer: MemoReferer?) {
        let memo = Memo(time: Date.init(timeIntervalSinceNow: 0),
                        content: content,
                        attachments: attachments)
        model.newMemo(memo, tags: labels, referer: referer)
    }
    
    func saveChain(chain: MemoChain) {
        model.saveChain(chain)
        if let idx = model.memoChains.firstIndex(where: { $0.id == chain.id }) {
            model.memoChains[idx] = chain
        }
    }
    
    func clear() {
        model.clear()
    }
    
    init() {
        model = MemoModel()
    }
}
