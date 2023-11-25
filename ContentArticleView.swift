//
//  ArticleView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/09/07.
//

import SwiftUI
import FirebaseFirestore

struct ContentArticleView: View {
    
    @State var viewOpacity = Double(0)
    @State var thisName = "ContentArticleView"
    @State var showImageBool = false
    @State var favBool = false
    @State var checkWeb = false
    @State var showImageName = UIImage()
    @State var favCount = 0
    @State var showImageOpacity = 0.0
    @State var barHidden = false
    @State var listener: ListenerRegistration?
    @StateObject var contentInfo: ContentInfo
    var backgroundImage: UIImage
    var aspectFit: Bool
    @Binding var gotContent: Bool
    @EnvironmentObject var name: Name
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var music: Music
    @EnvironmentObject var accountInfo: AccountInfo
    
    var body: some View {
        ZStack(alignment: .top) {
            ContentBackgroundImage(image: backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.2, aspectFit: aspectFit)
            
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Title(title: contentInfo.name, size: 36.0)
                    
                    HStack {
                        NavigationLink(destination: OtherAccountView(accountID: contentInfo.createdUserID)) {
                            Account(image: contentInfo.backgroundImage, name: contentInfo.createdUserName, imageSize: 45, textSize: 16)
                                .padding(.top, 20)
                        }
                        
                        Spacer()
                    }
                    
                    ForEach(0..<contentInfo.articleContents.count, id: \.self) { i in
                        ContentArticleSubView(i: i, showImageName: $showImageName, checkWeb: $checkWeb, showImageBool: $showImageBool, contentInfo: contentInfo)
                            .padding(.top, 40)
                    }
                }
                .padding([.leading, .trailing], 20)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 50)
            }
            .opacity(viewOpacity)
            .ignoresSafeArea()
            
            GradientNavigationBar()
            
            if showImageBool {
                ShowImageView(image: showImageName, showImageBool: $showImageBool, barHidden: $barHidden, preName: $thisName, opacity: $showImageOpacity)
                    .opacity(showImageOpacity)
            }
        }
        .onWillAppear {
            name.name = "ContentArticleView"
            if gotContent == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.viewOpacity = 1
                    }
                }
            }
            
            let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
            listener = ref.addSnapshotListener { snapshot, err in
                guard let snapshot = snapshot else { return }
                guard let users = snapshot.data()?["likes"] as? [String] else { return }
                favCount = users.count
                if users.contains(accountInfo.id) {
                    favBool = true
                } else {
                    favBool = false
                }
            }
        }
        .onWillDisappear {
            listener?.remove()
        }
        .onChange(of: gotContent, perform: { value in
            if value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.viewOpacity = 1
                    }
                }
            }
        })
        .background(.black)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
                    if favBool == false {
                        ref.updateData([
                            "likes": FieldValue.arrayUnion([accountInfo.id])
                        ])
                    } else {
                        ref.updateData([
                            "likes": FieldValue.arrayRemove([accountInfo.id])
                        ])
                    }
                }) {
                    HStack {
                        switch favBool {
                        case true:
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                        case false:
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                        }
                        
                        Text("\(favCount)")
                            .foregroundColor(.white)
                    }
                    .card()
                }
                
                Button(action: {
                    music.pauseBool.toggle()
                }) {
                    if music.pauseBool {
                        Image(systemName: "speaker.slash")
                            .foregroundColor(.white)
                            .card()
                    } else {
                        Image(systemName: "speaker")
                            .foregroundColor(.white)
                            .card()
                    }
                }
                
                if contentInfo.createdUserID != accountInfo.id {
                    ReportButton(accountID: accountInfo.id, contentType: "article", contentID: contentInfo.id, contentName: contentInfo.name)
                }
            }
        }
        .fullScreenCover(isPresented: $checkWeb) {
            WebView(viewName: thisName, addBool: false, showWebView: ShowWebView(url: webViewVar.nowURL))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentArticleSubView: View {
    
    var i: Int = 0
    @Binding var showImageName: UIImage
    @Binding var checkWeb: Bool
    @Binding var showImageBool: Bool
    @StateObject var contentInfo: ContentInfo
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    var body: some View {
        switch contentInfo.articleContents[i].type {
        case "image":
            ZStack(alignment: .topTrailing) {
                Image(uiImage: contentInfo.articleContents[i].imageData)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageFrame(image: contentInfo.articleContents[i].imageData).width, height: imageFrame(image: contentInfo.articleContents[i].imageData).height)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                    .gesture(TapGesture().onEnded({ _ in
                        showImageName = contentInfo.articleContents[i].imageData
                        withAnimation(.easeOut(duration: 0.3)) {
                            showImageBool.toggle()
                        }
                    }))
            }
        case "text":
            Text(contentInfo.articleContents[i].content)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.leading)
                .card()
        case "title":
            HStack {
                Spacer()
                
                Text(contentInfo.articleContents[i].content)
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                
                Spacer()
            }
        case "link":
            Button(action: {
                webViewVar.nowURL = contentInfo.articleContents[i].content
                checkWeb = true
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.7))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
                        .cornerRadius(15)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contentInfo.articleContents[i].webTitle)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(contentInfo.articleContents[i].content)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))
                                .lineLimit(1)
                        }
                        .padding([.top, .bottom], 8)
                        
                        Spacer()
                        
                        Image(uiImage: contentInfo.articleContents[i].imageData)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 40)/5 - 16, height: (UIScreen.main.bounds.size.width - 40)/5 - 16)
                            .cornerRadius(10)
                    }
                    .padding([.leading, .trailing], 8)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
            
        default:
            EmptyView()
        }
    }
    
    func imageFrame(image: UIImage) -> CGRect {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: image.size.height*(UIScreen.main.bounds.size.width - 40)/image.size.width)
        
        return frame
    }
}
