//
//  CreatorHomeView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/02/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import RealmSwift

struct CreatorHomeView: View {
    
    let realm = try! Realm()
    let gradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0, opacity: 0.6), Color(red: 0, green: 0, blue: 0, opacity: 0)]), startPoint: .bottom, endPoint: .top)
    @State var selection = 0
    @State var timer = Timer.publish(every: 1.1, on: .main, in: .common).autoconnect()
    @State var timerCount = 0
    @State var infoBool = false
    @State var settingBool = false
    @State var gotContent = false
    @State var worldDeleted = false
    @State var goSetting = false
    @State var followBool = false
    @State var contentOpacity = 1.0
    @State var infoOpacity = 0.0
    @State var categoryName = ""
    @State var categoryDescription = ""
    @State var createContent: (bool: Bool, categoryIndex: Int) = (false, 0)
    @State var viewOpacity = 0.0
    @State var followerCount = 0
    @State var contentCount = 0
    @State var listener: ListenerRegistration?
    @State var followerArray: [AccountInfo] = []
    @EnvironmentObject var name: Name
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @StateObject var loadObserver = LoadObserver()
    @StateObject var worldInfo: WorldInfo
    @Environment(\.dismiss) var dismiss
    let musicName = ""
    let loopCount = -1
   
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    NavigationLink(destination: OtherAccountView(accountID: worldInfo.createdUser)) {
                        Account(image: worldInfo.createdUserIcon, name: worldInfo.createdUserName, imageSize: 45, textSize: 16)
                            .card()
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize() + 10)
                    
                    HStack {
                        Spacer()
                        
                        Text(worldInfo.name)
                            .bold()
                            .shadow(color: .black, radius: 15, x: 0, y: 0)
                            .font(.system(size: 36))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing], 20)
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            if worldInfo.announcements.count > 0 {
                                TabView(selection: $selection) {
                                    if !worldInfo.announcements.isEmpty {
                                        ForEach(0..<worldInfo.announcements.count, id: \.self) { i in
                                            if worldInfo.announcements[i].categoryIndex < worldInfo.contentCategory.count {
                                                NavigationLink(destination: contentSegueView(contentInfo: worldInfo.contentCategory[worldInfo.announcements[i].categoryIndex].contents.filter( { $0.id == worldInfo.announcements[i].content } ).first ?? ContentInfo(), category: ContentCategory())) {
                                                    ZStack(alignment: .bottom) {
                                                        Image(uiImage: worldInfo.announcements[i].image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)*9/16)
                                                            .clipped()
                                                            .tag(i-1)
                                                        
                                                        Rectangle()
                                                            .fill(gradient)
                                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)*9/32)
                                                        
                                                        Text(worldInfo.announcements[i].name)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 20, weight: .semibold))
                                                            .multilineTextAlignment(.leading)
                                                            .lineLimit(2)
                                                            .card()
                                                            .padding(.bottom, 40)
                                                            .padding([.leading, .trailing], 10)
                                                    }
                                                }
                                                .simultaneousGesture(TapGesture().onEnded({ _ in
                                                    guard let content = worldInfo.contentCategory[worldInfo.announcements[i].categoryIndex].contents.filter( { $0.id == worldInfo.announcements[i].content } ).first else { return }
                                                    let iIndex = worldInfo.announcements[i].categoryIndex
                                                    guard let jIndex = worldInfo.contentCategory[iIndex].contents.firstIndex(where: { $0.id == worldInfo.announcements[i].content }) else { return }
                                                    
                                                    addViewCount(id: worldInfo.contentCategory[iIndex].contents[jIndex].id, collection: "contents")
                                                    
                                                    let group = DispatchGroup()
                                                    
                                                    if content.gotContent == false {
                                                        if content.contentStyle == "scroll" {
                                                            group.enter()
                                                            getScrollContents(contentInfo: worldInfo.contentCategory[iIndex].contents[jIndex]) { scrollContents, backgroundImage, musicData, musicURL in
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].scrollContents = scrollContents
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].backgroundImage = backgroundImage
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].music = musicURL
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].musicData = musicData
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].gotContent = true
                                                                group.leave()
                                                            }
                                                        } else if content.contentStyle == "show" {
                                                            group.enter()
                                                            getShowContents(contentInfo: worldInfo.contentCategory[iIndex].contents[jIndex]) { showContents in
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].showContents = showContents
                                                                worldInfo.contentCategory[iIndex].contents[jIndex].gotContent = true
                                                                group.leave()
                                                            }
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
                                    } else {
                                        EmptyView()
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle())
                                .transition(.slide)
                                .animation(.easeInOut(duration: 0.5), value: selection)
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width-40)*9/16)
                                .cornerRadius((UIScreen.main.bounds.size.width - 40)*0.05)
                                .shadow(color: .black, radius: 15, x: 0, y: 0)
                                .onReceive(timer, perform: { _ in
                                    if timerCount < 4 {
                                        timerCount += 1
                                    } else {
                                        if selection < 4 {
                                            selection += 1
                                        } else {
                                            selection = 0
                                        }
                                    }
                                })
                                .onChange(of: selection) { _ in
                                    timerCount = 0
                                }
                            }
                            
                            if settingBool {
                                NavigationLink(destination: EditAnnouncementView(worldInfo: worldInfo)) {
                                    Text("Edit Announcement")
                                        .font(.system(size: 20, weight: .medium))
                                        .padding([.top, .bottom], 3)
                                        .padding([.leading, .trailing], 10)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 2)
                                        }
                                        .foregroundColor(.white)
                                }
                                .card()
                                .padding(.top, 20)
                            }
                        }
                        .padding([.top, .bottom], 40)
                        
                        Spacer()
                    }
                    
                    NavigationLink(destination: ChatListView(worldInfo: worldInfo)) {
                        HStack {
                            Spacer()
                            
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 80, height: 80)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(40)
                                    
                                    Image(systemName: "ellipsis.bubble")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .card()
                                }
                                
                                Text("Forum")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .medium))
                                    .card()
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.bottom, 40)
                    
                    ForEach(0..<worldInfo.contentCategory.count, id: \.self) { i in
                        HStack {
                            Spacer()
                            
                            Text(worldInfo.contentCategory[i].name)
                                .font(.system(size: 28, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .card()
                            
                            Spacer()
                        }
                        .padding([.leading, .trailing], 20)
                        
                        HStack {
                            Spacer()
                            
                            Text(worldInfo.contentCategory[i].description)
                                .font(.system(size: 16, weight: .medium))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .foregroundColor(.white)
                                .card()
                            
                            Spacer()
                        }
                        .padding([.leading, .trailing], 20)
                        
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 10) {
                                ForEach(0..<numberOfContent(count: worldInfo.contentCategory[i].contents.count), id: \.self) { j in
                                    NavigationLink(destination: contentSegueView(contentInfo: worldInfo.contentCategory[i].contents[j], category: worldInfo.contentCategory[i])) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            if worldInfo.contentCategory[i].contents.count - 1 >= j {
                                                Image(uiImage: worldInfo.contentCategory[i].contents[j].backgroundImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: (UIScreen.main.bounds.width - 60)/3, height: (UIScreen.main.bounds.width - 60)/3)
                                                    .cornerRadius(((UIScreen.main.bounds.width - 60)/3)*0.15)
                                                    .card()
                                                
                                                Text(worldInfo.contentCategory[i].contents[j].name)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.white)
                                                    .frame(width: (UIScreen.main.bounds.width - 60)/3)
                                                    .lineLimit(2)
                                                    .card()
                                            }
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded({ _ in
                                        addViewCount(id: worldInfo.contentCategory[i].contents[j].id, collection: "contents")
                                        
                                        let group = DispatchGroup()
                                        if worldInfo.contentCategory[i].contents[j].gotContent == false {
                                            if worldInfo.contentCategory[i].contents[j].contentStyle == "scroll" {
                                                group.enter()
                                                getScrollContents(contentInfo: worldInfo.contentCategory[i].contents[j]) { scrollContents, backgroundImage, musicData, musicURL in
                                                    worldInfo.contentCategory[i].contents[j].scrollContents = scrollContents
                                                    worldInfo.contentCategory[i].contents[j].backgroundImage = backgroundImage
                                                    worldInfo.contentCategory[i].contents[j].music = musicURL
                                                    worldInfo.contentCategory[i].contents[j].musicData = musicData
                                                    worldInfo.contentCategory[i].contents[j].gotContent = true
                                                    group.leave()
                                                }
                                            } else if worldInfo.contentCategory[i].contents[j].contentStyle == "show" {
                                                group.enter()
                                                getShowContents(contentInfo: worldInfo.contentCategory[i].contents[j]) { showContents in
                                                    worldInfo.contentCategory[i].contents[j].showContents = showContents
                                                    worldInfo.contentCategory[i].contents[j].gotContent = true
                                                    group.leave()
                                                }
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
                            .frame(height: (UIScreen.main.bounds.width - 60)/3 + 65)
                            .padding([.leading, .trailing], 20)
                        }
                        .onChange(of: worldInfo.contentCategory[i].contents.count) { _ in
                            worldInfo.contentCategory[i].contents.sort { a, b in
                                return a.createdDate < b.createdDate
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: SeeMoreView(title: categoryName, explanation: categoryDescription, worldInfo: worldInfo, backgroundImage: worldInfo.contentCategory[i].backgroundImage, contents: worldInfo.contentCategory[i].contents)) {
                                Text("See more")
                                    .underline()
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .card()
                                    .padding(.bottom, 20)
                                    .padding(.top, 0)
                            }
                            .simultaneousGesture(TapGesture().onEnded({ _ in
                                categoryName = worldInfo.contentCategory[i].name
                                categoryDescription = worldInfo.contentCategory[i].description
                            }))
                            
                            Spacer()
                        }
                        
                        if settingBool {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    createContent = (true, i)
                                }) {
                                    Text("Do Creation")
                                        .font(.system(size: 20, weight: .medium))
                                        .padding([.top, .bottom], 3)
                                        .padding([.leading, .trailing], 10)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 2)
                                        }
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                            }
                            .card()
                            .padding(.bottom, 20)
                        }
                    }
                    
                    if settingBool {
                        HStack(spacing: 5) {
                            Spacer()
                            
                            NavigationLink(destination: EditCategoryView(worldInfo: worldInfo, backgroundImage: worldInfo.backgroundImage)) {
                                Text("Edit Category")
                                    .font(.system(size: 20, weight: .medium))
                                    .padding([.top, .bottom], 5)
                                    .padding([.leading, .trailing], 10)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 2)
                                    }
                                    .foregroundColor(.white)
                                    .card()
                            }
                            
                            Spacer()
                        }
                        .card()
                        .padding(.top, 20)
                        .padding([.leading, .trailing], 20)
                    }
                    
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                        .padding([.leading, .trailing], 20)
                        .padding(.top, 20)
                }
                .opacity(contentOpacity)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30)
            }
            .opacity(viewOpacity)
            
            if loadObserver.isLoading {
                LoadingView()
                    .opacity(loadObserver.opacity)
            }
            
            GradientNavigationBar()
            
            if infoBool {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        .foregroundColor(.black.opacity(0.4))
                        .ignoresSafeArea()
                    
                    CreatorHomeInfoView(followerCount: $followerCount, followBool: $followBool, contentCount: $contentCount, followerArray: $followerArray, backgroundImage: worldInfo.backgroundImage, worldInfo: worldInfo)
                }
                .opacity(infoOpacity)
            }
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    let ref = Firestore.firestore().collection("world").document(worldInfo.id)
                    if followBool == false {
                        ref.updateData([
                            "followers": FieldValue.arrayUnion([accountInfo.id]),
                            "followerTokens": FieldValue.arrayUnion(accountInfo.fcmTokens)
                        ])
                        worldInfo.following = true
                    } else {
                        ref.updateData([
                            "followers": FieldValue.arrayRemove([accountInfo.id]),
                            "followerTokens": FieldValue.arrayRemove(accountInfo.fcmTokens)
                        ])
                        worldInfo.following = false
                    }
                }) {
                    if followBool {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .card()
                    } else {
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                            .card()
                    }
                }
                
                Button(action: {
                    infoButtonFunc()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                        .card()
                }
                
                if settingBool {
                    Button(action: {
                        goSetting.toggle()
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .card()
                    }
                }
                
                Button(action: {
                    music.pauseBool.toggle()
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
                
                if settingBool == false {
                    ReportButton(accountID: accountInfo.id, contentType: "world", contentID: worldInfo.id, contentName: worldInfo.name)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                switch infoBool {
                case false:
                    CustomBackButtonView()
                case true:
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
        .fullScreenCover(isPresented: $createContent.bool, content: {
            NavigationView {
                CreateContentView(worldInfo: worldInfo, categoryIndex: createContent.categoryIndex, isPresent: $createContent.bool)
            }
            .accentColor(.white)
        })
        .fullScreenCover(isPresented: $goSetting, content: {
            NavigationView {
                EditWorldInfoView(worldInfo: worldInfo, deleted: $worldDeleted)
            }
            .accentColor(.white)
        })
        .onChange(of: goSetting, perform: { value in
            if value == false && music.musicURL != worldInfo.bgmURL {
                DispatchQueue.main.async {
                    music.musicMuteBool = true
                    music.pauseBool = true
                    music.musicLoop = false
                    music.musicURL = URL(fileURLWithPath: "")
                    music.listIndex = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    music.musicURL = worldInfo.bgmURL
                    music.musicLoop = true
                    music.musicMuteBool = false
                    music.pauseBool = false
                    music.finished = false
                    music.listIndex = -1
                    playAudio.playAudio(url: music.musicURL, muteBool: music.musicMuteBool, loop: true)
                }
            }
        })
        .pauseMusic(music: music, playAudio: playAudio)
        .onWillAppear {
            name.name = "CreatorHomeView"
            gotContent = false
            selection = 0
            
            DispatchQueue.main.async {
                loadObserver.isLoading = true
                withAnimation(.linear(duration: 0.3)) {
                    loadObserver.opacity = 1.0
                }
            }
            
            let storage = Storage.storage()
            let dispatchGroup = DispatchGroup()
            let ref = Firestore.firestore().collection("world").document(worldInfo.id)
            
            var resizedImageURL = worldInfo.backgroundURL
            if let resized = resizedImageURL.range(of: "_250x250.png") {
                resizedImageURL.replaceSubrange(resized, with: ".png")
            } else if let resized2 = resizedImageURL.range(of: "_500x500.png") {
                resizedImageURL.replaceSubrange(resized2, with: ".png")
            }
            
            if resizedImageURL != worldInfo.backgroundURL {
                worldInfo.backgroundURL = resizedImageURL
                storage.reference(forURL: resizedImageURL).getData(maxSize: 1024 * 1024 * 10) { data, _ in
                    guard let data = data else { return }
                    let image = UIImage(data: data) ?? UIImage(named: "black") ?? UIImage()
                    worldInfo.backgroundImage = image
                }
            }
            
            listener = ref.addSnapshotListener { snapshot, err in
                guard let snapshot = snapshot else { return }
                guard let userArray = snapshot.data()?["followers"] as? [String] else { return }
                var users = userArray
                for i in users {
                    if accountInfo.blockedUsers.contains(where: { $0  == i }) {
                        users.removeAll(where: { $0 == i })
                    }
                }
                followerCount = userArray.count
                if users.contains(accountInfo.id) {
                    followBool = true
                } else {
                    followBool = false
                }
                
                for (index, i) in followerArray.enumerated() {
                    if users.contains(where: { $0 == i.id }) == false {
                        followerArray.remove(at: index)
                    }
                }
                
                var loadCount = 10 - followerArray.count
                if users.count < loadCount {
                    loadCount = users.count
                }
                for i in 0..<loadCount {
                    let userRef = Firestore.firestore().collection("users").document(users[i])
                    userRef.getDocument { userSnapshot, _ in
                        guard let userSnapshot = userSnapshot else { return }
                        if followerArray.contains(where: { $0.id == userSnapshot.documentID }) == false {
                            let account = AccountInfo()
                            account.id = userSnapshot.documentID
                            getUserNameAndIcon(id: userSnapshot.documentID) { name, icon in
                                account.name = name
                                account.iconImage = icon
                                followerArray.append(account)
                            }
                        }
                    }
                }
            }
            
            let worldContentRef = Firestore.firestore().collection("contents").whereField("parentWorld", isEqualTo: worldInfo.id)
            worldContentRef.getDocuments { snapshot, _ in
                guard let snapshot = snapshot else { return }
                contentCount = snapshot.documents.count
            }
            
            let categoryRef = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory")
            
            categoryRef.getDocuments { documents, err in
                if let err = err {
                    print("Error: \(err)")
                } else if let documents = documents {
                    dispatchGroup.enter()
                    DispatchQueue(label: "getCategoryDocument").async {
                        for i in documents.documentChanges {
                            if i.type == .added {
                                if worldInfo.contentCategory.filter({ $0.id == i.document.documentID }).count == 0 {
                                    let category = ContentCategory()
                                    category.name = i.document.data()["name"] as! String
                                    category.description = i.document.data()["description"] as! String
                                    category.backgroundURL = i.document.data()["backgroundImage"] as! String
                                    category.id = i.document.documentID
                                    category.index = i.document.data()["index"] as! Int
                                    if (i.document.data()["backgroundImage"] as! String) != "" {
                                        if category.backgroundURL == worldInfo.backgroundURL {
                                            category.backgroundImage = worldInfo.backgroundImage
                                        } else {
                                            let storageRef = Storage.storage().reference(forURL: i.document.data()["backgroundImage"] as! String)
                                            dispatchGroup.enter()
                                            storageRef.getData(maxSize: 1024 * 1024 * 50) { data, err in
                                                if let data = data {
                                                    if let image = UIImage(data: data) {
                                                        category.backgroundImage = image
                                                    }
                                                }
                                                dispatchGroup.leave()
                                            }
                                        }
                                        
                                        dispatchGroup.notify(queue: .main) {
                                            worldInfo.contentCategory.append(category)
                                        }
                                    } else {
                                        worldInfo.contentCategory.append(category)
                                    }
                                }
                            }
                        }
                        dispatchGroup.leave()
                        
                        dispatchGroup.notify(queue: .main) {
                            worldInfo.contentCategory.sort { a, b in
                                return a.index < b.index
                            }
                            
                            dispatchGroup.enter()
                            DispatchQueue(label: "getContents").async {
                                for category in worldInfo.contentCategory {
                                    let contentRef = Firestore.firestore().collection("contents")
                                        .whereField("parentWorld", isEqualTo: worldInfo.id)
                                        .whereField("parentCategory", isEqualTo: category.id)
                                    dispatchGroup.enter()
                                    contentRef.getDocuments { cDocuments, err in
                                        if let cDocuments = cDocuments {
                                            dispatchGroup.enter()
                                            DispatchQueue(label: "getContentFromDocument").async {
                                                for d in cDocuments.documents {
                                                    let contentInfo = ContentInfo()
                                                    if category.contents.filter({ $0.id == d.documentID }).count == 0 {
                                                        contentInfo.id = d.documentID
                                                        contentInfo.name = d.data()["name"] as! String
                                                        contentInfo.explanation = d.data()["description"] as! String
                                                        contentInfo.contentStyle = d.data()["style"] as! String
                                                        contentInfo.parentWorld = d.data()["parentWorld"] as! String
                                                        contentInfo.parentCategory = d.data()["parentCategory"] as! String
                                                        let createdDate = d.data()["createdDate"] as! Timestamp
                                                        let updatedDate = d.data()["updatedDate"] as! Timestamp
                                                        contentInfo.createdDate = createdDate.dateValue()
                                                        contentInfo.updatedDate = updatedDate.dateValue()
                                                        contentInfo.createdUserID = d.data()["createdUser"] as! String
                                                        getUserNameAndIcon(id: contentInfo.createdUserID) { name, _ in
                                                            contentInfo.createdUserName = name
                                                        }
                                                        if let aspectFit = d.data()["backgroundAspectFit"] as? Bool {
                                                            contentInfo.backgroundAspectFit = aspectFit
                                                        }
                                                        if contentInfo.contentStyle == "scroll" {
                                                            contentInfo.loopPlay = d.data()["bgmLoop"] as! Bool
                                                        }
                                                        var imageURL = d.data()["backgroundImage"] as! String
                                                        if let png = imageURL.range(of: ".png") {
                                                            imageURL.replaceSubrange(png, with: "_250x250.png")
                                                        }
                                                        if imageURL != "" {
                                                            dispatchGroup.enter()
                                                            Storage.storage().reference(forURL: imageURL).getData(maxSize: 1024 * 1024 * 50) { data, err in
                                                                if let data = data {
                                                                    if let image = UIImage(data: data) {
                                                                        contentInfo.backgroundImage = image
                                                                    } else {
                                                                        contentInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
                                                                    }
                                                                } else {
                                                                    contentInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
                                                                }
                                                                category.contents.append(contentInfo)
                                                                dispatchGroup.leave()
                                                            }
                                                        } else {
                                                            category.contents.append(contentInfo)
                                                        }
                                                    }
                                                    
                                                    if let sameIndex = category.contents.firstIndex(where: { $0.id == d.documentID }) {
                                                        DispatchQueue.main.async {
                                                            category.contents[sameIndex].likes = d.data()["likes"] as? [String] ?? []
                                                        }
                                                    }
                                                }
                                                dispatchGroup.leave()
                                                
                                                dispatchGroup.notify(queue: .main) {
                                                    for i in category.contents {
                                                        if cDocuments.documents.contains(where: { $0.documentID == i.id }) == false {
                                                            category.contents.removeAll(where: { $0.id == i.id })
                                                        }
                                                    }
                                                }
                                            }
                                        } else if let err = err {
                                            print("getting content error.")
                                            print("Error: \(err)")
                                        }
                                        dispatchGroup.leave()
                                    }
                                }
                                dispatchGroup.leave()
                                
                                dispatchGroup.notify(queue: .main) {
                                    getAnnouncement()
                                }
                            }
                        }
                    }
                }
            }
            
            if worldInfo.createdUser == accountInfo.id {
                settingBool = true
            }
        }
        .onAppear {
            let dispatchGroup = DispatchGroup()
            if worldInfo.bgm != "" {
                if worldInfo.bgmURL == URL(fileURLWithPath: "") {
                    dispatchGroup.enter()
                    Storage.storage().reference().child(worldInfo.bgm).getData(maxSize: 1024 * 1024 * 20) { data, _ in
                        guard let data = data else { return }
                        worldInfo.bgmData = data
                        dispatchGroup.leave()
                    }
                    worldInfo.bgmURL = URL(fileURLWithPath: worldInfo.bgm)
                    
                    dispatchGroup.notify(queue: .main) {
                        if music.musicMuteBool && music.musicURL != worldInfo.bgmURL {
                            playBackgroundMusic(url: worldInfo.bgmURL)
                        } else if music.musicMuteBool && music.musicURL == worldInfo.bgmURL {
                            music.musicLoop = true
                            music.musicMuteBool = false
                            music.pauseBool = false
                            music.finished = false
                            music.listIndex = -1
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if music.musicMuteBool && music.musicURL != worldInfo.bgmURL {
                            playBackgroundMusic(url: worldInfo.bgmURL)
                        } else if music.musicMuteBool && music.musicURL == worldInfo.bgmURL {
                            music.musicLoop = true
                            music.musicMuteBool = false
                            music.pauseBool = false
                            music.finished = false
                            music.listIndex = -1
                        }
                    }
                }
            }
            
            for (iIndex, i) in worldInfo.contentCategory.enumerated() {
                for (jIndex, j) in i.contents.enumerated() {
                    if j.deleted && iIndex >= 0 && iIndex < worldInfo.contentCategory.count && jIndex >= 0 && jIndex < i.contents.count {
                        worldInfo.contentCategory[iIndex].contents.remove(at: jIndex)
                        for (kIndex, k) in worldInfo.announcements.enumerated() {
                            if k.content == j.id {
                                let announceDoc = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements").document(k.id)
                                announceDoc.delete()
                                selection = 0
                                worldInfo.announcements.remove(at: kIndex)
                            }
                        }
                    }
                }
            }
        }
        .onWillDisappear {
            listener?.remove()
        }
        .onChange(of: worldDeleted) { value in
            if value {
                dismiss()
            }
        }
        .onChange(of: createContent.bool) { value in
            if value == false {
                DispatchQueue.main.async {
                    playBackgroundMusic(url: worldInfo.bgmURL)
                }
            }
        }
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo, category: ContentCategory) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent, category: category)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent, category: category)
        }
    }
    
    func getAnnouncement() {
        let announceRef = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements")
        let group = DispatchGroup()
        
        group.enter()
        announceRef.getDocuments { announcement, err in
            if let announcement = announcement {
                for announceDocument in announcement.documents {
                    if worldInfo.announcements.filter({ $0.id == announceDocument.documentID }).count == 0 {
                        let announce = Announcement()
                        announce.id = announceDocument.documentID
                        announce.name = announceDocument.data()["name"] as! String
                        announce.index = announceDocument.data()["index"] as! Int
                        announce.content = announceDocument.data()["contentID"] as! String
                        for i in worldInfo.contentCategory {
                            if let content = i.contents.filter( { $0.id == announce.content }).first {
                                announce.image = content.backgroundImage
                                announce.categoryIndex = i.index
                            }
                        }
                        worldInfo.announcements.append(announce)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            worldInfo.announcements.sort { a, b in
                return a.index < b.index
            }
            
            withAnimation(.linear(duration: 0.3)) {
                viewOpacity = 1.0
                loadObserver.opacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                loadObserver.isLoading = false
            }
        }
    }
    
    func infoButtonFunc() {
        if infoBool == false {
            infoBool.toggle()
            withAnimation(.linear(duration: 0.3)) {
                contentOpacity = 0.0
                infoOpacity = 1.0
            }
        } else {
            withAnimation(.linear(duration: 0.3)) {
                contentOpacity = 1.0
                infoOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.infoBool.toggle()
            }
        }
    }
    
    func numberOfContent(count: Int) -> Int {
        var num = count
        if count > 6 {
            num = 6
        }
        
        return num
    }
    
    func playBackgroundMusic(url: URL) {
        music.musicURL = url
        music.musicLoop = true
        music.musicMuteBool = false
        music.pauseBool = false
        music.finished = false
        music.listIndex = -1
        playAudio.playAudioFromData(data: worldInfo.bgmData, muteBool: music.musicMuteBool, loop: music.musicLoop)
    }
}

//struct CreatorHomeView_Previews: PreviewProvider {
        
   // static var previews: some View {
       // CreatorHomeView()
        //    .edgesIgnoringSafeArea(.all)
    //}
//}

struct CreatorHomeInfoView: View {
    
    @Binding var followerCount: Int
    @Binding var followBool: Bool
    @Binding var contentCount: Int
    @Binding var followerArray: [AccountInfo]
    var membershipBool: Bool = true
    @State var backgroundImage = UIImage()
    @State var createdDate = ""
    @State var updatedDate = ""
    @StateObject var worldInfo: WorldInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    
                    Title(title: worldInfo.name, size: 32)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Text(worldInfo.explanation)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                    .padding(.top, 40)
                    .padding([.leading, .trailing], 20)
                
                if worldInfo.tags.count > 0 {
                    Text("Tags")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .card()
                        .padding(.top, 40)
                        .padding([.leading, .trailing], 20)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0..<worldInfo.tags.count, id: \.self) { i in
                                Button(action: {
                                    
                                }) {
                                    Text(worldInfo.tags[i])
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                        .card()
                                }
                            }
                        }
                        .frame(height: 50)
                        .padding(.top, 16)
                        .padding([.leading, .trailing], 20)
                    }
                }
                
                Text("Creator")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .card()
                    .padding(.top, 40)
                    .padding([.leading, .trailing], 20)
                
                NavigationLink(destination: OtherAccountView(accountID: worldInfo.createdUser)) {
                    HStack(spacing: 16) {
                        Image(uiImage: worldInfo.createdUserIcon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 60)/4, height: (UIScreen.main.bounds.size.width - 60)/4)
                            .clipShape(Circle())
                        
                        Text(worldInfo.createdUserName)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
                .card()
                .padding(.top, 24)
                .padding([.leading, .trailing], 20)
                
                HStack {
                    Text(NSLocalizedString("Followers", comment: "") + "(\(followerCount))")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                    
                    Spacer()
                    
                    if followerCount >= 10 {
                        NavigationLink(destination: AccountListView(backgroundImage: backgroundImage, documentRef: Firestore.firestore().collection("world").document(worldInfo.id), fieldName: "followers")) {
                            HStack {
                                Text("See more")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.white)
                                
                                Image(systemName: "chevron.forward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .card()
                .padding(.top, 40)
                .padding([.leading, .trailing], 20)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<contentCount(count: followerArray.count), id: \.self) { i in
                            NavigationLink(destination: OtherAccountView(accountID: followerArray[i].id)) {
                                VStack(spacing: 0) {
                                    Image(uiImage: followerArray[i].iconImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: (UIScreen.main.bounds.size.width - 60)/4, height: (UIScreen.main.bounds.size.width - 60)/4)
                                        .clipShape(Circle())
                                    
                                    Text(followerArray[i].name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1)
                                        .padding(.top, 3)
                                    
                                    //HStack {
                                    //Image(systemName: "p.circle")
                                    //.resizable()
                                    //.scaledToFit()
                                    //.frame(width: 14, height: 14)
                                    //.foregroundColor(.white)
                                    
                                    //Text("\(810/(i+1))")
                                    //.foregroundColor(.white)
                                    //.font(.system(size: 14, weight: .regular))
                                    //.multilineTextAlignment(.center)
                                    //.lineLimit(1)
                                    //}
                                }
                                .card()
                            }
                        }
                    }
                    .frame(height: (UIScreen.main.bounds.size.width - 60)/4 + 50, alignment: .top)
                    .padding(.top, 24)
                    .padding([.leading, .trailing], 20)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(contentCount)")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Creations")
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
                    .onWillAppear {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd"
                        createdDate = formatter.string(from: worldInfo.createdDate)
                    }
                    
                    HStack {
                        Text("Updated Date")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                        
                        Text(updatedDate)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }.onWillAppear {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd"
                        updatedDate = formatter.string(from: worldInfo.updatedDate)
                    }
                }
                .card()
                .padding(.top, 64)
                .padding(.leading, 20)
            }
            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 40)
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
