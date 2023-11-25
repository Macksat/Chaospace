//
//  MyLibraryView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct MyLibraryView: View {
    
    @State var followedWorlds = [WorldInfo]()
    @State var favoriteContents = [ContentInfo]()
    @State var dummyArray = [WorldInfo]()
    @State var dummyArray2 = [ContentInfo]()
    @State var gotContent = false
    @State var worldText = ""
    @State var contentText = ""
    let topPadding = UINavigationController().navigationBar.frame.size.height + statusBarSize()
    let bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @ObservedObject var accountInfo: AccountInfo
    @StateObject var notifiedWorld: WorldInfo
    @Binding var gotNotification: Bool
    
    var body: some View {
        GeometryReader { _ in
            NavigationLink(destination: CreatorHomeView(worldInfo: notifiedWorld), isActive: $gotNotification) {
                EmptyView()
            }
            
            ScrollView {
                VStack(spacing: 1) {
                    if followedWorlds.count == 0 {
                        MyLibraryChildView(contentArray: $dummyArray2, worldArray: $followedWorlds, index: "follow", text: $worldText)
                    } else {
                        NavigationLink(destination: {
                            segueView(array: "follow")
                        }) {
                            MyLibraryChildView(contentArray: $dummyArray2, worldArray: $followedWorlds, index: "follow", text: $worldText)
                        }
                    }
                    
                    if favoriteContents.count == 0 {
                        MyLibraryChildView(contentArray: $favoriteContents, worldArray: $dummyArray, index: "favorite", text: $contentText)
                    } else {
                        NavigationLink(destination: {
                            segueView(array: "favorite")
                        }) {
                            MyLibraryChildView(contentArray: $favoriteContents, worldArray: $dummyArray, index: "favorite", text: $contentText)
                        }
                        .simultaneousGesture(TapGesture().onEnded({ _ in
                            let group = DispatchGroup()
                            if favoriteContents.count == 1 {
                                addViewCount(id: favoriteContents.first!.id, collection: "contents")
                                if favoriteContents.first!.gotContent == false {
                                    if favoriteContents.first!.contentStyle == "scroll" {
                                        group.enter()
                                        getScrollContents(contentInfo: favoriteContents.first!) { scrollContents, backgroundImage, musicData, musicURL in
                                            favoriteContents.first!.scrollContents = scrollContents
                                            favoriteContents.first!.backgroundImage = backgroundImage
                                            favoriteContents.first!.music = musicURL
                                            favoriteContents.first!.musicData = musicData
                                            favoriteContents.first!.gotContent = true
                                            group.leave()
                                        }
                                    } else if favoriteContents.first!.contentStyle == "show" {
                                        group.enter()
                                        getShowContents(contentInfo: favoriteContents.first!) { showContents in
                                            favoriteContents.first!.showContents = showContents
                                            favoriteContents.first!.gotContent = true
                                            group.leave()
                                        }
                                    }
                                    
                                    group.notify(queue: .main) {
                                        gotContent = true
                                    }
                                } else {
                                    gotContent = true
                                }
                            }
                        }))
                    }
                }
                .padding(.top, 0)
            }
            
            GradientNavigationBar()
        }
        .ignoresSafeArea()
        .background(Color.chaosBlack)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .onWillAppear {
            getFollowingWorlds()
            getFavoriteContents()
            gotContent = false
        }
    }
    
    @ViewBuilder func segueView(array: String) -> some View {
        if array == "follow" {
            if followedWorlds.count == 1 {
                CreatorHomeView(worldInfo: followedWorlds[0])
            } else if followedWorlds.count > 1 {
                LibraryDetailView(contentArray: $favoriteContents, worldArray: $followedWorlds, viewName: NSLocalizedString("Following Worlds", comment: ""))
            }
        } else {
            if favoriteContents.count == 1 {
                if favoriteContents[0].contentStyle == "scroll" {
                    ContentScrollView(contentInfo: favoriteContents[0], gotContent: $gotContent)
                } else {
                    ContentShowView(contentInfo: favoriteContents[0], gotContent: $gotContent)
                }
                EmptyView()
            } else if favoriteContents.count > 1 {
                LibraryDetailView(contentArray: $favoriteContents, worldArray: $followedWorlds, contentBool: true, viewName: NSLocalizedString("Favorite Contents", comment: ""))
            }
        }
    }
    
    func getFollowingWorlds() {
        let group = DispatchGroup()
        let ref = Firestore.firestore().collection("world").whereField("followers", arrayContains: accountInfo.id)
        ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            group.enter()
            DispatchQueue(label: "getFollowingWorlds").async {
                for i in snapshot.documents {
                    if followedWorlds.contains(where: { $0.id == i.documentID }) == false {
                        let worldInfo = WorldInfo()
                        worldInfo.id = i.documentID
                        worldInfo.name = i.data()["name"] as! String
                        worldInfo.explanation = i.data()["description"] as! String
                        var backgroundImage = i.data()["backgroundImage"] as! String
                        worldInfo.bgm = i.data()["bgm"] as! String
                        worldInfo.bgmName = i.data()["bgmName"] as! String
                        worldInfo.createdUser = i.data()["createdUser"] as! String
                        worldInfo.tags = i.data()["tags"] as! [String]
                        worldInfo.category = i.data()["categories"] as! [String]
                        let createdDate = i.data()["createdDate"] as! Timestamp
                        let updatedDate = i.data()["updatedDate"] as! Timestamp
                        worldInfo.createdDate = createdDate.dateValue()
                        worldInfo.updatedDate = updatedDate.dateValue()
                        worldInfo.following = true
                        let storage = Storage.storage()
                        
                        if accountInfo.blockedUsers.contains(where: { $0 == worldInfo.createdUser }) == false {
                            group.enter()
                            getUserNameAndIcon(id: worldInfo.createdUser) { userName, iconImage in
                                worldInfo.createdUserName = userName
                                worldInfo.createdUserIcon = iconImage
                                
                                if backgroundImage != "" {
                                    if let png = backgroundImage.range(of: ".png") {
                                        backgroundImage.replaceSubrange(png, with: "_500x500.png")
                                        worldInfo.backgroundURL = backgroundImage
                                        
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
                                }
                                group.leave()
                            }
                            
                            group.notify(queue: .main) {
                                followedWorlds.append(worldInfo)
                            }
                        }
                    }
                }
                
                group.leave()
                
                group.notify(queue: .main) {
                    for i in followedWorlds {
                        if followedWorlds.count > snapshot.documents.count && snapshot.documents.contains(where: { $0.documentID == i.id }) == false {
                            followedWorlds.removeAll(where: { $0.id == i.id })
                        }
                        
                        if accountInfo.blockedUsers.contains(where: { $0 == i.createdUser }) {
                            followedWorlds.removeAll(where: { $0.createdUser == i.createdUser })
                        }
                    }
                    worldText = worldNames()
                }
            }
        }
    }
    
    func getFavoriteContents() {
        let dispatchGroup = DispatchGroup()
        let contentRef = Firestore.firestore().collection("contents").whereField("likes", arrayContains: accountInfo.id)
        dispatchGroup.enter()
        contentRef.getDocuments { cDocuments, err in
            if let cDocuments = cDocuments {
                dispatchGroup.enter()
                DispatchQueue(label: "getFavoriteContents").async {
                    for d in cDocuments.documents {
                        if d.data()["style"] as! String != "article" {
                            let contentInfo = ContentInfo()
                            if favoriteContents.contains(where: { $0.id == d.documentID }) == false {
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
                                contentInfo.isFavorite = true
                                
                                if accountInfo.blockedUsers.contains(where: { $0 == contentInfo.createdUserID }) == false {
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
                                        imageURL.replaceSubrange(png, with: "_500x500.png")
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
                                            favoriteContents.append(contentInfo)
                                            dispatchGroup.leave()
                                        }
                                    }
                                }
                            }
                            
                            if let sameIndex = favoriteContents.firstIndex(where: { $0.id == d.documentID }) {
                                favoriteContents[sameIndex].likes = d.data()["likes"] as! [String]
                            }
                        }
                    }
                    dispatchGroup.leave()
                    
                    dispatchGroup.notify(queue: .main) {
                        for i in favoriteContents {
                            if favoriteContents.count > cDocuments.documents.count && cDocuments.documents.contains(where: { $0.documentID == i.id }) == false {
                                favoriteContents.removeAll(where: { $0.id == i.id })
                            }
                            
                            if accountInfo.blockedUsers.contains(where: { $0 == i.createdUserID }) {
                                favoriteContents.removeAll(where: { $0.createdUserID == i.createdUserID })
                            }
                        }
                        contentText = contentNames()
                    }
                }
            } else if let err = err {
                print("getting content error.")
                print("Error: \(err)")
            }
            dispatchGroup.leave()
        }
    }
    
    func worldNames() -> String {
        var text = String()
        for i in 0..<followedWorlds.count {
            if i == followedWorlds.count - 1 {
                text += followedWorlds[i].name
            } else {
                text += "\(followedWorlds[i].name), "
            }
        }
        
        return text
    }
    
    func contentNames() -> String {
        var text = String()
        for i in 0..<favoriteContents.count {
            if i == favoriteContents.count - 1 {
                text += favoriteContents[i].name
            } else {
                text += "\(favoriteContents[i].name), "
            }
        }
        
        return text
    }
}

//struct MyLibraryView_Previews: PreviewProvider {
    //static var previews: some View {
        //MyLibraryView()
   // }
//}

struct MyLibraryChildView: View {
    
    @Binding var contentArray: [ContentInfo]
    @Binding var worldArray: [WorldInfo]
    var index: String = "follow"
    @State var topPadding = CGFloat(20)
    @State var bottomPadding = CGFloat(40)
    @State var title = ""
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            FadePageView(contentArray: $contentArray, worldArray: $worldArray, height: UIScreen.main.bounds.size.height / 2)
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2)
                .foregroundColor(.black.opacity(0.000001))
            
            VStack(alignment: .leading) {
                switch index {
                case "follow":
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                default:
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .padding(.top, topPadding)
                }
                
                Spacer()
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .card()
            .padding(.bottom, bottomPadding)
            .padding([.leading, .trailing], 20)
        }
        .ignoresSafeArea()
        .background(Color.chaosBlack)
        .onAppear {
            if index == "follow" {
                topPadding = statusBarSize() + 20
                title = NSLocalizedString("Following Worlds", comment: "")
            } else if index == "favorite" {
                bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30
                title = NSLocalizedString("Favorite Contents", comment: "")
            }
        }
    }
}
