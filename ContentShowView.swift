//
//  ContentShowView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/06.
//

import SwiftUI
import FirebaseFirestore

struct TextView: UIViewRepresentable {
    
    var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.layer.opacity = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            uiView.text = text
            uiView.layoutIfNeeded()
            uiView.setContentOffset(CGPoint(x: 0, y: -uiView.contentInset.top), animated: true)
            uiView.layer.opacity = 1
        }, completion: nil)
    }
}

extension UIImage {
    // image with rounded corners
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

struct ContentShowView: View {
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0.5), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
    @State var contentCount = 0
    @State var position = 0
    @State var boolen = true
    @State var titlePadding = UIScreen.main.bounds.size.height/4 + 20
    @State var titleOpacity = Double(0)
    @State var imagePadding = CGFloat(20)
    @State var imageOpacity = Double(0)
    @State var textOpacity = Double(0)
    @State var infoOpacity = Double(0)
    @State var articleOpacity = Double(0)
    @State var infoBool = false
    @State var tapBool = false
    @State var backgroundOpacity = Double(1)
    @State var backgroundOpacity2 = Double(0)
    @State var appearBool = false
    @State var titleSize = CGFloat(36)
    @State var indicatorOpacity = Double(0)
    @State var indicatorPadding = UIScreen.main.bounds.size.height - (UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 80)
    @State var indicatorBool = true
    @State var articlePadding = UINavigationController().navigationBar.frame.size.height + statusBarSize() + 20
    @State var articleBool = false
    @State var showImageBool = false
    @State var barHidden = true
    @State var isTitleShown = false
    @State var isImageShown = false
    @State var isTextShown = false
    @State var videoUpdate = false
    @State var favBool = false
    @State var favCount = 0
    @State var thisName = "ContentShowView"
    @State var showImageName = UIImage()
    @State var showImageOpacity = 0.0
    @State var chatPoint = -1
    @State var viewCount = 0
    @State var contentOpacity = 1.0
    @State var editContent = false
    @State private var listener: ListenerRegistration?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var name: Name
    @StateObject var contentInfo: ContentInfo
    @StateObject var forEditContentInfo: ContentInfo = ContentInfo()
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var tabBarHidden: TabBarHidden
    @StateObject var loadObserver = LoadObserver()
    @Binding var gotContent: Bool
    @StateObject var category: ContentCategory = ContentCategory()
    
