//
//  TagViewModel.swift
//  memo
//
//  Created by stevecai on 2021/12/5.
//

import Foundation

private let path = URL_DOC.appendingPathComponent(RECENT_TAGS_ID_KEY)
private func fetchTags() -> [String] {
    if let data = try? String(contentsOf: path) {
        if (data.isEmpty) {
            return []
        }
        return data.components(separatedBy: ",")
    } else {
        return []
    }
}

class TagViewModel: ObservableObject {
    @Published var recentTags: [String] = fetchTags()
    
    private func save() {
        try? recentTags.joined(separator: ",").write(to: URL_DOC.appendingPathComponent(RECENT_TAGS_ID_KEY), atomically: true, encoding: .utf8)
    }
    
    func clear() {
        recentTags = []
        save()
    }
    
    func newTag(tag: String) {
        if let idx = recentTags.firstIndex(of: tag) {
            recentTags.swapAt(idx, 0)
            save()
            return
        }
        recentTags.insert(tag, at: 0)
        if (recentTags.count > 10) {
            recentTags.removeLast()
        }
        save()
    }
}
