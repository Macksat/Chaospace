//
//  VideoTestView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/07/03.
//

import SwiftUI

struct VideoTestView: View {
    
    @EnvironmentObject var contentInfo: ContentInfo
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                BackgroundUIImage(image: UIImage(named: "palow") ?? UIImage(), opacity: 0.2)
                    .gesture(TapGesture().onEnded({ _ in
                        print("hello")
                    }))
                
                ScrollViewReader { _ in
                    ScrollView {
                        VStack {
                            PlayVideoView(url: contentInfo.scrollContents[0].videoURL, stopBool: $contentInfo.scrollContents[0].stopBools[0])
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)*9/16)
                                .opacity(contentInfo.scrollContents[0].opacity)
                                .cornerRadius(20)
                                .shadow(color: .black, radius: 15, x: 0, y: 0)
                                .padding(.top, 100)
                                .padding(.bottom, contentInfo.scrollContents[0].bottomHeight)
                        }
                    }
                    .gesture(TapGesture().onEnded({ _ in
                        print("hello")
                    }))
                }
                
                GradientNavigationBar()
            }
            .ignoresSafeArea()
        }
    }
}

struct VideoTestView_Previews: PreviewProvider {
    static var previews: some View {
        VideoTestView()
    }
}
