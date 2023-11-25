//
//  CreateArticleView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/30.
//

import SwiftUI
import Photos
import FirebaseFirestore
import FirebaseStorage

struct CreateArticleView: View {
    
    let image: UIImage
    @StateObject var parentContent: ContentInfo
    let menuArray: [(image: String, name: String)] = [("character", NSLocalizedString("Title", comment: "")), ("doc.plaintext", NSLocalizedString("Text", comment: "")), ("photo", NSLocalizedString("Image", comment: "")), ("link", NSLocalizedString("Link", comment: ""))]
    @State var thisName = "CreateArticleView"
    @State var preName = ""
    @State var addBool = false
    @State var photoLibraryShow = false
    @State var goWeb = false
    @State var checkWeb = false
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var imageArray = [UIImage]()
    @State var postButtonBool = false
    @State var removeBool = false
    @State var addButtonHidden = false
    @State var choosePhotoSource = false
    @State var fileShow = false
    @State var menuHeight = CGFloat(250)
    @State var photoMenuHeight = CGFloat(0)
    @State var menuOpacity = 0.0
    @State var menuPadding = -20.0
    @State var titleHeight = CGFloat(52.0)
    @State var titlePadding = CGFloat(0.0)
    @State var fileurls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerimages = [UIImage]()
    @State var progressCount = Double(0)
    @State var progressOpacity = Double(0)
    @State var showProgress = false
    @StateObject var contentInfo = ContentInfo()
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var name: Name
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { _ in
                BackgroundUIImage(image: image, opacity: 0.2)
            
                ScrollViewReader { reader in
                    ScrollView {
                        VStack(spacing: 0) {
                            ZStack {
                                ContentTextingView(text: $contentInfo.name, height: $titleHeight, viewBottomHeight: $titlePadding, originalHeight: 52, fontSize: 28, fontWeight: .bold, textAlignment: .center, placeholder: NSLocalizedString("Title", comment: ""))
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: titleHeight)
                            }
                            .padding([.leading, .trailing], 20)
                            .padding(.bottom, 20)
                            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            
                            if contentInfo.articleContents.count > 0 {
                                ForEach(0..<contentInfo.articleContents.count, id: \.self) { i in
                                    VStack(spacing: 0) {
                                        HStack {
                                            Button(action: {
                                                removeContent(index: i)
                                            }) {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 17, height: 17)
                                                    .foregroundColor(.white)
                                                    .opacity(contentInfo.articleContents[i].opacity)
                                                    .card()
                                                    .padding(.leading, 20)
                                            }
                                            
                                            Spacer()
                                            
                                            if contentInfo.articleContents.count > 1 {
                                                switch i {
                                                case 0:
                                                    Button(action: {
                                                        sortDown(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.down")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.articleContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                
                                                case contentInfo.articleContents.count - 1:
                                                    Button(action: {
                                                        sortUp(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.up")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.articleContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                    
                                                default:
                                                    Button(action: {
                                                        sortUp(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.up")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.articleContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                    
                                                    Button(action: {
                                                        sortDown(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.down")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.articleContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.bottom, contentInfo.articleContents[i].buttonHeight/2)
                                        
                                        ArticleSubView(content: $contentInfo.articleContents[i], articleArray: $contentInfo.articleContents, postButtonBool: $postButtonBool, bottomHeight: $bottomHeight, checkWeb: $checkWeb, articleName: $contentInfo.name)
                                            .opacity(contentInfo.articleContents[i].opacity)
                                    }
                                }
                            }
                            
                            if addButtonHidden == false {
                                Button(action: {
                                    if addBool == false {
                                        addBool = true
                                    } else {
                                        removeMenu()
                                    }
                                }) {
                                    Text("+Add Element")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                        .padding([.top, .bottom], 3)
                                        .padding([.leading, .trailing], 10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                        .card()
                                        .padding(.top, 10)
                                }
                            }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.size.width, height: bottomHeight)
                                .foregroundColor(.clear)
                                .id(contentInfo.articleContents.count)
                        }
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + 40)
                    }
                    .onChange(of: contentInfo.articleContents.count) { count in
                        if removeBool != true {
                            withAnimation(.easeOut(duration: 0.15)) {
                                reader.scrollTo(count)
                            }
                        }
                    }
                    }
                    .ignoresSafeArea()
                }
            
            if addBool == true {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: menuHeight)
                        .foregroundColor(.white.opacity(0.7))
                        .cornerRadius(20)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Button(action: {
                            removeMenu()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.black)
                                .font(.system(size: 17, weight: .medium))
                        }
                        .padding(.trailing, 0)
                        .padding(.bottom, 10)
                        
                        VStack(spacing: 1) {
                            ForEach(0..<menuArray.count, id: \.self) { i in
                                Button(action: {
                                    switch i {
                                    case 0:
                                        contentInfo.articleContents.append(ArticleContent(type: "title", content: "", height: CGFloat(45), imageData: UIImage(), webTitle: "", index: contentInfo.articleContents.count))
                                        removeMenu()
                                    case 1:
                                        contentInfo.articleContents.append(ArticleContent(type: "text", content: "", height: CGFloat(80), imageData: UIImage(), webTitle: "", index: contentInfo.articleContents.count))
                                        removeMenu()
                                    case 2:
                                        if choosePhotoSource == false {
                                            choosePhotoSource.toggle()
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                photoMenuHeight = 80
                                                menuHeight += photoMenuHeight
                                            }
                                        } else {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                photoMenuHeight = 0
                                                menuHeight -= 80
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                choosePhotoSource.toggle()
                                            }
                                        }
                                    default:
                                        goWeb = true
                                        removeMenu()
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                                            .foregroundColor(.black.opacity(0.7))
                                        
                                        HStack {
                                            Text(menuArray[i].name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .medium))
                                                .padding(.leading, 20)
                                            
                                            Spacer()
                                            
                                            Image(systemName: menuArray[i].image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 22, height: 22)
                                                .foregroundColor(.white)
                                                .padding(.trailing, 20)
                                        }
                                    }
                                }
                                
                                if choosePhotoSource && i == 2 {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 20) {
                                            Button(action: {
                                                photoLibraryShow.toggle()
                                                removeMenu()
                                            }) {
                                                Text("Select from Photo Library")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16, weight: .medium))
                                            }
                                            
                                            Button(action: {
                                                fileShow.toggle()
                                                removeMenu()
                                            }) {
                                                Text("Select from File")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 17, weight: .medium))
                                            }
                                        }
                                        .padding(.leading, 40)
                                        
                                        Spacer()
                                    }
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: photoMenuHeight)
                                    .background(.black.opacity(0.7))
                                    .padding(.top, -1)
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 60)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 10)
                }
                .opacity(menuOpacity)
                .padding(.bottom, menuPadding)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        menuOpacity = 1.0
                        menuPadding = 20.0
                    }
                }
                .gesture(DragGesture(coordinateSpace: .global).onEnded({ value in
                    if value.translation.height > 30 {
                        removeMenu()
                    }
                 }))
            }
            
