//
//  MyAccoountView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct MyAccountView: View {
    
    @ObservedObject var info: AccountInfo
    @State var worldInfo = WorldInfo()
    @State var worldListener: ListenerRegistration?
    @State var contentListener: ListenerRegistration?
    @State var goCreateWorld = false
    @State var goCreatedWorld = false
    @State var worldCreated = false
    @State var gotContent = false
    @State var goSetting = false
    @Binding var goAccount: Bool
    @Binding var opacity: Double
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                NavigationLink(destination: CreatorHomeView(worldInfo: info.createdWorlds.filter( { $0.id == worldInfo.id }).first ?? worldInfo), isActive: $goCreatedWorld) {
                    EmptyView()
                }
                
                AccountView(parentName: "MyAccountView", info: info, worldInfo: worldInfo, goCreateWorld: $goCreateWorld)
            }
        }
        .background(Color.chaosBlack)
        .ignoresSafeArea()
        .onWillAppear {
            getWorldAndContentInfo()
            goCreatedWorld = false
            goCreateWorld = false
            goCreatedWorld = false
            worldCreated = false
            gotContent = false
        }
        .onAppear {
            info.createdWorlds.removeAll(where: { $0.deleted == true })
            info.createdContents.removeAll(where: { $0.deleted == true })
        }
        .onWillDisappear {
            worldListener?.remove()
            contentListener?.remove()
        }
        .onChange(of: worldCreated, perform: { newValue in
            if newValue == true {
                let newWorldInfo = WorldInfo()
                newWorldInfo.id = worldInfo.id
                newWorldInfo.name = worldInfo.name
                newWorldInfo.explanation = worldInfo.explanation
                newWorldInfo.bgm = worldInfo.bgm
                newWorldInfo.bgmURL = worldInfo.bgmURL
                newWorldInfo.bgmName = worldInfo.bgmName
                newWorldInfo.createdUser = worldInfo.createdUser
                newWorldInfo.createdUserName = worldInfo.createdUserName
                newWorldInfo.createdUserIcon = worldInfo.createdUserIcon
                newWorldInfo.backgroundImage = worldInfo.backgroundImage
                newWorldInfo.backgroundURL = worldInfo.backgroundURL
                newWorldInfo.tags = worldInfo.tags
                newWorldInfo.category = worldInfo.category
                newWorldInfo.createdDate = worldInfo.createdDate
                newWorldInfo.updatedDate = worldInfo.updatedDate
                
                if info.createdWorlds.contains(where: { $0.id == worldInfo.id }) {
                    info.createdWorlds.removeAll(where: { $0.id == worldInfo.id })
                }
                info.createdWorlds.append(newWorldInfo)
                info.createdWorlds.sort { a, b in
                    return a.createdDate > b.createdDate
                }
                
                goCreatedWorld = true
            }
        })
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        opacity = 0.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        goAccount.toggle()
                    }
                }) {
                    Image(systemName: "multiply")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    goSetting.toggle()
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .fullScreenCover(isPresented: $goCreateWorld) {
            NavigationView {
                CreateWorldView(info: worldInfo, worldCreated: $worldCreated)
            }
            .accentColor(.white)
        }
        .fullScreenCover(isPresented: $goSetting) {
            NavigationView {
                AccountSettingView(goAccount: $goAccount, infoForSegue: info)
            }
            .accentColor(.white)
        }
    }
    
    func getWorldAndContentInfo() {
        let worldRef = Firestore.firestore().collection("world")
            .whereField("createdUser", isEqualTo: info.id)
            .order(by: "updatedDate", descending: true)
        
        worldListener = worldRef.addSnapshotListener { snapshot, _ in
            if let snapshot = snapshot {
                for i in snapshot.documentChanges {
                    if i.type == .removed {
                        info.createdWorlds.removeAll(where: { $0.id == i.document.documentID })
                    } else if i.type == .added {
                        if info.createdWorlds.contains(where: { $0.id == i.document.documentID }) == false {
                            requestWorldData(d: i.document)
                        }
                    }
                }
            }
        }
        
        let contentRef = Firestore.firestore().collection("contents")
            .whereField("createdUser", isEqualTo: info.id)
            .order(by: "updatedDate", descending: true)
        
        contentListener = contentRef.addSnapshotListener { snapshot, _ in
            guard let snapshot = snapshot else { return }
            for i in snapshot.documentChanges {
                if i.type == .removed {
                    info.createdContents.removeAll(where: { $0.id == i.document.documentID})
                } else if i.type == .added {
                    if info.createdContents.contains(where: { $0.id == i.document.documentID }) == false {
                        requestContentData(d: i.document)
                    }
                }
                
                if let sameIndex = info.createdContents.firstIndex(where: { $0.id == i.document.documentID }) {
                    DispatchQueue.main.async {
                        info.createdContents[sameIndex].likes = i.document.data()["likes"] as? [String] ?? []
                    }
                }
            }
        }
    }
    
    func requestContentData(d: QueryDocumentSnapshot) {
        let group = DispatchGroup()
        let contentInfo = ContentInfo()
        contentInfo.createdUserID = info.id
        contentInfo.createdUserName = info.name
        contentInfo.id = d.documentID
        contentInfo.name = d.data()["name"] as! String
        contentInfo.contentStyle = d.data()["style"] as! String
        if contentInfo.contentStyle != "article" {
            contentInfo.explanation = d.data()["description"] as! String
            contentInfo.parentWorld = d.data()["parentWorld"] as! String
            contentInfo.parentCategory = d.data()["parentCategory"] as! String
        }
        let createdDate = d.data()["createdDate"] as! Timestamp
        let updatedDate = d.data()["updatedDate"] as! Timestamp
        contentInfo.createdDate = createdDate.dateValue()
        contentInfo.updatedDate = updatedDate.dateValue()
        if let aspectFit = d.data()["backgroundAspectFit"] as? Bool {
            contentInfo.backgroundAspectFit = aspectFit
        }
        if contentInfo.contentStyle == "scroll" {
            contentInfo.loopPlay = d.data()["bgmLoop"] as! Bool
        }
        var imageURL = d.data()["backgroundImage"] as? String ?? ""
        if let png = imageURL.range(of: ".png") {
            imageURL.replaceSubrange(png, with: "_250x250.png")
        }
        if imageURL != "" {
            group.enter()
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
                group.leave()
            }
            
            group.notify(queue: .main) {
                info.createdContents.append(contentInfo)
                info.createdContents.sort { a, b in
                    return a.createdDate > b.createdDate
                }
            }
        } else {
            if contentInfo.contentStyle == "article" {
                contentInfo.backgroundImage = info.iconImage
            } else {
                contentInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
            }
            info.createdContents.append(contentInfo)
            info.createdContents.sort { a, b in
                return a.createdDate > b.createdDate
            }
        }
    }
    
    func requestWorldData(d: QueryDocumentSnapshot) {
        let worldInfo = WorldInfo()
        worldInfo.id = d.documentID
        worldInfo.name = d.data()["name"] as! String
        worldInfo.explanation = d.data()["description"] as! String
        var backgroundImage = d.data()["backgroundImage"] as! String
        worldInfo.bgm = d.data()["bgm"] as! String
        worldInfo.bgmName = d.data()["bgmName"] as! String
        worldInfo.createdUser = d.data()["createdUser"] as! String
        worldInfo.tags = d.data()["tags"] as! [String]
        worldInfo.category = d.data()["categories"] as! [String]
        let createdDate = d.data()["createdDate"] as! Timestamp
        let updatedDate = d.data()["updatedDate"] as! Timestamp
        worldInfo.createdDate = createdDate.dateValue()
        worldInfo.updatedDate = updatedDate.dateValue()
        let storage = Storage.storage()
        let ref = Firestore.firestore().collection("users").document(worldInfo.createdUser)
        let group = DispatchGroup()
        
        group.enter()
        ref.getDocument { document, err in
            if let document = document {
                worldInfo.createdUserName = document.data()!["name"] as! String
                let icon = document.data()!["thumbnail"] as! String
                
                if icon != "" {
                    group.enter()
                    storage.reference(forURL: icon).getData(maxSize: 1024 * 1024 * 10) { data, err in
                        if let err = err {
                            print("Error: \(err)")
                        } else if let data = data {
                            worldInfo.createdUserIcon = UIImage(data: data) ?? UIImage()
                        }
                        group.leave()
                    }
                }
                                
                if backgroundImage != "" {
                    if let png = backgroundImage.range(of: ".png") {
                        backgroundImage.replaceSubrange(png, with: "_250x250.png")
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
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if info.createdWorlds.contains(where: { $0.id == worldInfo.id }) == false {
                info.createdWorlds.append(worldInfo)
                info.createdWorlds.sort { a, b in
                    return a.createdDate > b.createdDate
                }
            }
        }
    }
}

//struct MyAccountView_Previews: PreviewProvider {
    //static var previews: some View {
        //MyAccountView()
    //}
//}

struct OtherAccountView: View {
    
    var accountID: String
    @StateObject var accountInfo = AccountInfo()
    @State var hogeBool = false
    @State var blockBool = false
    @EnvironmentObject var name: Name
    @EnvironmentObject var myAccountInfo: AccountInfo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { _ in
            AccountView(parentName: "OtherAccountView", info: accountInfo, goCreateWorld: $hogeBool)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10)
        }
        .ignoresSafeArea()
        .onWillAppear {
            getAccount(accountID: accountID)
            DispatchQueue.main.async {
                name.name = "OtherAccountView"
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if accountID != myAccountInfo.id {
                    Button(action: {
                        blockBool = true
                    }) {
                        Image(systemName: "person.fill.xmark")
                            .foregroundColor(.white)
                            .card()
                    }
                }
            }
        }
        .alert(isPresented: $blockBool, content: {
            Alert(title: Text("Caution"),
                  message: Text("Do you want to block this user?"),
                  primaryButton: .default(Text("Cancel"), action: {
                    blockBool = false
            }),
                  secondaryButton: .destructive(Text("Block"), action: {
                let ref = Firestore.firestore().collection("users").document(myAccountInfo.id)
                ref.updateData(["blockedUsers": FieldValue.arrayUnion([accountID])])
                
                myAccountInfo.blockedUsers.append(accountID)
                
                dismiss()
            })
            )
        })
    }
    
    func getAccount(accountID: String) {
        let group = DispatchGroup()
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("users").document(accountID)
        group.enter()
        ref?.getDocument(completion: { document, error in
            if let document = document, document.exists {
                accountInfo.name = document.data()!["name"] as! String
                accountInfo.profile = document.data()!["profile"] as! String
                accountInfo.born = (document.data()!["born"] as! Timestamp).dateValue()
                accountInfo.id = document.documentID
                accountInfo.backgroundURL = document.data()!["backgroundImage"] as! String
                accountInfo.iconURL = document.data()!["thumbnail"] as! String
                guard let createdDate = document.data()?["createdDate"] as? Timestamp else { return }
                accountInfo.createdDate = createdDate.dateValue()
                accountInfo.email = document.data()!["email"] as! String
                accountInfo.accountID = document.data()!["accountID"] as! String
                accountInfo.gender = document.data()!["gender"] as! String
                
                if accountInfo.backgroundURL != "" {
                    group.enter()
                    Storage.storage().reference(forURL: accountInfo.backgroundURL).getData(maxSize: 1024 * 1024 * 50) { data, err in
                        if let data = data {
                            if let image = UIImage(data: data) {
                                accountInfo.backgroundImage = image
                            }
                        }
                        group.leave()
                    }
                }
                
                if accountInfo.iconURL != "" {
                    group.enter()
                    Storage.storage().reference(forURL: accountInfo.iconURL).getData(maxSize: 1024 * 1024 * 50) { data, err in
                        if let data = data {
                            if let image = UIImage(data: data) {
                                accountInfo.iconImage = image
                            }
                        }
                        group.leave()
                    }
                }
            } else {
                print("Document does not exist")
            }
            group.leave()
            
            group.notify(queue: .main) {
                getWorldAndContentInfo()
            }
        })
    }
    
    func getWorldAndContentInfo() {
        let worldRef = Firestore.firestore().collection("world")
            .whereField("createdUser", isEqualTo: accountInfo.id)
            .order(by: "updatedDate", descending: true)
        
        worldRef.getDocuments { snapshot, _ in
            if let snapshot = snapshot {
                for i in snapshot.documents {
                    if accountInfo.createdWorlds.contains(where: { $0.id == i.documentID }) == false {
                        requestWorldData(d: i)
                    }
                }
            }
        }
        
        let contentRef = Firestore.firestore().collection("contents")
            .whereField("createdUser", isEqualTo: accountInfo.id)
            .order(by: "updatedDate", descending: true)
        
        contentRef.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            for i in snapshot.documents {
                if accountInfo.createdContents.contains(where: { $0.id == i.documentID }) == false {
                    requestContentData(d: i)
                }
                
                if let sameIndex = accountInfo.createdContents.firstIndex(where: { $0.id == i.documentID }) {
                    DispatchQueue.main.async {
                        accountInfo.createdContents[sameIndex].likes = i.data()["likes"] as? [String] ?? []
                    }
                }
            }
        }
    }
    
    func requestContentData(d: QueryDocumentSnapshot) {
        let group = DispatchGroup()
        let contentInfo = ContentInfo()
        contentInfo.createdUserID = accountInfo.id
        contentInfo.createdUserName = accountInfo.name
        contentInfo.id = d.documentID
        contentInfo.name = d.data()["name"] as! String
        contentInfo.contentStyle = d.data()["style"] as! String
        if contentInfo.contentStyle != "article" {
            contentInfo.explanation = d.data()["description"] as! String
            contentInfo.parentWorld = d.data()["parentWorld"] as! String
            contentInfo.parentCategory = d.data()["parentCategory"] as! String
        }
        let createdDate = d.data()["createdDate"] as! Timestamp
        let updatedDate = d.data()["updatedDate"] as! Timestamp
        contentInfo.createdDate = createdDate.dateValue()
        contentInfo.updatedDate = updatedDate.dateValue()
        if let aspectFit = d.data()["backgroundAspectFit"] as? Bool {
            contentInfo.backgroundAspectFit = aspectFit
        }
        if contentInfo.contentStyle == "scroll" {
            contentInfo.loopPlay = d.data()["bgmLoop"] as! Bool
        }
        var imageURL = d.data()["backgroundImage"] as? String ?? ""
        if let png = imageURL.range(of: ".png") {
            imageURL.replaceSubrange(png, with: "_250x250.png")
        }
        if imageURL != "" {
            group.enter()
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
                group.leave()
            }
            
            group.notify(queue: .main) {
                accountInfo.createdContents.append(contentInfo)
                accountInfo.createdContents.sort { a, b in
                    return a.createdDate > b.createdDate
                }
            }
        } else {
            if contentInfo.contentStyle == "article" {
                contentInfo.backgroundImage = accountInfo.iconImage
            } else {
                contentInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
            }
            accountInfo.createdContents.append(contentInfo)
            accountInfo.createdContents.sort { a, b in
                return a.createdDate > b.createdDate
            }
        }
    }
    
    func requestWorldData(d: QueryDocumentSnapshot) {
        let worldInfo = WorldInfo()
        worldInfo.id = d.documentID
        worldInfo.name = d.data()["name"] as! String
        worldInfo.explanation = d.data()["description"] as! String
        var backgroundImage = d.data()["backgroundImage"] as! String
        worldInfo.bgm = d.data()["bgm"] as! String
        worldInfo.bgmName = d.data()["bgmName"] as! String
        worldInfo.createdUser = d.data()["createdUser"] as! String
        worldInfo.tags = d.data()["tags"] as! [String]
        worldInfo.category = d.data()["categories"] as! [String]
        let createdDate = d.data()["createdDate"] as! Timestamp
        let updatedDate = d.data()["updatedDate"] as! Timestamp
        worldInfo.createdDate = createdDate.dateValue()
        worldInfo.updatedDate = updatedDate.dateValue()
        let storage = Storage.storage()
        let ref = Firestore.firestore().collection("users").document(worldInfo.createdUser)
        let group = DispatchGroup()
        
        group.enter()
        ref.getDocument { document, err in
            if let document = document {
                worldInfo.createdUserName = document.data()!["name"] as! String
                let icon = document.data()!["thumbnail"] as! String
                
                if icon != "" {
                    group.enter()
                    storage.reference(forURL: icon).getData(maxSize: 1024 * 1024 * 10) { data, err in
                        if let err = err {
                            print("Error: \(err)")
                        } else if let data = data {
                            worldInfo.createdUserIcon = UIImage(data: data) ?? UIImage()
                        }
                        group.leave()
                    }
                }
                                
                if backgroundImage != "" {
                    if let png = backgroundImage.range(of: ".png") {
                        backgroundImage.replaceSubrange(png, with: "_250x250.png")
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
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            accountInfo.createdWorlds.append(worldInfo)
            accountInfo.createdWorlds.sort { a, b in
                return a.createdDate > b.createdDate
            }
        }
    }
}

struct AccountView: View {
    
    let topHeight = UINavigationController().navigationBar.frame.size.height + statusBarSize()
    let bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20
    var parentName: String
    @ObservedObject var info: AccountInfo
    @StateObject var worldInfo: WorldInfo = WorldInfo()
    @Binding var goCreateWorld: Bool
    @State var dateStr = ""
    @State var gotContent = false
    
    var body: some View {
        ZStack {
            BackgroundUIImage(image: info.backgroundImage, opacity: 0.2)
            
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Image(uiImage: info.iconImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.width/3)
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 15, x: 0, y: 0)
                        
                        Spacer()
                    }
                    .padding(.top, topHeight + 10)
                    
                    Text(info.name)
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .card()
                        .padding(.top, 10)
                    
                    Text("@\(info.accountID)")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .card()
                        .padding(.top, 5)
                    
                    Text(info.profile)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .card()
                        .padding(.top, 20)
                    
                    Group {
                        Text("Created Worlds")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .card()
                            .padding(.top, 60)
                        
                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 10) {
                                ForEach(0..<info.createdWorlds.count, id: \.self) { i in
                                    NavigationLink(destination: CreatorHomeView(worldInfo: info.createdWorlds[i])) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Image(uiImage: info.createdWorlds[i].backgroundImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: (UIScreen.main.bounds.width - 60)/3, height: (UIScreen.main.bounds.width - 60)/3)
                                                .cornerRadius(((UIScreen.main.bounds.width - 60)/3)*0.15)
                                            
                                            Text(info.createdWorlds[i].name)
                                                .font(.system(size: 16, weight: .medium))
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(.white)
                                                .frame(width: (UIScreen.main.bounds.width - 60)/3)
                                                .lineLimit(2)
                                        }
                                        .card()
                                    }
                                }
                            }
                            .frame(height: (UIScreen.main.bounds.width - 60)/3 + 65)
                            .padding([.leading, .trailing], 20)
                        }
                        .padding([.leading, .trailing], -20)
                        .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            
                            if info.createdWorlds.count > 10 {
                            NavigationLink(destination: CreatedWorldListView(backgroundImage: info.backgroundImage, worlds: info.createdWorlds)) {
                                    Text("See more")
                                        .underline()
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                        .card()
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        if parentName == "MyAccountView" {
                            Button(action: {
                                worldInfo.id = ""
                                worldInfo.name = ""
                                worldInfo.explanation = ""
                                worldInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
                                worldInfo.backgroundURL = ""
                                worldInfo.bgm = ""
                                worldInfo.bgmName = ""
                                worldInfo.createdUser = ""
                                worldInfo.tags = []
                                worldInfo.category = []
                                worldInfo.createdDate = Date()
                                worldInfo.updatedDate = Date()
                                goCreateWorld.toggle()
                            }) {
                                Text("Create World")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .medium))
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.white, lineWidth: 2)
                                    )
                                    .card()
                            }
                            .padding(.top, 24)
                        }
                    }
                    
                    Text("Posted Contents")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .card()
                        .padding(.top, 60)
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 10) {
                            ForEach(0..<info.createdContents.count, id: \.self) { i in
                                NavigationLink(destination: contentSegueView(contentInfo: info.createdContents[i])) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Image(uiImage: info.createdContents[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.width - 60)/3, height: (UIScreen.main.bounds.width - 60)/3)
                                            .cornerRadius(((UIScreen.main.bounds.width - 60)/3)*0.15)
                                        
                                        Text(info.createdContents[i].name)
                                            .font(.system(size: 16, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .frame(width: (UIScreen.main.bounds.width - 60)/3)
                                            .lineLimit(2)
                                    }
                                    .card()
                                }
                                .simultaneousGesture(TapGesture().onEnded({ _ in
                                    addViewCount(id: info.createdContents[i].id, collection: "contents")
                                    
                                    let group = DispatchGroup()
                                    if info.createdContents[i].gotContent == false {
                                        switch info.createdContents[i].contentStyle {
                                        case "scroll":
                                            group.enter()
                                            getScrollContents(contentInfo: info.createdContents[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                                info.createdContents[i].scrollContents = scrollContents
                                                info.createdContents[i].backgroundImage = backgroundImage
                                                info.createdContents[i].music = musicURL
                                                info.createdContents[i].musicData = musicData
                                                info.createdContents[i].gotContent = true
                                                group.leave()
                                                
                                                group.notify(queue: .main) {
                                                    gotContent = true
                                                }
                                            }
                                        case "show":
                                            group.enter()
                                            getShowContents(contentInfo: info.createdContents[i]) { showContents in
                                                info.createdContents[i].showContents = showContents
                                                info.createdContents[i].gotContent = true
                                                group.leave()
                                                
                                                group.notify(queue: .main) {
                                                    gotContent = true
                                                }
                                            }
                                        case "article":
                                            var articleContents = [ArticleContent]()
                                            let ref = Firestore.firestore().collection("contents").document(info.createdContents[i].id)
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
                                                    info.createdContents[i].articleContents = articleContents
                                                    info.createdContents[i].gotContent = true
                                                    gotContent = true
                                                }
                                            }
                                        default:
                                            break
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
                    .padding([.leading, .trailing], -20)
                    .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        
                        if info.createdContents.count > 10 {
                            NavigationLink(destination: CreatedContentListView(backgroundImage: info.backgroundImage, contents: info.createdContents)) {
                                Text("See more")
                                    .underline()
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .card()
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        Text("Registered Date")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                        
                        Text(dateStr)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .onAppear {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/MM/dd"
                                dateStr = formatter.string(from: info.createdDate)
                            }
                            .onChange(of: info.createdDate) { value in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/MM/dd"
                                dateStr = formatter.string(from: value)
                            }
                        
                        Spacer()
                    }
                    .card()
                    .padding(.top, 60)
                    
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                        .padding(.top, 20)
                }
                .padding([.leading, .trailing], 20)
                .padding(.bottom, bottomHeight + 20)
            }
            
            GradientNavigationBar()
        }
        .onWillAppear {
            gotContent = false
        }
        .background(.black)
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent)
        } else {
            ContentArticleView(contentInfo: contentInfo, backgroundImage: info.backgroundImage, aspectFit: false, gotContent: $gotContent)
        }
    }
}
