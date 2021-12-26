//
//  FlexView.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

struct FlexView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    @Binding var isExpand: Bool
    let useScrollView: Bool = true
    
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    @State private var itemHeight: CGFloat = 0
    @State private var maxLines: CGFloat = 1
    private var maxViewHeight: CGFloat {
        get {
            return itemHeight * maxLines + spacing * (maxLines - 1)
        }
    }
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    func allSizeComputed() -> Bool {
        var computed = true
        data.forEach { elem in
            if (!elementsSize.contains{ $0.key == elem}) {
                computed = false
                return
            }
        }
        return computed
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.white
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            if (isExpand && useScrollView) {
                ScrollView(showsIndicators: false) {
                    _body
                }.frame(maxHeight: maxViewHeight)
            } else {
                _body
            }
        }
    }
    
    var _body: some View {
        Group {
            // 有未确定大小的 view 的情况下，先读一遍 view 的大小，下面再进行真正的构造
            if (!allSizeComputed()) {
                VStack {
                    ForEach(Array(data), id: \.self) { elem in
                        content(elem)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[elem] = size
                                if (itemHeight == 0) {
                                    itemHeight = size.height
                                }
                            }
                    }
                }
            } else {
                VStack(alignment: alignment, spacing: spacing) {
                    ForEach(computeRows(), id: \.self) { rowElements in
                        HStack(spacing: spacing) {
                            ForEach(rowElements, id: \.self) { element in
                                content(element)
                            }
                        }
                    }
                }
            }
        }
    }

    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth

        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: 1, height: 1)]
            
            if remainingWidth - elementSize.width >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        if (!isExpand) {
            return [rows[0]]
        }
        DispatchQueue.main.async {
            maxLines = currentRow < 3 ? CGFloat(currentRow + 1) : 3
        }
        return rows
    }
}
