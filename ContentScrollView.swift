//
//  ContentScrollView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ContentScrollView: View {
    
    @State var opacity = Double(0)
    @State var infoOpacity = Double(0)
    @State var thisName = "ContentScrollView"
    @State var showImageBool = false
    @State var infoBool = false
    @State var favBool = false
    @State var videoChangedBool = false
    @State var imageNum = 0
    @State var showImageName = UIImage()
    @State var favCount = 0
    @State var checkWeb = false
    @State var barHidden = true
    @State var showImageOpacity = 0.0
    @State var chatPoint = -1
    @State var viewCount = 0
    @State var editContent = false
    @State private var listener: ListenerRegistration?
    @EnvironmentObject var name: Name
    @StateObject var contentInfo: ContentInfo
    @StateObject var forEditContentInfo: ContentInfo = ContentInfo()
    @EnvironmentObject var music: Music
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var tabBarHidden: TabBarHidden
    @Binding var gotContent: Bool
    @StateObject var loadObserver = LoadObserver()
    @StateObject var category: ContentCategory = ContentCategory()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            ContentBackgroundImage(image: contentInfo.backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.25, aspectFit: contentInfo.backgroundAspectFit)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    Title(title: contentInfo.name, size: 36.0)
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .padding([.leading, .trailing], 20)
                    
                    ForEach(0..<contentInfo.scrollContents.count, id: \.self) { i in
                        ContentScrollSubView(videoChangedBool: $videoChangedBool, showImageName: $showImageName, checkWeb: $checkWeb, showImageBool: $showImageBool, contentInfo: contentInfo, content: contentInfo.scrollContents[i])
                            .padding([.leading, .trailing], 20)
                    }
                    
                    ArticleView(parentContent: contentInfo, backgroundImage: $contentInfo.backgroundImage, aspectFit: contentInfo.backgroundAspectFit, contentCategory: category)
                        .padding(.top, UIScreen.main.bounds.size.height/2)
                }
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 50)
            }
            .opacity(opacity)
            
            if barHidden == false {
                GradientNavigationBar()
            }
            
            if infoBool {
                ZStack {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .foregroundColor(.black.opacity(0.4))
                
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
        .fullScreenCover(isPresented: $checkWeb) {
            WebView(viewName: thisName, addBool: false, showWebView: ShowWebView(url: webViewVar.nowURL))
        }
        .onChange(of: gotContent, perform: { value in
            if value {
                setForEditContentInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.opacity = 1
                        playBackgroundMusic()
                    }
                }
                
                withAnimation(.linear(duration: 0.3)) {
                    loadObserver.opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    loadObserver.isLoading = false
                }
            }
        })
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
                
                name.name = thisName
                if gotContent == true {
                    setForEditContentInfo()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.opacity = 1
                            playBackgroundMusic()
                        }
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
            } else {
                name.name = "ContentInfoView"
            }
            
            tabBarHidden.hidden = barHidden
            chatPoint = -1
        }
        .onWillDisappear {
            listener?.remove()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
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
                                showImageName = contentInfo.backgroundImage
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
                            contentInfo.isFavorite = true
                        } else {
                            ref.updateData([
                                "likes": FieldValue.arrayRemove([accountInfo.id])
                            ])
                            contentInfo.isFavorite = false
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
        .onChange(of: editContent, perform: { value in
            if value == false && name.name == "ContentScrollPreView" {
                contentInfo.scrollContents = forEditContentInfo.scrollContents
                contentInfo.name = forEditContentInfo.name
                contentInfo.explanation = forEditContentInfo.explanation
                contentInfo.updatedDate = forEditContentInfo.updatedDate
                contentInfo.backgroundImage = forEditContentInfo.backgroundImage
                contentInfo.backgroundAspectFit = forEditContentInfo.backgroundAspectFit
                contentInfo.music = forEditContentInfo.music
                contentInfo.musicData = forEditContentInfo.musicData
                contentInfo.loopPlay = forEditContentInfo.loopPlay
            } else if value == false && name.name == "CreateContentView" {
                contentInfo.deleted = forEditContentInfo.deleted
                dismiss()
            }
            
            if value == false {
                setForEditContentInfo()
            }
        })
        .fullScreenCover(isPresented: $editContent, content: {
            NavigationView {
                CreateContentView(info: forEditContentInfo, isPresent: $editContent)
            }
            .accentColor(.white)
        })
        .edgesIgnoringSafeArea(.all)
    }
    
    func setForEditContentInfo() {
        forEditContentInfo.scrollContents = contentInfo.scrollContents
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
    
    func infoButtonFunc() {
        if infoBool == false {
            infoBool.toggle()
            withAnimation(.linear(duration: 0.3)) {
                opacity = 0.0
                infoOpacity = 1.0
            }
        } else {
            withAnimation(.linear(duration: 0.3)) {
                opacity = 1.0
                infoOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.infoBool.toggle()
            }
        }
    }
    
    func playBackgroundMusic() {
        if music.musicMuteBool {
            playAudio.playAudioFromData(data: contentInfo.musicData, muteBool: false, loop: contentInfo.loopPlay)
            music.musicURL = contentInfo.music
            music.musicLoop = contentInfo.loopPlay
            music.musicMuteBool = false
            music.pauseBool = false
            music.finished = false
            music.listIndex = -1
        }
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
}

//struct ContentScrollView_Previews: PreviewProvider {
    //static var previews: some View {
       // ContentScrollView().edgesIgnoringSafeArea(.all)
   // }
//}


struct ContentInfoView: View {
    
    @StateObject var contentInfo: ContentInfo
    @State var createdDate = ""
    @State var updatedDate = ""
    @State var goWorld = false
    @State var showWorldButton = true
    @StateObject var worldInfo = WorldInfo()
    @Binding var viewCount: Int
    @ObservedObject var category: ContentCategory = ContentCategory()
    
    var body: some View {
        NavigationLink(destination: CreatorHomeView(worldInfo: worldInfo), isActive: $goWorld) {
            EmptyView()
        }
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    
                    Title(title: contentInfo.name, size: 32)
                    
                    Spacer()
                }
                
                Text(contentInfo.explanation)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                    .card()
                    .padding(.top, 40)
                    .padding([.leading, .trailing], 20)
                
                Text("Creator")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .card()
                    .padding(.top, 40)
                    .padding([.leading, .trailing], 20)
                
                NavigationLink(destination: OtherAccountView(accountID: contentInfo.createdUserID)) {
                    HStack(spacing: 16) {
                        Image(uiImage: contentInfo.createdUserIcon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 60)/4, height: (UIScreen.main.bounds.size.width - 60)/4)
                            .clipShape(Circle())
                        
                        Text(contentInfo.createdUserName)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
                .card()
                .padding(.top, 24)
                .padding([.leading, .trailing], 20)
                
                if showWorldButton {
                    Button(action: {
                        let ref = Firestore.firestore().collection("world").document(contentInfo.parentWorld)
                        ref.getDocument { snapshot, _ in
                            guard let d = snapshot else { return }
                            
                            worldInfo.id = d.documentID
                            worldInfo.name = d.data()!["name"] as! String
                            worldInfo.explanation = d.data()!["description"] as! String
                            let backgroundImage = d.data()!["backgroundImage"] as! String
                            worldInfo.backgroundURL = backgroundImage
                            worldInfo.bgm = d.data()!["bgm"] as! String
                            worldInfo.bgmName = d.data()!["bgmName"] as! String
                            worldInfo.tags = d.data()!["tags"] as! [String]
                            worldInfo.category = d.data()!["categories"] as! [String]
                            let createdDate = d.data()!["createdDate"] as! Timestamp
                            let updatedDate = d.data()!["updatedDate"] as! Timestamp
                            worldInfo.createdDate = createdDate.dateValue()
                            worldInfo.updatedDate = updatedDate.dateValue()
                            let storage = Storage.storage()
                            let group = DispatchGroup()
                            
                            worldInfo.createdUser = contentInfo.createdUserID
                            worldInfo.createdUserName = contentInfo.createdUserName
                            worldInfo.createdUserIcon = contentInfo.createdUserIcon
                            
                            if backgroundImage != "" {
                                group.enter()
                                storage.reference(forURL: backgroundImage).getData(maxSize: 1024 * 1024 * 10) { data, err in
                                    if let err = err {
                                        print("Error: \(err)")
                                    } else if let data = data {
                                        worldInfo.backgroundImage = UIImage(data: data) ?? UIImage()
                                    }
                                    group.leave()
                                }
                            }
                            
                            group.notify(queue: .main) {
                                goWorld.toggle()
                            }
                        }
                    }) {
                        Text("Go to world this content is in")
                            .underline()
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .card()
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.top, 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(viewCount)")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Views")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                    }
                    
                    HStack {
                        Text("\(contentInfo.thisArticles.count)")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Articles")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                    }
                    
                    HStack {
                        Text("Created Date")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                        
                        Text(createdDate)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    HStack {
                        Text("Updated Date")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                        
                        Text(updatedDate)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .card()
                .padding(.top, 120)
                .padding(.leading, 20)
            }
            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 40)
        }
        .onWillAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            createdDate = formatter.string(from: contentInfo.createdDate)
            updatedDate = formatter.string(from: contentInfo.updatedDate)
            
            if contentInfo.createdUserName == "" || contentInfo.createdUserIcon == UIImage(named: "black2") ?? UIImage() {
                getUserNameAndIcon(id: contentInfo.createdUserID) { name, icon in
                    contentInfo.createdUserName = name
                    contentInfo.createdUserIcon = icon
                }
            }
            
            if category.id != "" {
                showWorldButton = false
            }
        }
    }
    
    func contentCount(count: Int) -> Int {
        if count > 10 {
            return 10
        } else {
            return count
        }
    }
}
