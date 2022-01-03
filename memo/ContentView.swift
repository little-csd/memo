//
//  ContentView.swift
//  memo
//
//  Created by stevecai on 2021/11/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection = 0
    
    @State var popupSheet = false
    @State var memoReferer: MemoReferer? = nil
    
    @StateObject var tagViewModel = TagViewModel()
    @StateObject var memoViewModel = MemoViewModel()
    
    var recordingFooter: some View {
        ZStack(alignment: .top) {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)).frame(height: 149)
            HStack(alignment: .center, spacing: 8) {
                Image("AddMain").frame(width: 30, height: 30)
                Text("开始记录你的想法...").font(.system(size: 15)).foregroundColor(.grey70)
                Spacer()
            }
            .padding(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(Color.white)
            .cornerRadius(CORNER_RADIUS)
            .onTapGesture {
                popupSheet = true
            }
            .padding(.init(top: 8, leading: 8, bottom: 96, trailing: 8))
        }.background(Color.init(white: 1, opacity: 0.5))
    }
    
    var tabItems: some View {
        HStack(spacing: 0) {
            Button {
                selection = 0
            } label: {
                Spacer()
                VStack(spacing: 0) {
                    Image(selection == 0 ? "RecordMain_2" : "RecordMain_1").frame(width: 36, height: 36)
                    Text("记录").font(.system(size: 10))
                }.foregroundColor(selection == 0 ? Color.blue96 : Color.grey70)
                Spacer()
            }
            Button {
                selection = 1
            } label: {
                Spacer()
                VStack(spacing: 0) {
                    Image(selection == 1 ? "CommunityMain_2" : "CommunityMain_1").renderingMode(.template).frame(width: 36, height: 36)
                    Text("社区").font(.system(size: 10))
                }.foregroundColor(selection == 1 ? Color.blue96 : Color.grey70)
                Spacer()
            }
            Button {
                selection = 2
            } label: {
                Spacer()
                VStack(spacing: 0) {
                    Image(selection == 2 ? "PersonalMain_2" : "PersonalMain_1").renderingMode(.template).frame(width: 36, height: 36)
                    Text("个人").font(.system(size: 10))
                }.foregroundColor(selection == 2 ? Color.blue96 : Color.grey70)
                Spacer()
            }
        }.padding(.bottom, 30)
    }
    
    var body: some View {
        // 这里没有使用 TabView，功能太少了，上面放个“开始记录”的 UI 都不方便
        NavigationView {
            ZStack(alignment: .bottom) {
                switch (selection) {
                case 0:
                    ZStack(alignment: .bottom) {
                        Color.grey97
                        RecordView(popupSheet: $popupSheet, referer: $memoReferer, bottomOffset: 149)
                        recordingFooter
                    }
                case 1:
                    ZStack {
                        Color.grey97
                        Text("社区(暂未开放)")
                    }
                case 2:
                    ZStack {
                        Color.grey97
                        Text("个人(暂未开放)，点击可删除所有记录").onTapGesture {
                            memoViewModel.clear()
                            tagViewModel.clear()
                        }
                    }
                default: // not reach
                    Color.grey97
                }
                tabItems
            }
            .navigationBarTitleView(EmptyView())
            .navigationBarHidden(true)
            .navigationViewStyle(.stack)
            .ignoresSafeArea()
        }
        .bottomSheet($popupSheet) {
            RichTextEditorView(showKeyboard: $popupSheet, memoReferer: $memoReferer)
        }
        .environmentObject(memoViewModel)
        .environmentObject(tagViewModel)
    }
}













//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
