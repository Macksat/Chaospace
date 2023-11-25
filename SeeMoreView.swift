//
//  SeeMoreView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/04/08.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct SeeMoreView: View {
    
    var title: String = ""
    var explanation: String = ""
    var parentContent: ContentInfo = ContentInfo()
    var worldInfo: WorldInfo = WorldInfo()
    @State var gotContent = false
    var backgroundImage: UIImage
    var aspectFit: Bool = false
    var contents: [ContentInfo]
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack(alignment: .top) {
            ContentBackgroundImage(image: backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.2, aspectFit: aspectFit)
            
            ScrollView {
                VStack {
                    if title != "" {
                        Title(title: title, size: 36)
                            .padding(.bottom, 10)
                    }
                    
                    if explanation != "" {
                        Text(explanation)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .card()
                            .padding(.bottom, 20)
                            .padding([.leading, .trailing], 20)
                    }
                    
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 40)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width - 40)/2 - 20), alignment: .top)], alignment: .center) {
                        ForEach(0..<contents.count, id: \.self) { i in
                            NavigationLink(destination: contentSegueView(contentInfo: contents[i])) {
                                VStack(alignment: .leading, spacing: 5) {
                                    switch contents[i].contentStyle {
                                    case "article":
                                        Image(uiImage: contents[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                            .clipShape(Circle())
                                            .shadow(color: .black, radius: 15, x: 0, y: 0)
                                        
                                        Text(contents[i].name)
                                            .font(.system(size: 16, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .leading)
                                            .lineLimit(2)
                                            .card()
                                        
                                        Text(contents[i].createdUserName)
                                            .font(.system(size: 16, weight: .regular))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .leading)
                                            .lineLimit(1)
                                            .card()
                                    default:
                                        Image(uiImage: contents[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                            .cornerRadius(15)
                                            .shadow(color: .black, radius: 15, x: 0, y: 0)
                                        
                                        Text(contents[i].name)
                                            .font(.system(size: 16, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .leading)
                                            .lineLimit(2)
                                            .card()
                                    }
                                }
                            }
                            .simultaneousGesture(TapGesture().onEnded({ _ in
                                if contents[i].contentStyle == "article" {
                                    addViewCount(id: parentContent.id, collection: "contents")
                                } else {
                                    addViewCount(id: contents[i].id, collection: "contents")
                                }
                                
                                let group = DispatchGroup()
                                if contents[i].gotContent == false {
                                    switch contents[i].contentStyle {
                                    case "scroll":
                                        group.enter()
                                        getScrollContents(contentInfo: contents[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                            contents[i].scrollContents = scrollContents
                                            contents[i].backgroundImage = backgroundImage
                                            contents[i].music = musicURL
                                            contents[i].musicData = musicData
                                            contents[i].gotContent = true
                                            group.leave()
                                        }
                                    case "show":
                                        group.enter()
                                        getShowContents(contentInfo: contents[i]) { showContents in
                                            contents[i].showContents = showContents
                                            contents[i].gotContent = true
                                            group.leave()
                                        }
                                    case "article":
                                        group.enter()
                                        getArticleContents(parentContent: parentContent, i: i) { articleContents in
                                            contents[i].articleContents = articleContents
                                            contents[i].gotContent = true
                                            group.leave()
                                        }
                                    default:
                                        break
                                    }
                                    
                                    group.notify(queue: .main) {
                                        gotContent = true
                                    }
                                } else {
                                    gotContent = true
                                }
                            }))
                        }
                    }
                    .padding([.leading, .trailing], 20)
                }
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "SeeMoreView"
            }
            gotContent = false
        }
        .ignoresSafeArea()
        .customBackButton()
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent)
        } else {
            ContentArticleView(contentInfo: contentInfo, backgroundImage: backgroundImage, aspectFit: aspectFit, gotContent: $gotContent)
        }
    }
}

//struct SeeMoreView_Previews: PreviewProvider {
    //static var previews: some View {
        //SeeMoreView()
    //}
//}