            if showProgress {
                UploadProgressView(progressCount: $progressCount)
                    .opacity(progressOpacity)
            }
            
            GradientNavigationBar()
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    name.name = preName
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .onChange(of: progressCount, perform: { value in
            if value >= 100.0 {
                name.name = preName
                dismiss()
            }
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                switch postButtonBool {
                case true:
                    Button(action: {
                        showProgress.toggle()
                        withAnimation(.easeOut(duration: 0.3)) {
                            progressOpacity = 1.0
                        }
                        let uploadContentCount = contentInfo.articleContents.count
                        
                        let ref = Firestore.firestore().collection("contents")
                        let document = ref.addDocument(data: [
                            "name": contentInfo.name,
                            "style": contentInfo.contentStyle,
                            "createdDate": Date(),
                            "updatedDate": Date(),
                            "parentContent": parentContent.id,
                            "createdUser": accountInfo.id,
                            "likes": [String](),
                            "viewCount": 0
                        ])
                        
                        contentInfo.createdDate = Date()
                        contentInfo.updatedDate = Date()
                        contentInfo.createdUserID = accountInfo.id
                        contentInfo.createdUserName = accountInfo.name
                        contentInfo.id = document.documentID
                        contentInfo.backgroundImage = accountInfo.iconImage
                        contentInfo.gotContent = true
                        
                        let articleRef = document.collection("articleContent")
                        let group = DispatchGroup()
                        
                        for (index, i) in contentInfo.articleContents.enumerated() {
                            group.enter()
                            DispatchQueue(label: "uploadArticle").async {
                                switch i.type {
                                case "title":
                                    articleRef.addDocument(data: [
                                        "content1" : i.content,
                                        "type": i.type,
                                        "index": index
                                    ])
                                    progressCount += 100 / Double(uploadContentCount)
                                case "text":
                                    articleRef.addDocument(data: [
                                        "content1" : i.content,
                                        "type": i.type,
                                        "index": index
                                    ])
                                    progressCount += 100 / Double(uploadContentCount)
                                case "image":
                                    let imgData = compressImageData(image: i.imageData)
                                    let d = articleRef.addDocument(data: [
                                        "content1" : "",
                                        "type": i.type,
                                        "index": index
                                    ])
                                    var imageProgress = Double(0)
                                    group.enter()
                                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/articles/\(d.documentID)/image\(index)_\(UUID()).png", data: imgData, type: "image/png", document: articleRef.document(d.documentID), contentName: "content1") { progress, status in
                                        progressCount += (progress - imageProgress) / Double(uploadContentCount)
                                        imageProgress = progress
                                        if status == "failed" {
                                            group.leave()
                                        } else if status == "succeeded" {
                                            group.leave()
                                        }
                                    }
                                case "link":
                                    let imgData = i.imageData.jpegData(compressionQuality: 0.1) ?? Data()
                                    let d = articleRef.addDocument(data: [
                                        "content1" : i.content,
                                        "content2": i.webTitle,
                                        "content3": "",
                                        "type": i.type,
                                        "index": index
                                    ])
                                    var linkProgress = Double(0)
                                    group.enter()
                                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/articles/\(d.documentID)/link\(index)_\(UUID()).png", data: imgData, type: "image/png", document: articleRef.document(d.documentID), contentName: "content3") { progress, status in
                                        progressCount += (progress - linkProgress) / Double(uploadContentCount)
                                        linkProgress = progress
                                        if status == "failed" {
                                            group.leave()
                                        } else if status == "succeeded" {
                                            group.leave()
                                        }
                                    }
                                default:
                                    break
                                }
                                group.leave()
                            }
                            
                            group.notify(queue: .main) {
                                if index == contentInfo.articleContents.count - 1 {
                                    parentContent.thisArticles.append(contentInfo)
                                    parentContent.thisArticles.sort { a, b in
                                        return a.likes.count > b.likes.count
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        if progressCount < 100 {
                                            name.name = preName
                                            dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundColor(.white)
                            .card()
                    }
                    
                case false:
                    Image(systemName: "paperplane")
                        .foregroundColor(.white.opacity(0.5))
                        .card()
                }
            }
        }
        .background(.black)
        .onWillAppear {
            preName = name.name
            DispatchQueue.main.async {
                name.name = thisName
                contentInfo.contentStyle = "article"
            }
        }
        .onChange(of: contentInfo.articleContents.count, perform: { _ in
            postButtonCondition()
        })
        .onChange(of: contentInfo.name, perform: { _ in
            postButtonCondition()
        })
        .sheet(isPresented: $photoLibraryShow) {
            PHPicker(urls: $pickerurls, images: $pickerimages)
        }
        .onChange(of: photoLibraryShow, perform: { value in
            if value == false && pickerimages.count > 0 {
                for i in pickerimages {
                    contentInfo.articleContents.append(ArticleContent(type: "image", height: i.size.height*(UIScreen.main.bounds.size.width - 40)/i.size.width, imageData: i, index: contentInfo.articleContents.count))
                }
                pickerimages.removeAll()
                pickerurls.removeAll()
            }
        })
        .sheet(isPresented: $fileShow, content: {
            FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
        })
        .onChange(of: fileShow, perform: { value in
            if value == false && fileurls.count > 0 {
                do {
                    let data = try Data(contentsOf: fileurls[0])
                    guard let image = UIImage(data: data) else { return }
                    contentInfo.articleContents.append(ArticleContent(type: "image", height: image.size.height*(UIScreen.main.bounds.size.width - 40)/image.size.width, imageData: image, index: contentInfo.articleContents.count))
                } catch {
                    print("Failed to get image from url.")
                }
                fileurls.removeAll()
            }
        })
        .onChange(of: goWeb, perform: { value in
            if value == false && webViewVar.nowURL != "" {
                contentInfo.articleContents.append(ArticleContent(type: "link", content: webViewVar.nowURL, height: CGFloat(0), imageData: webViewVar.image, webTitle: webViewVar.title, index: contentInfo.articleContents.count))
                
                webViewVar.nowURL = ""
                webViewVar.title = ""
                webViewVar.image = UIImage()
                webViewVar.goB = false
                webViewVar.goF = false
            }
        })
        .fullScreenCover(isPresented: $goWeb) {
            WebView(viewName: "CreateArticleView", addBool: true, showWebView: ShowWebView(url: "https://google.com"))
        }
        .fullScreenCover(isPresented: $checkWeb) {
            WebView(viewName: "CreateArticleView", addBool: false, showWebView: ShowWebView(url: webViewVar.nowURL))
        }
    }
    
    func sortUp(i: Int) {
        removeBool = true
        
        let content = contentInfo.articleContents.remove(at: i-1)
        contentInfo.articleContents.insert(content, at: i)
        
        contentInfo.articleContents[i].opacity = 0
        contentInfo.articleContents[i-1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                contentInfo.articleContents[i].opacity = 1
                contentInfo.articleContents[i-1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func sortDown(i: Int) {
        removeBool = true
        
        let content = contentInfo.articleContents.remove(at: i)
        contentInfo.articleContents.insert(content, at: i+1)
        
        contentInfo.articleContents[i].opacity = 0
        contentInfo.articleContents[i+1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                contentInfo.articleContents[i].opacity = 1
                contentInfo.articleContents[i+1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func removeContent(index: Int) {
        removeBool = true
        withAnimation(.easeOut(duration: 0.3)) {
            contentInfo.articleContents[index].opacity = 0
            contentInfo.articleContents[index].buttonHeight = -(contentInfo.articleContents[index].height + 100.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            contentInfo.articleContents.remove(at: index)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            removeBool = false
        }
    }
   
    func removeMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            menuOpacity = 0.0
            menuPadding = -20.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            addBool = false
            choosePhotoSource = false
            photoMenuHeight = 0.0
            menuHeight = 250
        }
    }
    
    func postButtonCondition() {
        if contentInfo.name != "" && contentInfo.articleContents.count > 0 {
            var typeBool = false
            for i in contentInfo.articleContents {
                if i.type != "title" && i.type != "text" {
                    typeBool = true
                } else {
                    if i.content != "" {
                        typeBool = true
                    }
                }
            }
            
            if typeBool == true {
                postButtonBool = true
            } else {
                postButtonBool = false
            }
        } else {
            postButtonBool = false
        }
    }
}

//struct CreateArticleView_Previews: PreviewProvider {
    //static var previews: some View {
        //CreateArticleView()
    //}
//}

struct ArticleSubView: View {
    
    @Binding var content: ArticleContent
    @Binding var articleArray: [ArticleContent]
    @Binding var postButtonBool: Bool
    @Binding var bottomHeight: CGFloat
    @Binding var checkWeb: Bool
    @Binding var articleName: String
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    var body: some View {
        switch content.type {
        case "title":
            ContentTextingView(text: $content.content, height: $content.height, viewBottomHeight: $bottomHeight, originalHeight: 45, fontSize: 24, fontWeight: .semibold, textAlignment: .center, placeholder: "Title")
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .padding([.leading, .trailing], 20)
                .padding(.top, 10)
                .padding(.bottom, content.buttonHeight)
                .onChange(of: content.content, perform: { _ in
                    postButtonCondition()
                })
        case "text":
            ContentTextingView(text: $content.content, height: $content.height, viewBottomHeight: $bottomHeight)
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .padding(.top, 10)
                .padding(.bottom, content.buttonHeight)
                .onChange(of: content.content, perform: { _ in
                    postButtonCondition()
                })
        case "image":
            Image(uiImage: content.imageData)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .cornerRadius(20)
                .card()
                .padding(.top, 10)
                .padding(.bottom, content.buttonHeight)
        default:
            Button(action: {
                webViewVar.nowURL = content.content
                checkWeb = true
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
                        .cornerRadius(15)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(content.webTitle)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(content.content)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .regular))
                                .lineLimit(1)
                        }
                        .padding([.top, .bottom], 8)
                        
                        Spacer()
                        
                        Image(uiImage: content.imageData)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 40)/5 - 16, height: (UIScreen.main.bounds.size.width - 40)/5 - 16)
                            .cornerRadius(10)
                    }
                    .padding([.leading, .trailing], 8)
                }
            }
            .opacity(content.opacity)
            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
            .padding(.top, 10)
            .padding(.bottom, content.buttonHeight)
        }
    }
    
    func postButtonCondition() {
        if articleName != "" && articleArray.count > 0 {
            var typeBool = false
            for i in articleArray {
                if i.type != "title" && i.type != "text" {
                    typeBool = true
                } else {
                    if i.content != "" {
                        typeBool = true
                    }
                }
            }
            
            if typeBool == true {
                postButtonBool = true
            } else {
                postButtonBool = false
            }
        } else {
            postButtonBool = false
        }
    }
}
