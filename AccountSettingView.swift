//
//  AccountSettingView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/25.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuthUI
import RealmSwift

struct AccountSettingView: View {
    
    let realm = try! Realm()
    @State var profileHeight = CGFloat(80)
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var showImagePicker = false
    @State var viewName = "AccountSettingView"
    @State var choosePhotoSource = false
    @State var chooseMenuPadding = CGFloat(-20)
    @State var chooseMenuOpacity = Double(0)
    @State var showFile = false
    @State var showImage = false
    @State var iconChanged = false
    @State var backgroundChanged = false
    @State var signOutAlert = false
    @State var deleteAccount = false
    @State var name = ""
    @State var profile = ""
    @State var fileurls = [URL]()
    @State var pickerImages = [UIImage]()
    @State var pickerurls = [URL]()
    @State var iconImage = UIImage()
    @State var backgroundImage = UIImage()
    @State var showImageOpacity = 0.0
    @State var barHidden = false
    @Binding var goAccount: Bool
    @ObservedObject var infoForSegue: AccountInfo
    @EnvironmentObject var info: AccountInfo
    @EnvironmentObject var viewNameObject: Name
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                BackgroundUIImage(image: backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Button(action: {
                            viewName = "AccountSettingViewIcon"
                            choosePhotoSource.toggle()
                        }) {
                            ZStack(alignment: .bottom) {
                                Image(uiImage: iconImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.width/3)
                                    .clipShape(Circle())
                                
                                Circle()
                                    .foregroundColor(.black.opacity(0.2))
                                    .frame(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.width/3)
                                
                                HStack(alignment: .bottom) {
                                    Text("Change Image")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .regular))
                                    
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                            }
                            .card()
                        }
                        .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                        
                        Text("Name")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                        
                        TextField("Enter User Name", text: $name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                            .background(.white.opacity(0.7))
                            .cornerRadius(15)
                            .padding(.top, 10)
                        
                        Text("Profile")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                        
                        ContentTextingView(text: $profile, height: $profileHeight, viewBottomHeight: $bottomHeight, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Introduce Yourself", comment: ""), textLimit: 200)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: profileHeight)
                            .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            
                            Text("\(profile.count)/200")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                                .card()
                        }
                        .padding(.top, 5)
                        
                        Group {
                            Text("Background Image")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            ChooseBackgroundView(showContentMenu: $choosePhotoSource, image: $backgroundImage, showImage: $showImage)
                                .padding(.top, 10)
                            
                            Button(action: {
                                backgroundImage = UIImage(named: "black") ?? UIImage()
                            }) {
                                HStack {
                                    Text("Clear Background Image")
                                        .underline()
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                        .card()
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        NavigationLink(destination: BlockListView(backgroundImage: $backgroundImage)) {
                            HStack {
                                Text("Blocked Users")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.forward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                        .card()
                        .padding(.top, 40)
                        
                        Group {
                            Button(action: {
                                signOutAlert.toggle()
                            }) {
                                Text("Sign out")
                                    .font(.system(size: 20, weight: .medium))
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 5)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                    }
                                    .foregroundColor(.white)
                                    .card()
                            }
                            .padding(.top, 56)
                            .alert(isPresented: $signOutAlert, content: {
                                Alert(title: Text("Caution"),
                                      message: Text("Do you want to sign out?"),
                                      primaryButton: .default(Text("Cancel"), action: {
                                            signOutAlert = false
                                        }),
                                      secondaryButton: .destructive(Text("Sign out"), action: {
                                            guard let userInfo = realm.objects(DeviceUser.self).first else { return }
                                            let ref = Firestore.firestore().collection("users").document(info.id)
                                            ref.updateData(["fcmToken": FieldValue.arrayRemove([userInfo.fcmToken])])
                                            deleteFCMTokenFromWorld(id: info.id, fcmTokens: [userInfo.fcmToken])
                                            info.email = ""
                                            info.name = ""
                                            info.id = ""
                                            info.createdDate = Date()
                                            info.createdWorlds = []
                                            info.createdContents = []
                                            info.iconURL = ""
                                            info.iconImage = UIImage()
                                            info.backgroundImage = UIImage()
                                            info.profile = ""
                                            info.born = Date()
                                            info.readChats = []
                                            let objects = realm.objects(DeviceUser.self)
                                            try! realm.write {
                                                if objects.count > 0 {
                                                    realm.delete(objects)
                                                }
                                            }
                                            goAccount = false
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                let authUI = FUIAuth.defaultAuthUI()
                                                do {
                                                    try authUI?.signOut()
                                                } catch {
                                                    print("Could not sign out.")
                                                }
                                            }
                                        })
                                )
                            })
                            
                            Button(action: {
                                deleteAccount.toggle()
                            }) {
                                Text("Delete Account")
                                    .font(.system(size: 20, weight: .medium))
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 5)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                    }
                                    .foregroundColor(.red)
                                    .card()
                            }
                            .padding(.top, 64)
                            .alert(isPresented: $deleteAccount, content: {
                                Alert(title: Text("Caution"),
                                      message: Text("Do you want to delete this account?"),
                                      primaryButton: .default(Text("Cancel"), action: {
                                            deleteAccount = false
                                        }),
                                      secondaryButton: .destructive(Text("Delete"), action: {
                                            guard let userInfo = realm.objects(DeviceUser.self).first else { return }
                                            let ref = Firestore.firestore().collection("users").document(info.id)
                                            ref.updateData(["fcmToken": FieldValue.arrayRemove([userInfo.fcmToken])])
                                            deleteFCMTokenFromWorld(id: info.id, fcmTokens: [userInfo.fcmToken])
                                            let group = DispatchGroup()
                                    
                                            let readRef = ref.collection("readChats")
                                            group.enter()
                                            readRef.getDocuments { snapshot, _ in
                                                var batch = Firestore.firestore().batch()
                                                guard let snapshot = snapshot else { return }
                                                for (iIndex, i) in snapshot.documents.enumerated() {
                                                    batch.deleteDocument(i.reference)
                                                    if (iIndex + 1) % 500 == 0 || iIndex == snapshot.documents.count - 1 {
                                                        batch.commit()
                                                        batch = Firestore.firestore().batch()
                                                    }
                                                }
                                                snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                group.leave()
                                            }
                                    
                                            let worldReference = Firestore.firestore().collection("world")
                                            group.enter()
                                            requestFirebaseSnapshot(ref: worldReference, whereField: "createdUser", equalTo: info.id) { snapshot in
                                                var worldBatch = Firestore.firestore().batch()
                                                for (iIndex, i) in snapshot.documents.enumerated() {
                                                    let chatRef = Firestore.firestore().collection("chatBoard")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: chatRef, whereField: "worldID", equalTo: i.documentID) { chatBoardSnapshot in
                                                        var boardBatch = Firestore.firestore().batch()
                                                        var chatBatch = Firestore.firestore().batch()
                                                        for (jIndex, j) in chatBoardSnapshot.documents.enumerated() {
                                                            let chatContentRef = chatRef.document(j.documentID).collection("chatContent")
                                                            group.enter()
                                                            requestFirebaseSnapshot(ref: chatContentRef, whereField: "", equalTo: "") { chatSnapshot in
                                                                for (kIndex, k) in chatSnapshot.documents.enumerated() {
                                                                    chatBatch.deleteDocument(k.reference)
                                                                    if (kIndex + 1) % 500 == 0 || kIndex == chatSnapshot.documents.count - 1 {
                                                                        chatBatch.commit()
                                                                        chatBatch = Firestore.firestore().batch()
                                                                    }
                                                                }
                                                                chatSnapshot.documents.forEach { chatBatch.deleteDocument($0.reference) }
                                                                group.leave()
                                                            }
                                                            
                                                            boardBatch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == chatBoardSnapshot.documents.count - 1 {
                                                                boardBatch.commit()
                                                                boardBatch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        group.leave()
                                                    }
                                                    
                                                    let announceRef = worldReference.document(i.documentID).collection("announcements")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: announceRef, whereField: "", equalTo: "") { announceSnapshot in
                                                        let batch = Firestore.firestore().batch()
                                                        announceSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                        batch.commit()
                                                        group.leave()
                                                    }
                                                    
                                                    let categoryRef = worldReference.document(i.documentID).collection("contentCategory")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: categoryRef, whereField: "", equalTo: "") { categorySnapshot in
                                                        var batch = Firestore.firestore().batch()
                                                        for (jIndex, j) in categorySnapshot.documents.enumerated() {
                                                            batch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == categorySnapshot.documents.count - 1 {
                                                                batch.commit()
                                                                batch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        categorySnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                        group.leave()
                                                    }
                                                    
                                                    worldBatch.deleteDocument(worldReference.document(i.documentID))
                                                    if (iIndex + 1) % 500 == 0 || iIndex == snapshot.documents.count - 1 {
                                                        worldBatch.commit()
                                                        worldBatch = Firestore.firestore().batch()
                                                    }
                                                }
                                                group.leave()
                                            }
                                    
                                            let contentRef = Firestore.firestore().collection("contents")
                                            group.enter()
                                            requestFirebaseSnapshot(ref: contentRef, whereField: "createdUser", equalTo: info.id) { snapshot in
                                                var batch = Firestore.firestore().batch()
                                                var contentBatch = Firestore.firestore().batch()
                                                for i in snapshot.documents {
                                                    switch i.data()["style"] as? String {
                                                    case "scroll":
                                                        let scrollRef = contentRef.document(i.documentID).collection("scrollContent")
                                                        group.enter()
                                                        requestFirebaseSnapshot(ref: scrollRef, whereField: "", equalTo: "") { scrollSnapshot in
                                                            for (jIndex, j) in scrollSnapshot.documents.enumerated() {
                                                                let musicRef = scrollRef.document(j.documentID).collection("musicList")
                                                                group.enter()
                                                                requestFirebaseSnapshot(ref: musicRef, whereField: "", equalTo: "") { musicSnapshot in
                                                                    var musicBatch = Firestore.firestore().batch()
                                                                    for (kIndex, k) in musicSnapshot.documents.enumerated() {
                                                                        musicBatch.deleteDocument(k.reference)
                                                                        if (kIndex + 1) % 500 == 0 || kIndex == musicSnapshot.documents.count - 1 {
                                                                            musicBatch.commit()
                                                                            musicBatch = Firestore.firestore().batch()
                                                                        }
                                                                    }
                                                                    musicSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                                    group.leave()
                                                                }
                                                                
                                                                batch.deleteDocument(j.reference)
                                                                if (jIndex + 1) % 500 == 0 || jIndex == scrollSnapshot.documents.count - 1 {
                                                                    batch.commit()
                                                                    batch = Firestore.firestore().batch()
                                                                }
                                                            }
                                                            group.leave()
                                                        }
                                                    case "show":
                                                        let showRef = contentRef.document(i.documentID).collection("showContent")
                                                        group.enter()
                                                        requestFirebaseSnapshot(ref: showRef, whereField: "", equalTo: "") { showSnapshot in
                                                            for (jIndex, j) in showSnapshot.documents.enumerated() {
                                                                batch.deleteDocument(j.reference)
                                                                if (jIndex + 1) % 500 == 0 || jIndex == showSnapshot.documents.count - 1 {
                                                                    batch.commit()
                                                                    batch = Firestore.firestore().batch()
                                                                }
                                                            }
                                                            group.leave()
                                                        }
                                                    case "article":
                                                        let articleRef = contentRef.document(i.documentID).collection("articleContent")
                                                        group.enter()
                                                        requestFirebaseSnapshot(ref: articleRef, whereField: "", equalTo: "") { articleSnapshot in
                                                            for (jIndex, j) in articleSnapshot.documents.enumerated() {
                                                                batch.deleteDocument(j.reference)
                                                                if (jIndex + 1) % 500 == 0 || jIndex == articleSnapshot.documents.count - 1 {
                                                                    batch.commit()
                                                                    batch = Firestore.firestore().batch()
                                                                }
                                                            }
                                                            group.leave()
                                                        }
                                                    default: break
                                                    }
                                                }
                                                
                                                for (iIndex, i) in snapshot.documents.enumerated() {
                                                    contentBatch.deleteDocument(i.reference)
                                                    if (iIndex + 1) % 500 == 0 || iIndex == snapshot.documents.count - 1 {
                                                        contentBatch.commit()
                                                        contentBatch = Firestore.firestore().batch()
                                                    }
                                                }
                                                group.leave()
                                            }
                                    
                                            group.notify(queue: .main) {
                                                ref.delete()
                                            }
                                                                                        
                                            deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(info.id)")
                                    
                                            Auth.auth().currentUser?.delete()
                                    
                                            info.email = ""
                                            info.name = ""
                                            info.id = ""
                                            info.createdDate = Date()
                                            info.createdWorlds = []
                                            info.createdContents = []
                                            info.iconURL = ""
                                            info.iconImage = UIImage()
                                            info.backgroundImage = UIImage()
                                            info.profile = ""
                                            info.born = Date()
                                            info.readChats = []
                                            let objects = realm.objects(DeviceUser.self)
                                            try! realm.write {
                                                if objects.count > 0 {
                                                    realm.delete(objects)
                                                }
                                            }
                                            goAccount = false
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                let authUI = FUIAuth.defaultAuthUI()
                                                do {
                                                    try authUI?.signOut()
                                                } catch {
                                                    print("Could not sign out.")
                                                }
                                            }
                                        })
                                )
                            })
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, 30 + bottomHeight)
                }
                
