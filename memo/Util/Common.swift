//
//  Common.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

let CORNER_RADIUS_S = CGFloat(4.0)
let CORNER_RADIUS = CGFloat(8.0)
let BLUR_RADIUS = CGFloat(5.0)
let IMAGE_SIZE = CGFloat(112)
let DATE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
}()

let URL_DOC = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let CHAIN_ID_KEY = "MemoChains.data"
let RECENT_TAGS_ID_KEY = "RecentTags.data"
let CHAINS_PATH_PREFIX = "chains"
let IMAGES_PATH_PREFIX = "images"

private struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    // 0x1A1A1A
    public static var black01: Color {
        return .init(red: 0.1, green: 0.1, blue: 0.1)
    }
    
    // 0x8E8E93
    public static var grey58: Color {
        return .init(red: 0.56, green: 0.56, blue: 0.58)
    }
    
    // 0xAEAEB2
    public static var grey70: Color {
        return .init(red: 0.68, green: 0.68, blue: 0.7)
    }
    
    // 0xC7C7CC
    public static var grey80: Color {
        return .init(red: 0.78, green: 0.78, blue: 0.8)
    }
    
    // 0xE5E5EA
    public static var grey92: Color {
        return .init(red: 0.9, green: 0.9, blue: 0.92)
    }
    
    // 0xF2F2F7
    public static var grey97: Color {
        return .init(red: 0.95, green: 0.95, blue: 0.97)
    }
    
    // 0xF5F7FB
    public static var grey98: Color {
        return .init(red: 0.96, green: 0.97, blue: 0.98)
    }
    
    // 0xFDFDFD
    public static var white99: Color {
        return .init(red: 0.99, green: 0.99, blue: 0.99)
    }
    
    // 0x6783E8
    public static var lightPurple: Color {
        return .init(red: 0.4, green: 0.51, blue: 0.91)
    }
    
    // 0x3478F6
    public static var blue96: Color {
        return .init(red: 0.2, green: 0.47, blue: 0.96)
    }
    
    // 0xFF3B30
    public static var red02: Color {
        return .init(red: 1, green: 0.23, blue: 0.19)
    }
}

extension EdgeInsets {
    public static func edge(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> Self {
        .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

extension CGSize {
    public func dist() -> CGFloat {
        return (self.width * self.width + self.height * self.height).squareRoot()
    }
    
    public func longSide() -> CGFloat {
        return self.width > self.height ? self.width : self.height
    }
}

extension UIImage {
    convenience init?(uuid: String) {
        let path = URL_DOC.appendingPathComponent(IMAGES_PATH_PREFIX, isDirectory: true).appendingPathComponent(uuid)
        if let imageData = try? Data(contentsOf: path) {
            self.init(data: imageData)
        } else {
            self.init(systemName: "EditorImage")
        }
    }
}

extension String {
    
    func withFontAttributed(font: UIFont) -> NSAttributedString {
        let s = NSMutableAttributedString.init(string: self)
        let range = NSRange.init(location: 0, length: self.count)
        s.addAttribute(.font, value: font, range: range)
        return s
    }
    
    func withAttributed(font: UIFont, color: UIColor) -> NSAttributedString {
        let s = NSMutableAttributedString.init(string: self)
        let range = NSRange.init(location: 0, length: self.count)
        s.addAttribute(.font, value: font, range: range)
        s.addAttribute(.foregroundColor, value: color, range: range)
        return s
    }
    
    func removeFileAsUUID(with prefix: String) {
        if (prefix.isEmpty) {
            let path = URL_DOC.appendingPathComponent(self)
            try? FileManager.default.removeItem(at: path)
        } else {
            let path = URL_DOC.appendingPathComponent(prefix, isDirectory: true).appendingPathComponent(self)
            try? FileManager.default.removeItem(at: path)
        }
    }
}

extension Text {
    init(_ astring: NSAttributedString) {
        self.init("")
        
        astring.enumerateAttributes(in: NSRange(location: 0, length: astring.length), options: []) { (attrs, range, _) in
            
            var t = Text(astring.attributedSubstring(from: range).string)

            if let font = attrs[NSAttributedString.Key.font] as? UIFont {
                t  = t.font(.init(font))
            }
            
            if let color = attrs[NSAttributedString.Key.foregroundColor] as? UIColor {
                t  = t.foregroundColor(Color(color))
            }
            
            self = self + t
        }
    }
}

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let c = left.mutableCopy() as! NSMutableAttributedString
        c.append(right)
        return c
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        background(
            NavigationLink(
                destination: view,
                isActive: binding,
                label: { EmptyView() }
            )
            .accessibility(hidden: true)
        )
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