    var body: some View {
        ZStack(alignment: .top) {
            if gotContent {
                if boolen == true {
                    if contentCount > 0 {
                        ContentBackgroundImage(image: contentInfo.showContents[contentCount-1].backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0, aspectFit: contentInfo.showContents[contentCount-1].backgroundAspectFit)
                    }
                } else {
                    if contentCount < contentInfo.showContents.count-1 {
                        ContentBackgroundImage(image: contentInfo.showContents[contentCount+1].backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0, aspectFit: contentInfo.showContents[contentCount+1].backgroundAspectFit)
                    }
                }
                
                ContentBackgroundImage(image: contentInfo.showContents[contentCount].backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0, aspectFit: contentInfo.showContents[contentCount].backgroundAspectFit)
                    .opacity(backgroundOpacity)
                    .onChange(of: contentCount) { newValue in
                        withAnimation(.easeOut(duration: 0.3)) {
                            backgroundOpacity = 1
                        }
                    }
                
                if indicatorBool == true {
                    VStack {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .card()
                        
                        Text("Swipe to Next")
                            .font(.system(size: 20, weight: .medium))
                            .card()
                    }
                    .foregroundColor(.white)
                    .opacity(indicatorOpacity)
                    .padding(.top, indicatorPadding)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.indicatorOpacity = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.7)) {
                                    self.indicatorPadding -= 40
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut(duration: 0.7)) {
                                    self.indicatorPadding += 40
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .center) {
                    Text(contentInfo.showContents[contentCount].title)
                        .animation(.none, value: contentCount)
                        .foregroundColor(.white)
                        .font(.system(size: titleSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, titlePadding)
                        .onAppear {
                            if appearBool == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.titlePadding -= 20
                                    }
                                }
                            }
                            
                            if contentInfo.showContents[contentCount].title != "" {
                                isTitleShown = true
                            } else {
                                isTitleShown = false
                            }
                        }
                        .onChange(of: contentCount, perform: { newValue in
                            withAnimation(.easeOut(duration: 0.3)) {
                                if boolen == true {
                                    titlePadding -= 20
                                } else {
                                    titlePadding += 20
                                }
                            }
                            
                            if contentInfo.showContents[newValue].title != "" {
                                isTitleShown = true
                            } else {
                                isTitleShown = false
                            }
                        })
                        .opacity(titleOpacity)
                        .onAppear(perform: {
                            if appearBool == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        self.titleOpacity = 1
                                    }
                                }
                            }
                        })
                        .onChange(of: contentCount, perform: { newValue in
                            withAnimation(.easeOut(duration: 0.3)) {
                                titleOpacity = 1
                            }
                        })
                        .card()
                        .padding([.leading, .trailing], 20)
                                            
                    ZStack(alignment: .top) {
                        ZStack {
                            switch contentInfo.showContents[contentCount].video {
                            case URL(fileURLWithPath: ""):
                                Image(uiImage: contentInfo.showContents[contentCount].image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(20)
                                    .frame(width: imageFrame(image: contentInfo.showContents[contentCount].image, title: contentInfo.showContents[contentCount].title).width, height: imageFrame(image: contentInfo.showContents[contentCount].image, title: contentInfo.showContents[contentCount].title).height)
                                    .animation(.none, value: contentCount)
                                    .shadow(color: .black, radius: 10, x: 0, y: 0)
                                    .gesture(TapGesture().onEnded({ _ in
                                        if contentInfo.showContents[contentCount].image.size.height > 0 {
                                            showImageName = contentInfo.showContents[contentCount].image
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                showImageBool.toggle()
                                            }
                                        }
                                    }))
                            default:
                                PlayVideoView(url: contentInfo.showContents[contentCount].video, didChange: $videoUpdate)
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40) * 9 / 16)
                                    .cornerRadius(20)
                                    .animation(.none, value: contentCount)
                                    .shadow(color: .black, radius: 10, x: 0, y: 0)
                            }
                        }
                        .padding(.top, imagePadding + 10)
                        .onAppear(perform: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                if appearBool == false {
                                    imagePadding -= 20
                                }
                            }
                            
                            if contentInfo.showContents[contentCount].image != UIImage() {
                                isImageShown = true
                            } else {
                                isImageShown = false
                            }
                        })
                        .onChange(of: contentCount, perform: { newValue in
                            withAnimation(.easeOut(duration: 0.3)) {
                                if boolen == true {
                                    imagePadding -= 20
                                } else {
                                    imagePadding += 20
                                }
                            }
                            
                            if contentInfo.showContents[contentCount].image != UIImage() {
                                isImageShown = true
                            } else {
                                isImageShown = false
                            }
                        })
                        .opacity(imageOpacity)
                        .onAppear(perform: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                if appearBool == false {
                                    self.imageOpacity = 1
                                }
                            }
                        })
                        .onChange(of: contentCount, perform: { newValue in
                            withAnimation(.easeOut(duration: 0.3)) {
                                imageOpacity = 1
                            }
                        })
                        
                        VStack {
                            Spacer()
                            
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .fill(gradient)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
                                    .opacity(textOpacity)
                                    .onAppear(perform: {
                                        if appearBool == false {
                                            if contentInfo.showContents[contentCount].text != "" {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation(.easeOut(duration: 0.5)) {
                                                        self.textOpacity = 1
                                                    }
                                                }
                                            }
                                            
                                            if contentInfo.showContents[contentCount].text != "" {
                                                isTextShown = true
                                            } else {
                                                isTextShown = false
                                            }
                                        }
                                    })
                                    .onChange(of: contentCount) { newValue in
                                        if contentInfo.showContents[contentCount].text == "" {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                self.textOpacity = 0
                                            }
                                        } else {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                self.textOpacity = 1
                                            }
                                        }
                                        
                                        if contentInfo.showContents[contentCount].text != "" {
                                            isTextShown = true
                                        } else {
                                            isTextShown = false
                                        }
                                    }
                                    
                                TextView(text: contentInfo.showContents[contentCount].text)
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height/3)
                                    .padding([.leading, .trailing], 20)
                                    .padding(.top, UIScreen.main.bounds.size.height/10)
                                    .card()
                                    .opacity(textOpacity)
                                    .onAppear(perform: {
                                        if appearBool == false {
                                            if contentInfo.showContents[contentCount].text != "" {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation(.easeOut(duration: 0.5)) {
                                                        self.textOpacity = 1
                                                    }
                                                }
                                            }
                                        }
                                    })
                            }
                            .padding(.bottom, 0)
                        }
                    }
                }
                .opacity(contentOpacity)
                
                if contentCount == contentInfo.showContents.count - 1 {
                    ScrollView {
                        RefreshControl(coordinateSpaceName: "RefreshControl") {
                            minusContentCount()
                        }
                        
                        VStack {
                            Button(action: {
                                contentCount = 1
                                minusContentCount()
                            }) {
                                VStack {
                                    Image(systemName: "chevron.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                        .card()
                                    
                                    Text("Back to First")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                        .card()
                                }
                            }
                            .padding(.bottom, 10)
                            
                            ArticleView(parentContent: contentInfo, backgroundImage: $contentInfo.showContents.first?.backgroundImage ?? $contentInfo.backgroundImage, aspectFit: contentInfo.backgroundAspectFit, contentCategory: category)
                        }
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                        .padding(.top, articlePadding)
                        .opacity(articleOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.3)) {
                                if articleBool == false {
                                    articlePadding -= 20
                                }
                                articleOpacity = 1.0
                            }
                            articleBool = true
                        }
                    }
                    .coordinateSpace(name: "RefreshControl")
                    .opacity(contentOpacity)
                }
            } else {
                ContentBackgroundImage(image: contentInfo.backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0, aspectFit: contentInfo.backgroundAspectFit)
            }
            
            if barHidden == false {
                GradientNavigationBar()
            }
            
            if infoBool {
                ZStack {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .foregroundColor(.black.opacity(0.4))
                        .ignoresSafeArea()
                
                    ContentInfoView(contentInfo: contentInfo, viewCount: $viewCount, category: category)
                }
                .opacity(infoOpacity)
            }
            
            if loadObserver.isLoading {
                LoadingView()
                    .opacity(loadObserver.opacity)
            }
            
            if showImageBool {
                ShowImageView(image: showImageName, showImageBool: $showImageBool, barHidden: $barHidden, preName: $thisName, opacity: $showImageOpacity)
                    .opacity(showImageOpacity)
            }
        }
        .background(.black)
        .navigationTitle(Text(""))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if infoBool == false {
                    if barHidden == false {
                        Button(action: {
                            infoButtonFunc()
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                                .card()
                        }
                        
                        Button(action: {
                            barHidden = true
                            tabBarHidden.hidden = barHidden
                            if showImageBool == false {
                                showImageName = contentInfo.showContents[contentCount].backgroundImage
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showImageBool.toggle()
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showImageOpacity = 0.0
                                }
                                name.name = thisName
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showImageBool = false
                                }
                            }
                        }) {
                            Image(systemName: "rectangle.and.arrow.up.right.and.arrow.down.left")
                                .foregroundColor(.white)
                                .card()
                        }
                        
                        Button(action: {
                            music.pauseBool.toggle()
                            if music.musicMuteBool == true {
                                music.musicMuteBool = false
                            }
                        }) {
                            if music.pauseBool == true {
                                Image(systemName: "speaker.slash")
                                    .foregroundColor(.white)
                                    .card()
                            } else {
                                Image(systemName: "speaker")
                                    .foregroundColor(.white)
                                    .card()
                            }
                        }
                        
                        if contentInfo.createdUserID == accountInfo.id {
                            Button(action: {
                                editContent.toggle()
                            }) {
                                Image(systemName: "gear")
                                    .foregroundColor(.white)
                                    .card()
                            }
                        }
                    }
                        
                    Button(action: {
                        barHidden.toggle()
                        tabBarHidden.hidden = barHidden
                    }) {
                        switch barHidden {
                        case true:
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .foregroundColor(.white)
                                .card()
                        case false:
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.white)
                                .card()
                        }
                    }
                } else {
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
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            case false:
                                Image(systemName: "star")
                                    .foregroundColor(.white)
                            }
                                
                            Text("\(favCount)")
                                .foregroundColor(.white)
                        }
                        .card()
                    }
                    
                    if contentInfo.createdUserID != accountInfo.id {
                        ReportButton(accountID: accountInfo.id, contentType: "content", contentID: contentInfo.id, contentName: contentInfo.name)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if barHidden == false {
                    if infoBool == false {
                        CustomBackButtonView()
                    } else {
                        Button(action: {
                            infoButtonFunc()
                        }) {
                            Image(systemName: "multiply")
                                .foregroundColor(.white)
                                .card()
                        }
                    }
                }
            }
        }
        .gesture(DragGesture(coordinateSpace: .global).onEnded({ value in
            if value.translation.height > 30 {
                minusContentCount()
                videoUpdate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    videoUpdate = false
                }
            } else if value.translation.height < -30 {
                indicatorBool = false
                if contentCount < contentInfo.showContents.count - 1 {
                    if contentInfo.showContents[contentCount + 1].musicData != Data() {
                        changeMusic(index: contentCount + 1)
                    }
                    
                    contentCount += 1
                    titleOpacity = 0
                    titlePadding = UINavigationController().navigationBar.frame.size.height+statusBarSize() + 30
                    imageOpacity = 0
                    imagePadding = 20
                    boolen = true
                    backgroundOpacity = 0
                    titleSize = 32
                }
                
                videoUpdate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    videoUpdate = false
                }
            }
            
            if value.translation.width > 70 {
                dismiss()
            }
         }))
        .onWillAppear {
            getArticle(parentContent: contentInfo)
            if contentInfo.thisArticles.count > 0 {
                for i in contentInfo.thisArticles {
                    if accountInfo.blockedUsers.contains(where: { $0 == i.createdUserID }) {
                        contentInfo.thisArticles.removeAll(where: { $0.createdUserID == i.createdUserID })
                    }
                }
            }
            
            if infoBool == false {
                DispatchQueue.main.async {
                    loadObserver.isLoading = true
                    withAnimation(.linear(duration: 0.3)) {
                        loadObserver.opacity = 1.0
                    }
                }
                
                if gotContent {
                    if let backgroundImage = contentInfo.showContents.first?.backgroundImage {
                        contentInfo.backgroundImage = backgroundImage
                    }
                    setForEditContentInfo()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if music.musicMuteBool {
                            changeMusic(index: contentCount)
                            music.musicMuteBool = false
                            music.pauseBool = false
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.appearBool = true
                    }
                    
                    withAnimation(.linear(duration: 0.3)) {
                        loadObserver.opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        loadObserver.isLoading = false
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
                    
                    viewCount = snapshot.data()?["viewCount"] as? Int ?? 0
                }
                
                name.name = "ContentShowView"
            } else {
                name.name = "ContentInfoView"
                barHidden = false
                indicatorBool = false
            }
            
            tabBarHidden.hidden = barHidden
            chatPoint = -1
        }
        .onWillDisappear {
            listener?.remove()
            barHidden = true
        }
        .onChange(of: gotContent, perform: { newValue in
            if newValue {
                if let backgroundImage = contentInfo.showContents.first?.backgroundImage {
                    contentInfo.backgroundImage = backgroundImage
                }
                setForEditContentInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if music.musicMuteBool {
                        changeMusic(index: contentCount)
                        music.musicMuteBool = false
                        music.pauseBool = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.appearBool = true
                }
                
                withAnimation(.linear(duration: 0.3)) {
                    loadObserver.opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    loadObserver.isLoading = false
                }
            }
        })
        .onChange(of: editContent, perform: { value in
            if value == false && name.name == "ContentShowPreView" {
                contentCount = 0
                contentInfo.showContents = forEditContentInfo.showContents
                contentInfo.showContents.append(ShowContent(index: contentInfo.showContents.count, backgroundImage: contentInfo.showContents[contentInfo.showContents.count - 1].backgroundImage, backgroundAspectFit: contentInfo.showContents[contentInfo.showContents.count - 1].backgroundAspectFit, music: contentInfo.showContents[contentInfo.showContents.count - 1].music, musicData: Data(), loopPlay: contentInfo.showContents[contentInfo.showContents.count - 1].loopPlay))
                contentInfo.name = forEditContentInfo.name
                contentInfo.explanation = forEditContentInfo.explanation
                contentInfo.updatedDate = forEditContentInfo.updatedDate
                contentInfo.backgroundImage = forEditContentInfo.backgroundImage
                contentInfo.backgroundAspectFit = forEditContentInfo.backgroundAspectFit
                contentInfo.music = forEditContentInfo.music
                contentInfo.musicData = forEditContentInfo.musicData
                contentInfo.loopPlay = forEditContentInfo.loopPlay
            } else if value == false && name.name == "CreateContentView" {
                dismiss()
            }
            
            if value == false {
                setForEditContentInfo()
            }
        })
        .fullScreenCover(isPresented: $editContent) {
            NavigationView {
                CreateContentView(info: forEditContentInfo, isPresent: $editContent)
            }
            .accentColor(.white)
        }
    }
    
    func setForEditContentInfo() {
        forEditContentInfo.showContents = contentInfo.showContents
        forEditContentInfo.showContents.removeLast()
        forEditContentInfo.name = contentInfo.name
        forEditContentInfo.id = contentInfo.id
        forEditContentInfo.explanation = contentInfo.explanation
        forEditContentInfo.createdUserName = contentInfo.createdUserName
        forEditContentInfo.createdDate = contentInfo.createdDate
        forEditContentInfo.updatedDate = contentInfo.updatedDate
        forEditContentInfo.createdUserID = contentInfo.createdUserID
        forEditContentInfo.backgroundImage = contentInfo.backgroundImage
        forEditContentInfo.backgroundAspectFit = contentInfo.backgroundAspectFit
        forEditContentInfo.music = contentInfo.music
        forEditContentInfo.musicData = contentInfo.musicData
        forEditContentInfo.loopPlay = contentInfo.loopPlay
        forEditContentInfo.contentStyle = contentInfo.contentStyle
        forEditContentInfo.thisArticles = contentInfo.thisArticles
        forEditContentInfo.parentWorld = contentInfo.parentWorld
        forEditContentInfo.parentCategory = contentInfo.parentCategory
        forEditContentInfo.gotContent = contentInfo.gotContent
        forEditContentInfo.likes = contentInfo.likes
    }
    
    func getArticle(parentContent: ContentInfo) {
        let ref = Firestore.firestore().collection("contents")
            .whereField("style", isEqualTo: "article")
            .whereField("parentContent", isEqualTo: parentContent.id)
        let group = DispatchGroup()
        
        group.enter()
        ref.getDocuments { snapshot, _ in
            if let snapshot = snapshot {
                for i in snapshot.documents {
                    let contentInfo = ContentInfo()
                    if parentContent.thisArticles.filter({ $0.id == i.documentID }).count == 0 {
                        contentInfo.name = i.data()["name"] as! String
                        contentInfo.id = i.documentID
                        contentInfo.contentStyle = i.data()["style"] as! String
                        let createdDate = i.data()["createdDate"] as! Timestamp
                        let updatedDate = i.data()["updatedDate"] as! Timestamp
                        contentInfo.createdDate = createdDate.dateValue()
                        contentInfo.updatedDate = updatedDate.dateValue()
                        contentInfo.createdUserID = i.data()["createdUser"] as! String
                        
                        if accountInfo.blockedUsers.contains(where: { $0 == contentInfo.createdUserID }) == false {
                            group.enter()
                            getUserNameAndIcon(id: contentInfo.createdUserID) { userName, iconImage in
                                contentInfo.createdUserName = userName
                                contentInfo.backgroundImage = iconImage
                                group.leave()
                            }
                            
                            group.notify(queue: .main) {
                                parentContent.thisArticles.append(contentInfo)
                            }
                        }
                    }
                    
                    if let sameIndex = parentContent.thisArticles.firstIndex(where: { $0.id == i.documentID }) {
                        parentContent.thisArticles[sameIndex].likes = i.data()["likes"] as! [String]
                    }
                }
                
                group.notify(queue: .main) {
                    for i in snapshot.documents {
                        for j in parentContent.thisArticles {
                            if i.documentID == j.id {
                                j.likes = i.data()["likes"] as! [String]
                            }
                        }
                    }
                }
            }
            group.leave()
            
            group.notify(queue: .main) {
                parentContent.thisArticles.sort { a, b in
                    return a.likes.count > b.likes.count
                }
            }
        }
    }
    
    func infoButtonFunc() {
        if infoBool == false {
            infoBool.toggle()
            withAnimation(.linear(duration: 0.3)) {
                infoOpacity = 1.0
                contentOpacity = 0.0
            }
        } else {
            withAnimation(.linear(duration: 0.3)) {
                infoOpacity = 0.0
                contentOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.infoBool.toggle()
            }
        }
    }
    
    func changeMusic(index: Int) {
        if String(data: contentInfo.showContents[index].musicData, encoding: .utf8) == "nothing" {
            music.musicMuteBool = true
            music.pauseBool = true
            music.musicURL = URL(fileURLWithPath: "")
        } else {
            if music.musicURL != contentInfo.showContents[index].music {
                music.musicURL = contentInfo.showContents[index].music
                music.musicLoop = contentInfo.showContents[index].loopPlay
                music.finished = false
                playAudio.playAudioFromData(data: contentInfo.showContents[index].musicData, muteBool: false, loop: contentInfo.showContents[index].loopPlay)
                if music.musicMuteBool {
                    music.musicMuteBool = false
                    music.pauseBool = false
                }
                if music.pauseBool == false {
                    music.listPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        music.listPressed = false
                    }
                }
            }
        }
    }
    
    func titleHeight(text: String) -> CGFloat {
        let width = UIScreen.main.bounds.size.width - 40
        let height = text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: titleSize, weight: .bold)], context: nil).height
        return height
    }
    
    func imageFrame(image: UIImage, title: String) -> CGRect {
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: image.size.height*(UIScreen.main.bounds.size.width - 40)/image.size.width)
        let nowTitleHeight = titleHeight(text: title)
        if 110 + nowTitleHeight + frame.size.height > UIScreen.main.bounds.height {
            let imageHeight = UIScreen.main.bounds.size.height - 110 - nowTitleHeight
            let imageWidth = imageHeight * image.size.width / image.size.height
            frame.size.width = imageWidth
            frame.size.height = imageHeight
        }
        
        return frame
    }
    
    func minusContentCount() {
        if contentCount > 0 {
            if contentInfo.showContents[contentCount - 1].musicData != Data() {
                changeMusic(index: contentCount - 1)
            } else {
                var containMusicIndex = contentCount - 1
                while containMusicIndex >= 0 {
                    if contentInfo.showContents[containMusicIndex].musicData != Data() {
                        changeMusic(index: containMusicIndex)
                        containMusicIndex = -1
                    } else {
                        containMusicIndex -= 1
                    }
                }
            }
            
            contentCount -= 1
            articlePadding = UINavigationController().navigationBar.frame.size.height+statusBarSize() + 20
            articleOpacity = 0.0
            articleBool = false
            titleOpacity = 0
            titlePadding = UINavigationController().navigationBar.frame.size.height+statusBarSize() - 10
            imageOpacity = 0
            imagePadding = -20
            boolen = false
            backgroundOpacity = 0
            titleSize = 32
        }
        
        if contentCount == 0 {
            if titlePadding != UIScreen.main.bounds.size.height/4 {
                titlePadding = UIScreen.main.bounds.size.height/4 - 20
            }
            titleSize = 36
        }
    }
}