                if choosePhotoSource {
                    VStack {
                        Spacer()
                        
                        ChooseFileOrLibrary(photoLibraryShow: $showImagePicker, fileShow: $showFile, menuShow: $choosePhotoSource, padding: $chooseMenuPadding, opacity: $chooseMenuOpacity, viewName: $viewName)
                            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() - 10)
                            .padding([.leading, .trailing], 20)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    chooseMenuPadding = 20.0
                                    chooseMenuOpacity = 1.0
                                }
                            }
                        }
                }
                
                if showImage {
                    ShowImageView(image: backgroundImage, showImageBool: $showImage, barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
                        .opacity(showImageOpacity)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .gesture(TapGesture().onEnded({ _ in
            UIApplication.shared.closeKeyboard()
        }))
        .sheet(isPresented: $showImagePicker, content: {
            SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerImages)
        })
        .onChange(of: showImagePicker, perform: { value in
            if value == false && pickerImages.count > 0 {
                if viewName == "AccountSettingView" {
                    backgroundImage = pickerImages[0]
                    backgroundChanged = true
                } else {
                    iconImage = pickerImages[0]
                    iconChanged = true
                    viewName = "AccountSettingView"
                }
                    pickerImages.removeAll()
            } else if value == false && pickerImages.count == 0 {
                viewName = "AccountSettingView"
            }
        })
        .sheet(isPresented: $showFile, content: {
            FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
        })
        .onChange(of: showFile, perform: { value in
            if value == false && fileurls.count > 0 {
                if viewName == "AccountSettingView" {
                    do {
                        let data = try Data(contentsOf: fileurls[0])
                        if let image = UIImage(data: data) {
                            backgroundImage = image
                            backgroundChanged = true
                        }
                    } catch {
                        print("Failed to get image.")
                    }
                } else {
                    do {
                        let data = try Data(contentsOf: fileurls[0])
                        if let image = UIImage(data: data) {
                            iconImage = image
                            iconChanged = true
                        }
                    } catch {
                        print("Failed to get image.")
                    }
                    viewName = "AccountSettingView"
                }
                fileurls.removeAll()
            } else if value == false && fileurls.count == 0 {
                viewName = "AccountSettingView"
            }
        })
        .ignoresSafeArea()
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if name != "" {
                    Button(action: {
                        let ref = Firestore.firestore().collection("users").document(info.id)
                        ref.updateData([
                            "name": name,
                            "profile": profile,
                            "updatedDate": Date(),
                        ])
                        
                        Storage.storage().reference(forURL: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(info.id)").listAll() { result, _ in
                            guard let result = result else { return }
                            for i in result.items {
                                i.delete { err in
                                    if let err = err {
                                        print(err)
                                    }
                                }
                            }
                        }
                        
                        let storageRef = Storage.storage().reference()
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/png"
                        if backgroundImage != UIImage(named: "black") ?? UIImage() {
                            let path = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(info.id)/backgroundImage_\(UUID()).png"
                            var imageData = Data()
                            if backgroundChanged {
                                imageData = customCompressImage(image: backgroundImage, rate: 0.3)
                            } else {
                                imageData = backgroundImage.jpegData(compressionQuality: 1) ?? Data()
                            }
                            let imageRef = storageRef.child(path)
                            let uploadTask = imageRef.putData(imageData, metadata: metadata)
                            uploadTask.observe(.success) { _ in
                                imageRef.downloadURL { imageURL, err in
                                    if let imageURL = imageURL {
                                        let urlStr = imageURL.absoluteString
                                        ref.updateData(["backgroundImage": urlStr])
                                        info.backgroundURL = urlStr
                                    }
                                }
                            }
                        } else {
                            ref.updateData(["backgroundImage": ""])
                        }
                        
                        if iconImage != UIImage(named: "black2") ?? UIImage() {
                            let iconPath = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(info.id)/iconImage_\(UUID()).png"
                            var iconData = Data()
                            if iconChanged {
                                iconData = customCompressImage(image: iconImage, rate: 0.3)
                            } else {
                                iconData = iconImage.jpegData(compressionQuality: 1) ?? Data()
                            }
                            let iconRef = storageRef.child(iconPath)
                            let iconUploadTask = iconRef.putData(iconData, metadata: metadata)
                            iconUploadTask.observe(.success) { _ in
                                iconRef.downloadURL { imageURL, err in
                                    if let imageURL = imageURL {
                                        var resizeURL = imageURL.absoluteString
                                        if let png = imageURL.absoluteString.range(of: ".png") {
                                            resizeURL.replaceSubrange(png, with: "_250x250.png")
                                            ref.updateData(["thumbnail": resizeURL])
                                            info.iconURL = resizeURL
                                        }
                                    }
                                }
                            }
                        } else {
                            ref.updateData(["thumbnail": ""])
                        }
                        
                        info.name = name
                        info.profile = profile
                        info.iconImage = iconImage
                        info.backgroundImage = backgroundImage
                        
                        infoForSegue.name = name
                        infoForSegue.profile = profile
                        infoForSegue.iconImage = iconImage
                        infoForSegue.backgroundImage = backgroundImage
                        
                        dismiss()
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    }
                } else {
                    Text("Done")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                }
            }
        }
        .onWillAppear {
            name = info.name
            profile = info.profile
            iconImage = info.iconImage
            backgroundImage = info.backgroundImage
            
            DispatchQueue.main.async {
                viewNameObject.name = "AccountSettingView"
            }
        }
    }
}

//struct AccountSettingView_Previews: PreviewProvider {
    //static var previews: some View {
        //AccountSettingView()
    //}
//}
