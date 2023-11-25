//
//  CreatedWorldListVIew.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/10/29.
//

import SwiftUI

struct CreatedWorldListView: View {
    
    var backgroundImage: UIImage
    var aspectFit: Bool = false
    var worlds: [WorldInfo]
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack(alignment: .top) {
            ContentBackgroundImage(image: backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.2, aspectFit: aspectFit)
            
            ScrollView {
                VStack {
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 40)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width - 40)/2 - 20), alignment: .top)], alignment: .center) {
                        ForEach(0..<worlds.count, id: \.self) { i in
                            NavigationLink(destination: CreatorHomeView(worldInfo: worlds[i])) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Image(uiImage: worlds[i].backgroundImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                        .cornerRadius(15)
                                        .shadow(color: .black, radius: 15, x: 0, y: 0)
                                    
                                    Text(worlds[i].name)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.white)
                                        .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .leading)
                                        .lineLimit(2)
                                        .card()
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing], 20)
                }
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreatedWorldListView"
            }
        }
        .ignoresSafeArea()
        .customBackButton()
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
}
