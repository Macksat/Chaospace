//
//  CreatedContentListView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/10/29.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct CreatedContentListView: View {
    
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
                                addViewCount(id: contents[i].id, collection: "contents")
                                
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
                                        getArticle(contentInfo: contents[i]) { articleContents in
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
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreatedContentListView"
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
    
    func getArticle(contentInfo: ContentInfo, _ completion: @escaping(_ articleContents: [ArticleContent]) -> Void) {
        var articleContents = [ArticleContent]()
        let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
        let group = DispatchGroup()
        let subContentStoreRef = ref.collection("articleContent")
        group.enter()
        subContentStoreRef.getDocuments { subDocuments, _ in
            if let subDocuments = subDocuments {
                for sdoc in subDocuments.documents {
                    var articleContent = ArticleContent()
                    articleContent.type = sdoc.data()["type"] as! String
                    articleContent.index = sdoc.data()["index"] as! Int
                    if articleContent.type == "image" {
                        group.enter()
                        Storage.storage().reference().child(sdoc.data()["content1"] as! String).downloadURL { someURL, _ in
                            if let someURL = someURL {
                                group.enter()
                                requestImageFromURLSession(url: someURL as NSURL) { image in
                                    articleContent.imageData = image
                                    group.leave()
                                }
                            }
                            group.leave()
                        }
                    } else if articleContent.type == "link" {
                        articleContent.webTitle = sdoc.data()["content2"] as! String
                        articleContent.content = sdoc.data()["content1"] as! String
                        group.enter()
                        Storage.storage().reference().child(sdoc.data()["content3"] as! String).downloadURL { linkURL, _ in
                            if let linkURL = linkURL {
                                group.enter()
                                requestImageFromURLSession(url: linkURL as NSURL) { image in
                                    articleContent.imageData = image
                                    group.leave()
                                }
                            }
                            group.leave()
                        }
                    } else {
                        articleContent.content = sdoc.data()["content1"] as! String
                    }
                    
                    group.notify(queue: .main) {
                        articleContents.append(articleContent)
                    }
                }
            }
            group.leave()
            
            group.notify(queue: .main) {
                articleContents.sort { a, b in
                    return a.index < b.index
                }
                completion(articleContents)
            }
        }
    }
}
