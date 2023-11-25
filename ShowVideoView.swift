//
//  PlayVideoView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/07/08.
//

import SwiftUI

struct ShowVideoView: View {
    
    @Binding var url: URL
    @Binding var showVideoBool: Bool
    @State var opacity = 0.0
    @State var barHidden = true
    @EnvironmentObject var name: Name
    @Binding var preName: String
    @State var hogeBool = false
    @EnvironmentObject var tabBarHidden: TabBarHidden
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black.opacity(opacity))
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .gesture(TapGesture().onEnded({ _ in
                    barHidden.toggle()
                    if name.name == "" {
                        name.name = "ShowVideoView"
                    } else {
                        name.name = ""
                    }
                }))
            
            PlayVideoView(url: url, didChange: $hogeBool)
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 9 / 16)
                .opacity(opacity)
            
            if barHidden == false {
                GradientNavigationBar()
            }
        }
        .opacity(opacity)
        .onWillAppear {
            barHidden = true
            tabBarHidden.hidden = barHidden
            name.name = "ShowVideoView"
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
        }
        .onWillDisappear {
            name.name = preName
        }
        .gesture(DragGesture()
                .onEnded({ value in
                    if value.translation.height > 50 || value.translation.height < -50 {
                        backFunc()
                    }
                    if value.translation.width > 50 || value.translation.width < -50 {
                        backFunc()
                    }
                }))
        .gesture(TapGesture().onEnded({ _ in
            barHidden.toggle()
            tabBarHidden.hidden = barHidden
        }))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
    }
    
    func backFunc() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0.0
        }
        self.name.name = preName
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showVideoBool = false
        }
    }
}

