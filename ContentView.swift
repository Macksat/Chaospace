//
//  ContentView.swift
//  Shared
//
//  Created by Sato Masayuki on 2022/01/19.
//

import SwiftUI
import UIKit
import AVFoundation
import Photos
import FirebaseFirestore
import FirebaseStorage
import RealmSwift
import FirebaseAuth
import FirebaseAuthUI

func bottomInsetHeight() -> CGFloat {
    if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        return bottomPadding
    }
    
    return CGFloat()
}

struct ContentView: View {
    let realm = try! Realm()
    @State var logInBool = false
    @State var thisName = "ContentView"
    @State var chatName = "ChatView"
    @State var textFieldText = ""
    @State var textingHeight = CGFloat(40)
    @State var photoLibraryShow = false
    @State var selection = 0
    @State var musicFinished = false
    @State var preViewName = ""
    @State var signInTransaction = Transaction()
    @State var fcmToken = FCMToken()
    @State var gotNotification = false
    @State var notifiedWorld = WorldInfo()
    @State var goAccount = false
    @State var accountViewOpacity = 0.0
    @State var isContentSearch = false
    @State var isWorldSearch = false
    @StateObject var accountInfoForSegue = AccountInfo()
    @ObservedObject var authObserver = FirebaseAuthStateObserver()
    @EnvironmentObject var viewName: Name
    @EnvironmentObject var textingBool: TextingBool
    @EnvironmentObject var music: Music
    @ObservedObject var keyboard = KeyboardObserver()
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var chatBoardID: ChatBoardID
    @EnvironmentObject var tabBarHidden: TabBarHidden
    @EnvironmentObject var appDelegate: AppDelegate
    let gradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0, opacity: 0.6), Color(red: 0, green: 0, blue: 0, opacity: 0)]), startPoint: .bottom, endPoint: .top)
    
    init() {
        let appearance = UISegmentedControl.appearance()
        let font = UIFont.systemFont(ofSize: 17, weight: .medium)
        let foregroundColor = UIColor.white

        // 選択時の背景色
        appearance.selectedSegmentTintColor = foregroundColor

        // 通常時のフォントとフォント色
        appearance.setTitleTextAttributes([
            .font: font,
            .foregroundColor: foregroundColor
        ], for: .normal)

        // 選択時のフォントとフォント色
        appearance.setTitleTextAttributes([
            .font: font,
            .foregroundColor: UIColor.black
        ], for: .selected)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                ZStack(alignment: .bottom) {
                    NavigationView {
                        if authObserver.isSignIn {
                            HomeView(isSearch: $isWorldSearch, accountInfo: accountInfoForSegue)
                                .shadow(color: .clear, radius: 10, x: 0, y: 0)
                                .onWillAppear {
                                    DispatchQueue.main.async {
                                        viewName.name = "HomeView"
                                    }
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .navigationBarLeading) {
                                        if isWorldSearch == false {
                                            Button(action: {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    goAccount.toggle()
                                                    accountViewOpacity = 1.0
                                                }
                                            }) {
                                                Image(uiImage: accountInfo.iconImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                        } else {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        }
                    }
                    
                    if tabBarHidden.hidden == false {
                        Rectangle()
                            .fill(gradient)
                            .frame(width: UIScreen.main.bounds.size.width, height: UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                            .foregroundColor(.black.opacity(0.2))
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    if tabBarHidden.hidden == false {
                        VStack {
                            Image(systemName: "network")
                            Text("Chaos")
                        }
                    }
                }
                .tag(0)
                
                ZStack(alignment: .bottom) {
                    NavigationView {
                        ContentHomeView(isSearch: $isContentSearch, accountInfo: accountInfoForSegue)
                            .shadow(color: .clear, radius: 10, x: 0, y: 0)
                            .onWillAppear {
                                DispatchQueue.main.async {
                                    viewName.name = "ContentHomeView"
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .navigationBarLeading) {
                                    if isContentSearch == false {
                                        Button(action: {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                goAccount.toggle()
                                                accountViewOpacity = 1.0
                                            }
                                        }) {
                                            Image(uiImage: accountInfo.iconImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                    }
                    
                    if tabBarHidden.hidden == false {
                        Rectangle()
                            .fill(gradient)
                            .frame(width: UIScreen.main.bounds.size.width, height: UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                            .foregroundColor(.black.opacity(0.2))
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    if tabBarHidden.hidden == false {
                        VStack {
                            Image(systemName: "menucard")
                            Text("Creation")
                        }
                    }
                }
                .tag(1)
                
                ZStack(alignment: .bottom) {
                    NavigationView {
                        MyLibraryView(accountInfo: accountInfoForSegue, notifiedWorld: notifiedWorld, gotNotification: $gotNotification)
                            .onWillAppear {
                                DispatchQueue.main.async {
                                    viewName.name = "MyLibraryView"
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .navigationBarLeading) {
                                    Button(action: {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            goAccount.toggle()
                                            accountViewOpacity = 1.0
                                        }
                                    }) {
                                        Image(uiImage: accountInfo.iconImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                    }
                    
                    if tabBarHidden.hidden == false {
                        Rectangle()
                            .fill(gradient)
                            .frame(width: UIScreen.main.bounds.size.width, height: UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                            .foregroundColor(.black.opacity(0.2))
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    if tabBarHidden.hidden == false {
                        VStack {
                            Image(systemName: "books.vertical.fill")
                            Text("Library")
                        }
                    }
                }
                .tag(2)
            }
            .accentColor(.white)
            .onChange(of: viewName.name) { newValue in
                if viewName.name == "ChatView" || viewName.name == "ChatPhotoShowView" {
                    tabBarHidden.hidden = true
                } else {
                    let customHideViews = ["ContentShowView", "ShowImageView", "ContentScrollView", "ShowVideoView"]
                    if customHideViews.contains(viewName.name) == false {
                        tabBarHidden.hidden = false
                    }
                }
            }
            
            if goAccount {
                NavigationView {
                    MyAccountView(info: accountInfoForSegue, goAccount: $goAccount, opacity: $accountViewOpacity)
                        .onWillAppear {
                            DispatchQueue.main.async {
                                viewName.name = "MyAccountView"
                            }
                        }
                }
                .accentColor(.white)
                .opacity(accountViewOpacity)
            }
            
            if tabBarHidden.hidden {
                Rectangle()
                    .foregroundColor(.black.opacity(0.00001))
                    .frame(width: UIScreen.main.bounds.size.width, height: UITabBarController().tabBar.frame.size.height + bottomInsetHeight())
                    .padding(.bottom, 0)
                    .ignoresSafeArea()
                
                if textingBool.bool {
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.size.width, height: 50)
                                .foregroundColor(.white.opacity(0.00001))
                                .padding(.bottom, 0)
                            
                            HStack(alignment: .bottom) {
                                Button(action: {
                                    photoLibraryShow = true
                                    UIApplication.shared.closeKeyboard()
                                    textingBool.bottomHeight = bottomInsetHeight()
                                    textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
                                }) {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 24, alignment: .trailing)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.white)
                                        .card()
                                }
                                .padding(.leading, 10)
                                .padding(.bottom, 5)
                                
                                ZStack(alignment: .center) {
                                    TextingView(text: $textFieldText, height: $textingHeight, placeholder: NSLocalizedString("Add Comment", comment: ""))
                                        .frame(height: textingHeight)
                                }
                                
                                Button(action: {
                                    if textFieldText != "" {
                                        let ref = Firestore.firestore().collection("chatBoard").document(chatBoardID.id).collection("chatContent")
                                        ref.addDocument(data: [
                                            "content": textFieldText,
                                            "date": Date(),
                                            "userID": accountInfo.id,
                                            "images": [],
                                            "resizeImages": []
                                        ])
                                        chatBoardID.chatAdded = true
                                    }
                                    textFieldText = ""
                                }) {
                                    Image(systemName: "paperplane")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 24, alignment: .leading)
                                        .padding(.leading, 5)
                                        .foregroundColor(.white)
                                        .card()
                                }
                                .padding(.trailing, 10)
                                .padding(.bottom, 5)
                            }
                            .padding(.bottom, 10)
                        }
                        .padding(.bottom, 0)
                        
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.size.width, height: textingBool.bottomHeight)
                            .onChange(of: keyboard.keyboardHeight, perform: { newValue in
                                if newValue > 60 {
                                    textingBool.keyboardHeight = newValue
                                    withAnimation(.easeOut(duration: 0.235)) {
                                        textingBool.bottomHeight = newValue - 10
                                    }
                                }
                            })
                            .onWillAppear {
                                DispatchQueue.main.async {
                                    textingBool.bottomHeight = bottomInsetHeight()
                                }
                            }
                            .foregroundColor(.clear)
                    }
                    .gesture(DragGesture().onChanged({ value in
                        if value.translation.height > 40 {
                            UIApplication.shared.closeKeyboard()
                            textingBool.keyboardHeight = 0
                            textingBool.bottomHeight = bottomInsetHeight()
                        }
                    }))
                    .accentColor(.black)
                }
            }
        }
        .onAppear {
            keyboard.startObserve()
        }
        .onWillAppear {
            let userInfo = realm.objects(DeviceUser.self).first
            if let accountID = userInfo?.accountID {
                getMyAccount(accountID: accountID)
            } else {
                logInBool = true
            }
        }
        .onDisappear {
            keyboard.stopObserve()
        }
        .onChange(of: music.musicMuteBool) { newValue in
            music.finished = false
        }
        .pauseMusic(music: music, playAudio: playAudio)
        .onChange(of: music.listPressed, perform: { newValue in
            if newValue {
                if music.musicMuteBool == false && music.musicURL != URL(fileURLWithPath: "") {
                    playAudio.player?.play()
                } else {
                    playAudio.player?.stop()
                }
            }
        })
        .onChange(of: playAudio.finished, perform: { newValue in
            if newValue == true {
                music.finished = newValue
                playAudio.finished = false
            }            
        })
        .onChange(of: viewName.name, perform: { newValue in
            let noPlayViews = ["HomeView", "MyLibraryView", "LibraryDetailView", "MyAccountView", "CreatorHomeView", "ContentShowView", "ContentScrollView", "CreateContentView", "MakingScrollContentView", "MakingShowContentView", "ContentShowPreView", "ContentScrollPreView"]
            if noPlayViews.contains(newValue) && noPlayViews.contains(preViewName) {
                stopPlayingAudio()
            }
            preViewName = newValue
        })
        .onChange(of: selection, perform: { _ in
            stopPlayingAudio()
        })
        .sheet(isPresented: $photoLibraryShow) {
            ChatPHPicker()
        }
        .fullScreenCover(isPresented: $logInBool) {
            NavigationView {
                if UserDefaults.standard.bool(forKey: "agreeWithTerms") != true {
                    StartAppView(goRootView: $logInBool)
                } else {
                    CustomSignInView(goRootView: $logInBool)
                }
            }
            .accentColor(.white)
        }
        .onChange(of: authObserver.isSignIn) { value in
            if value == false {
                logInBool = true
                accountInfoForSegue.createdWorlds.removeAll()
                accountInfoForSegue.createdContents.removeAll()
            } else {
                let objects = realm.objects(DeviceUser.self)
                if logInBool == false && objects.count > 0 {
                    registerAccount(email: authObserver.email)
                }
            }
        }
        .onChange(of: logInBool) { newValue in
            if newValue == false {
                let objects = realm.objects(DeviceUser.self)
                if objects.count > 0 {
                    if let userInfo = objects.first {
                        let ref = Firestore.firestore().collection("users").document(userInfo.accountID)
                        ref.updateData(["fcmToken": FieldValue.arrayUnion([fcmToken.token()])])
                        addFCMTokenToWorld(id: userInfo.accountID, fcmTokens: [fcmToken.token()])
                        
                        try! realm.write {
                            userInfo.fcmToken = fcmToken.token()
                        }
                    }
                    
                    registerAccount(email: authObserver.email)
                }
            }
        }
        .onChange(of: appDelegate.notifiedWorldID) { value in
            if value != "" {
                selection = 1
                
                let group = DispatchGroup()
                let ref = Firestore.firestore().collection("world").document(value)
                group.enter()
                ref.getDocument { snapshot, _ in
                    guard let i = snapshot else { return }
                    notifiedWorld.id = i.documentID
                    notifiedWorld.name = i.data()!["name"] as! String
                    notifiedWorld.explanation = i.data()!["description"] as! String
                    let backgroundImage = i.data()!["backgroundImage"] as! String
                    notifiedWorld.backgroundURL = backgroundImage
                    notifiedWorld.bgm = i.data()!["bgm"] as! String
                    notifiedWorld.bgmName = i.data()!["bgmName"] as! String
                    notifiedWorld.createdUser = i.data()!["createdUser"] as! String
                    notifiedWorld.tags = i.data()!["tags"] as! [String]
                    notifiedWorld.category = i.data()!["categories"] as! [String]
                    let createdDate = i.data()!["createdDate"] as! Timestamp
                    let updatedDate = i.data()!["updatedDate"] as! Timestamp
                    notifiedWorld.createdDate = createdDate.dateValue()
                    notifiedWorld.updatedDate = updatedDate.dateValue()
                    let storage = Storage.storage()
                    
                    group.enter()
                    getUserNameAndIcon(id: notifiedWorld.createdUser) { userName, iconImage in
                        notifiedWorld.createdUserName = userName
                        notifiedWorld.createdUserIcon = iconImage
                        
                        if backgroundImage != "" {
                            group.enter()
                            storage.reference(forURL: backgroundImage).getData(maxSize: 1024 * 1024 * 10) { data, err in
                                if let err = err {
                                    print("Error: \(err)")
                                } else if let data = data {
                                    notifiedWorld.backgroundImage = UIImage(data: data) ?? UIImage()
                                }
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        gotNotification = true
                    }
                }
            }
        }
        .onChange(of: accountInfo.blockedUsers.count) { _ in
            accountInfoForSegue.blockedUsers = accountInfo.blockedUsers
        }
    }
    
    func getMyAccount(accountID: String) {
        let db = Firestore.firestore()
        let group = DispatchGroup()
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
                accountInfo.fcmTokens = document.data()!["fcmToken"] as! [String]
                accountInfo.blockedUsers = document.data()!["blockedUsers"] as! [String]
                
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
                accountInfoForSegue.name = accountInfo.name
                accountInfoForSegue.profile = accountInfo.profile
                accountInfoForSegue.born = accountInfo.born
                accountInfoForSegue.id = accountInfo.id
                accountInfoForSegue.backgroundURL = accountInfo.backgroundURL
                accountInfoForSegue.iconURL = accountInfo.iconURL
                accountInfoForSegue.createdDate = accountInfo.createdDate
                accountInfoForSegue.email = accountInfo.email
                accountInfoForSegue.accountID = accountInfo.accountID
                accountInfoForSegue.gender = accountInfo.gender
                accountInfoForSegue.fcmTokens = accountInfo.fcmTokens
                accountInfoForSegue.backgroundImage = accountInfo.backgroundImage
                accountInfoForSegue.iconImage = accountInfo.iconImage
                accountInfoForSegue.blockedUsers = accountInfo.blockedUsers
            }
        })
    }
    
    func registerAccount(email: String) {
        let group = DispatchGroup()
        let ref = Firestore.firestore().collection("users").whereField("email", isEqualTo: email)
        let date = Date()
        
        group.enter()
        ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let userInfo = DeviceUser()
            
            self.accountInfo.email = email
            self.accountInfo.createdDate = date
            
            if snapshot.documents.count > 0 {
                guard let document = snapshot.documents.first else { return }
                self.accountInfo.id = document.documentID
                self.accountInfo.name = document.data()["name"] as! String
                self.accountInfo.profile = document.data()["profile"] as! String
                self.accountInfo.born = (document.data()["born"] as! Timestamp).dateValue()
                self.accountInfo.id = document.documentID
                self.accountInfo.backgroundURL = document.data()["backgroundImage"] as! String
                self.accountInfo.iconURL = document.data()["thumbnail"] as! String
                guard let createdDate = document.data()["createdDate"] as? Timestamp else { return }
                self.accountInfo.createdDate = createdDate.dateValue()
                self.accountInfo.email = document.data()["email"] as! String
                self.accountInfo.accountID = document.data()["accountID"] as! String
                self.accountInfo.gender = document.data()["gender"] as! String
                self.accountInfo.fcmTokens = document.data()["fcmToken"] as! [String]
                self.accountInfo.blockedUsers = document.data()["blockedUsers"] as! [String]
                
                if self.accountInfo.backgroundURL != "" {
                    group.enter()
                    Storage.storage().reference(forURL: self.accountInfo.backgroundURL).getData(maxSize: 1024 * 1024 * 50) { data, err in
                        if let data = data {
                            if let image = UIImage(data: data) {
                                self.accountInfo.backgroundImage = image
                            }
                        }
                        group.leave()
                    }
                } else {
                    self.accountInfo.backgroundImage = UIImage(named: "black") ?? UIImage()
                }
                
                if self.accountInfo.iconURL != "" {
                    group.enter()
                    Storage.storage().reference(forURL: self.accountInfo.iconURL).getData(maxSize: 1024 * 1024 * 50) { data, err in
                        if let data = data {
                            if let image = UIImage(data: data) {
                                self.accountInfo.iconImage = image
                            }
                        }
                        group.leave()
                    }
                } else {
                    self.accountInfo.iconImage = UIImage(named: "black2") ?? UIImage()
                }
                userInfo.accountID = document.documentID
                userInfo.fcmToken = fcmToken.token()
            }
            group.leave()
            
            group.notify(queue: .main) {
                let objects = realm.objects(DeviceUser.self)
                try! realm.write {
                    realm.delete(objects)
                }
                
                userInfo.email = email
                try! self.realm.write {
                    self.realm.add(userInfo)
                }
                
                accountInfoForSegue.name = accountInfo.name
                accountInfoForSegue.profile = accountInfo.profile
                accountInfoForSegue.born = accountInfo.born
                accountInfoForSegue.id = accountInfo.id
                accountInfoForSegue.backgroundURL = accountInfo.backgroundURL
                accountInfoForSegue.iconURL = accountInfo.iconURL
                accountInfoForSegue.createdDate = accountInfo.createdDate
                accountInfoForSegue.email = accountInfo.email
                accountInfoForSegue.accountID = accountInfo.accountID
                accountInfoForSegue.gender = accountInfo.gender
                accountInfoForSegue.fcmTokens = accountInfo.fcmTokens
                accountInfoForSegue.backgroundImage = accountInfo.backgroundImage
                accountInfoForSegue.iconImage = accountInfo.iconImage
                accountInfoForSegue.blockedUsers = accountInfo.blockedUsers
            }
        }
    }
    
    func stopPlayingAudio() {
        DispatchQueue.main.async {
            music.musicMuteBool = true
            music.pauseBool = true
            music.musicLoop = false
            music.musicURL = URL(fileURLWithPath: "")
            music.listIndex = 0
            playAudio.player = AVAudioPlayer()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
    //static var previews: some View {
        //ContentView()
   // }
//}
