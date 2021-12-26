//
//  MemoModel.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import UIKit

struct MemoModel {
    public var memoChains: [MemoChain]
    
    private static var chainIDs: [String] {
        get {
            let path = URL_DOC.appendingPathComponent(CHAIN_ID_KEY)
            if let data = try? String(contentsOf: path) {
                return data.components(separatedBy: ",")
            } else {
                print("read \(CHAIN_ID_KEY) failed")
                return []
            }
        }
    }
    
    private static func createFakeMemos() -> [MemoChain] {
        var data = [MemoChain]()
        let chain1 = MemoChain(tags: ["学习方法"], memos: [
            Memo(time: Date(),
                 content: "多数时候我们都会陷入「收藏者谬误」，感觉收藏到就是学习。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: []),
            Memo(time: Date(timeIntervalSinceNow: TimeInterval(1_000_000)),
                 content: "实际上「知晓某事」并不是「知道某事」。我觉得收藏更像是把信息搬运。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: []),
            Memo(time: Date(timeIntervalSinceNow: TimeInterval(2_000_000)),
                 content: "多数时候我们都会陷入「收藏者谬误」。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: [])
        ], isPined: true)
        let chain2 = MemoChain(tags: ["生活随笔"], memos: [
            Memo(time: Date(),
                 content: "Life's a mess party but we enjoy it so much.".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: [])
        ])
        let chain3 = MemoChain(tags: ["随想"], memos: [
            Memo(time: Date(),
                 content: "多数时候我们都会陷入「收藏者谬误」，感觉收藏到就是学习到，但实际上「知晓某事」并不是「知道某事」。我觉得收藏更像是把信息搬运...".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: [])
        ])
        let chain4 = MemoChain(tags: [], memos: [
            Memo(time: Date(),
                 content: "多数时候我们都会陷入「收藏者谬误」，感觉收藏到就是学习。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: []),
            Memo(time: Date(timeIntervalSinceNow: TimeInterval(1_000_000)),
                 content: "实际上「知晓某事」并不是「知道某事」。我觉得收藏更像是把信息搬运。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: []),
            Memo(time: Date(timeIntervalSinceNow: TimeInterval(2_000_000)),
                 content: "多数时候我们都会陷入「收藏者谬误」。".withAttributed(font: UIFont.systemFont(ofSize: 16), color: UIColor.black),
                 attachments: [])
        ], isPined: false)
        data.append(chain1)
        data.append(chain2)
        data.append(chain3)
        data.append(chain4)
        return []
    }
    
    private static func createMemosFromDB() -> [MemoChain] {
        var chains: [MemoChain] = []
        chainIDs.forEach({ uuid in
            let path = URL_DOC.appendingPathComponent(CHAINS_PATH_PREFIX, isDirectory: true).appendingPathComponent(uuid)
            do {
                let data = try Data(contentsOf: path)
                let chain = try JSONDecoder().decode(MemoChain.self, from: data)
                chains.append(chain)
            } catch {
                print("read chain \(uuid) failed")
            }
        })
        return chains
    }
    
    func saveChainIDs() {
        var chainIDs: [String] = []
        memoChains.forEach { chain in
            chainIDs.append(chain.id.uuidString)
        }
        let data = chainIDs.joined(separator: ",")
        let path = URL_DOC.appendingPathComponent(CHAIN_ID_KEY)
        try? data.write(to: path, atomically: true, encoding: .utf8)
    }
    
    func saveChain(_ chain: MemoChain) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(chain)
            let path = URL_DOC.appendingPathComponent(CHAINS_PATH_PREFIX, isDirectory: true).appendingPathComponent(chain.id.uuidString)
            try encoded.write(to: path, options: .atomic)
        } catch {
            print("save chain \(chain.id) failed")
        }
    }
    
    mutating func reorderChains() {
        memoChains = memoChains.sorted { chain1, chain2 in
            if (chain1.isPined != chain2.isPined) {
                return chain1.isPined
            }
            let memo1 = chain1.memos[0]
            let memo2 = chain2.memos[0]
            return memo1.time.compare(memo2.time).rawValue > 0
        }
        saveChainIDs()
    }
    
    mutating func newMemo(_ memo: Memo, tags: [String], referer: MemoReferer?) {
        if let referer = referer {
            let chainIdx = memoChains.firstIndex { $0.id == referer.chainId }!
            let chain = memoChains[chainIdx]
            if (referer.memoIndex == 0) { // 引用第一个 memo，不新建链
                var memos = chain.memos
                memos.insert(memo, at: 0)
                let newChain = MemoChain(id: UUID(), tags: chain.tags, memos: memos, isPined: chain.isPined, isFold: chain.isFold)
                memoChains[chainIdx] = newChain
                saveChain(newChain)
            } else { // 否则新建一条 MemoChain，复制前面的 memo
                var memos = Array(chain.memos.suffix(from: referer.memoIndex))
                memos.insert(memo, at: 0)
                let newChain = MemoChain(id: UUID(), tags: chain.tags, memos: memos, isPined: chain.isPined, isFold: chain.isFold)
                memoChains.insert(newChain, at: 0)
                saveChain(newChain)
            }
        } else {
            let chain = MemoChain(tags: tags, memos: [memo])
            memoChains.insert(chain, at: 0)
            saveChain(chain)
        }
        reorderChains()
    }
    
    mutating func clear() {
        // clear attachments
        try? FileManager.default.removeItem(at: URL_DOC.appendingPathComponent(IMAGES_PATH_PREFIX, isDirectory: true))
        try? FileManager.default.removeItem(at: URL_DOC.appendingPathComponent(CHAINS_PATH_PREFIX, isDirectory: true))
        try? FileManager.default.removeItem(at: URL_DOC.appendingPathComponent(CHAIN_ID_KEY))
        memoChains = []
    }
    
    init() {
        let URL_CHAINS = URL_DOC.appendingPathComponent(CHAINS_PATH_PREFIX, isDirectory: true)
        let URL_IMAGES = URL_DOC.appendingPathComponent(IMAGES_PATH_PREFIX, isDirectory: true)
        if (!FileManager.default.fileExists(atPath: URL_CHAINS.path)) {
            try! FileManager.default.createDirectory(at: URL_CHAINS, withIntermediateDirectories: true)
        }
        if (!FileManager.default.fileExists(atPath: URL_IMAGES.path)) {
            try! FileManager.default.createDirectory(at: URL_IMAGES, withIntermediateDirectories: true)
        }
        memoChains = MemoModel.createMemosFromDB()
    }
}

struct Memo: Identifiable, Codable {
    var id = UUID()
    let time: Date
    var content: NSAttributedString
    var attachments: [String] = []
    
    enum CodingKeys : CodingKey {
        case id
        case time
        case content
        case attachments
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(time, forKey: CodingKeys.time)
        try container.encode(attachments, forKey: CodingKeys.attachments)
        
        var attributedText: [String] = []
        content.enumerateAttributes(in: NSRange(location: 0, length: content.length), options: []) { attr, range, _ in
            let s = content.attributedSubstring(from: range).string
            if let font = attr[NSAttributedString.Key.font] as? UIFont {
                if (font.fontDescriptor.symbolicTraits.contains(.traitBold)) {
                    attributedText.append("b" + s)
                } else {
                    attributedText.append("n" + s)
                }
            }
        }
        let data = try JSONSerialization.data(withJSONObject: attributedText, options: [])
        try container.encode(data, forKey: CodingKeys.content)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: CodingKeys.id)
        time = try container.decode(Date.self, forKey: CodingKeys.time)
        attachments = try container.decode(Array.self, forKey: CodingKeys.attachments)
        
        let data = try container.decode(Data.self, forKey: CodingKeys.content)
        let attributedText = (try JSONSerialization.jsonObject(with: data, options: [])) as? [String]
        var text = NSAttributedString(string: "")
        attributedText?.forEach({ str in
            if (str.first == "b") {
                text = text + String(str.dropFirst()).withFontAttributed(font: UIFont.boldSystemFont(ofSize: 17))
            } else {
                text = text + String(str.dropFirst()).withFontAttributed(font: UIFont.systemFont(ofSize: 17))
            }
        })
        content = text
    }
    
    init(time: Date, content: NSAttributedString, attachments: [String]) {
        self.time = time
        self.content = content
        self.attachments = attachments
    }
}

struct MemoChain: Identifiable, Codable {
    var id = UUID()
    var tags: [String]
    var memos: [Memo]
    var isPined: Bool = false
    var isFold: Bool = true
}

struct MemoReferer {
    var chainId: UUID
    var memoIndex: Int
}
