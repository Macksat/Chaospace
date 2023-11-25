//
//  EditWorldInfoView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/06.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EditWorldInfoView: View {
    @StateObject var info = WorldInfo()
    @State var explanationHeight = CGFloat(80)
    @State var nameHeight = CGFloat(42)
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var viewName = "EditWorldInfoView"
    @State var showImagePicker = false
    @State var showFile = false
    @State var tagText = ""
    @State var showCategory = false
    @State var menuOpacity = 0.0
    @State var chevronRotation = 0.0
    @State var bgmText = ""
    @State var choosePhotoSource = false
    @State var showImage = false
    @State var chooseMenuPadding = CGFloat(-20)
    @State var chooseMenuOpacity = Double(0)
    @State var fileurls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerimages = [UIImage]()
    @State var bgmURL = URL(fileURLWithPath: "")
    @State var imageSelected = false
    @State var showImageOpacity = 0.0
    @State var barHidden = false
    @State var showDeleteAlert = false
    @State var uploadFailed = false
    @State var uploadCompleted = false
    @StateObject var loadObserver = LoadObserver()
    @ObservedObject var worldInfo: WorldInfo
    @Binding var deleted: Bool
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var name: Name
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                BackgroundUIImage(image: info.backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Group {
                            Text("World Name")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            
                            ContentTextingView(text: $info.name, height: $nameHeight, viewBottomHeight: $bottomHeight, originalHeight: 42, fontSize: 20, fontWeight: .medium, textAlignment: .left, placeholder: NSLocalizedString("Enter World Name", comment: ""), textLimit: 30)
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: nameHeight)
                                .padding(.top, 10)
                            
                            HStack {
                                Spacer()
                                
                                Text("\(info.name.count)/30")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .regular))
                                    .card()
                            }
                            .padding(.top, 5)
                        }
                        
                        Text("Description")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                        
                        ContentTextingView(text: $info.explanation, height: $explanationHeight, viewBottomHeight: $bottomHeight, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Description of This World", comment: ""), textLimit: 300)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: explanationHeight)
                            .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            
                            Text("\(info.explanation.count)/300")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                                .card()
                        }
                        .padding(.top, 5)
                        
                        Group {
                            Text("Genre")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            Button(action: {
                                categoryMenu(buttonBool: true)
                            }) {
                                VStack(spacing: 1) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/6)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        HStack {
                                            Text("Tap to Choose Genres")
                                                .foregroundColor(.black)
                                                .font(.system(size: 17, weight: .medium))
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .rotationEffect(.degrees(chevronRotation))
                                                .foregroundColor(.black)
                                                .padding(.trailing, 8)
                                        }
                                        .padding([.top, .bottom], 8)
                                        .padding([.leading, .trailing], 8)
                                    }
                                    
                                    if showCategory {
                                        ForEach(1..<categoryArray.count, id: \.self) { i in
                                            Button(action: {
                                                if let index = info.category.firstIndex(where: ({ $0 == categoryArray[i] })) {
                                                    info.category.remove(at: index)
                                                } else {
                                                    info.category.append(categoryArray[i])
                                                }
                                            }) {
                                                ZStack {
                                                    Rectangle()
                                                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 44)
                                                        .foregroundColor(.white.opacity(0.7))
                                                    
                                                    HStack {
                                                        Text(categoryArray[i])
                                                            .foregroundColor(.black)
                                                            .font(.system(size: 17, weight: .medium))
                                                            .padding(.leading, 8)
                                                        
                                                        Spacer()
                                                        
                                                        if info.category.filter({ $0 == categoryArray[i] }).first != nil {
                                                            Image(systemName: "checkmark")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 17, height: 17)
                                                                .foregroundColor(.black)
                                                                .padding(.trailing, 16)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .opacity(menuOpacity)
                                        .onAppear {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                menuOpacity = 1.0
                                            }
                                        }
                                    }
                                }
                                .cornerRadius(15)
                            }
                            .padding(.top, 10)
                        }
                        
                        Group {
                            Text("Background Image")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            ChooseBackgroundView(showContentMenu: $choosePhotoSource, image: $info.backgroundImage, showImage: $showImage)
                                .padding(.top, 10)
                            
                            Button(action: {
                                info.backgroundImage = UIImage(named: "black") ?? UIImage()
                                imageSelected = true
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
                        
                        Group {
                            Text("BGM")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            Button(action: {
                                showFile.toggle()
                            }) {
                                ZStack {
                                    Rectangle()
                                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
                                        .foregroundColor(.white.opacity(0.7))
                                        .cornerRadius(15)
                                    
                                    if bgmText == "" {
                                        Text("Tap to Choose BGM")
                                            .foregroundColor(.black)
                                            .font(.system(size: 17, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .frame(width: UIScreen.main.bounds.size.width - 56, alignment: .leading)
                                            .padding([.top, .bottom], 8)
                                            .padding([.leading, .trailing], 8)
                                    } else {
                                        Text(bgmText)
                                            .foregroundColor(.black)
                                            .font(.system(size: 17, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .frame(width: UIScreen.main.bounds.size.width - 56, alignment: .leading)
                                            .padding([.top, .bottom], 8)
                                            .padding([.leading, .trailing], 8)
                                    }
                                }
                            }
                            .padding(.top, 10)
                            
                            Button(action: {
                                info.bgm = ""
                                info.bgmName = ""
                                bgmText = ""
                                bgmURL = URL(fileURLWithPath: "")
                            }) {
                                HStack {
                                    Text("Clear BGM")
                                        .underline()
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                        .card()
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        Group {
                            Text("Tags")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            TagTextingView(text: $tagText, viewBottomHeight: $bottomHeight, tagArray: $info.tags, fontSize: 20, fontWeight: .medium, textAlignment: .left, placeholder: NSLocalizedString("Enter Tags", comment: ""))
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: 42)
                                .padding(.top, 10)
                            
                            generateTags()
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .padding(.top, 10)
                                .padding(.bottom, 40)
                        }
                        
                        Button(action: {
                            showDeleteAlert.toggle()
                        }) {
                            Text("Delete World")
                                .font(.system(size: 20, weight: .medium))
                                .padding([.top, .bottom], 3)
                                .padding([.leading, .trailing], 10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 2)
                                }
                                .foregroundColor(.red)
                                .card()
                        }
                        .padding(.top, 20)
                        .alert(isPresented: $showDeleteAlert, content: {
                            Alert(title: Text("Caution"),
                                  message: Text("Do you want to delete this world?"),
                                  primaryButton: .default(Text("Cancel"), action: {
                                        showDeleteAlert = false
                                    }),
                                  secondaryButton: .destructive(Text("Delete"), action: {
                                        let group = DispatchGroup()
                                        let worldReference = Firestore.firestore().collection("world").document(worldInfo.id)
                                        group.enter()
                                        worldReference.getDocument { snapshot, _ in
                                            var boardBatch = Firestore.firestore().batch()
                                            var chatBatch = Firestore.firestore().batch()
                                            guard let i = snapshot else { return }
                                            let chatRef = Firestore.firestore().collection("chatBoard")
                                            group.enter()
                                            requestFirebaseSnapshot(ref: chatRef, whereField: "worldID", equalTo: i.documentID) { chatBoardSnapshot in
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
                                            
                                            let announceRef = worldReference.collection("announcements")
                                            group.enter()
                                            requestFirebaseSnapshot(ref: announceRef, whereField: "", equalTo: "") { announceSnapshot in
                                                let batch = Firestore.firestore().batch()
                                                announceSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                batch.commit()
                                                group.leave()
                                            }
                                            
                                            let categoryRef = worldReference.collection("contentCategory")
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
                                            
                                            worldReference.delete()
                                            group.leave()
                                        }
                                
                                        let contentRef = Firestore.firestore().collection("contents")
                                        group.enter()
                                        requestFirebaseSnapshot(ref: contentRef, whereField: "parentWorld", equalTo: worldInfo.id) { snapshot in
                                            var contentBatch = Firestore.firestore().batch()
                                            for (iIndex, i) in snapshot.documents.enumerated() {
                                                var batch = Firestore.firestore().batch()
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
                                                                musicSnapshot.documents.forEach { musicBatch.deleteDocument($0.reference) }
                                                                group.leave()
                                                            }
                                                            
                                                            batch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == scrollSnapshot.documents.count - 1 {
                                                                batch.commit()
                                                                batch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        scrollSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
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
                                                
                                                contentBatch.deleteDocument(i.reference)
                                                if (iIndex + 1) % 500 == 0 || iIndex == snapshot.documents.count - 1 {
                                                    contentBatch.commit()
                                                    contentBatch = Firestore.firestore().batch()
                                                }
                                            }
                                            group.leave()
                                        }
                                        
                                        group.notify(queue: .main) {
                                            deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)")
                                            deleted = true
                                            worldInfo.deleted = true
                                            dismiss()
                                        }
                                    })
                                  )
                        })
                    }
                    .padding(.bottom, 30 + bottomHeight)
                    .padding([.leading, .trailing], 20)
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
                    ShowImageView(image: info.backgroundImage, showImageBool: $showImage,  barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
                        .opacity(showImageOpacity)
                }
                
                if loadObserver.isLoading {
                    LoadingView()
                        .opacity(loadObserver.opacity)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .gesture(TapGesture().onEnded({ _ in
            categoryMenu(buttonBool: false)
        }))
        .sheet(isPresented: $showImagePicker, content: {
            SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerimages)
        })
        .onChange(of: showImagePicker, perform: { value in
            if value == false && pickerimages.count > 0 {
                info.backgroundImage = pickerimages[0]
                imageSelected = true
                pickerimages.removeAll()
            }
        })
        .sheet(isPresented: $showFile, content: {
            if viewName == "EditWorldViewPhoto" {
                FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
            } else {
                FileView(multipleSelection: false, fileType: "music", urls: $fileurls)
            }
        })
        .onChange(of: fileurls.count, perform: { count in
            if count > 0 {
                if viewName == "EditWorldViewPhoto" {
                    do {
                        let data = try Data(contentsOf: fileurls[0])
                        if let image = UIImage(data: data) {
                            info.backgroundImage = image
                            imageSelected = true
                            print("image selected")
                        }
                    } catch {
                        print("Failed to get image.")
                    }
                    viewName = "EditWorldInfoView"
                } else {
                    bgmURL = fileurls[0]
                    info.bgmURL = fileurls[0]
                    bgmText = fileurls[0].lastPathComponent
                    if let mp3 = bgmText.range(of: ".mp3") {
                        bgmText.replaceSubrange(mp3, with: "")
                    }
                }
                fileurls.removeAll()
            }
        })
        .onChange(of: showFile, perform: { value in
            if value == false && fileurls.count == 0 {
                viewName = "EditWorldInfoView"
            }
        })
        .onChange(of: uploadCompleted) { newValue in
            if newValue {
                dismiss()
            }
        }
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
                if info.name != "" {
                    Button(action: {
                        loadObserver.isLoading = true
                        withAnimation(.linear(duration: 0.3)) {
                            loadObserver.opacity = 1.0
                        }
                        
                        info.bgmURL = bgmURL
                        
                        let group = DispatchGroup()
                        let ref = Firestore.firestore().collection("world").document(worldInfo.id)
                        
                        Storage.storage().reference(forURL: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)").listAll() { result, _ in
                            guard let result = result else { return }
                            for i in result.items {
                                i.delete { err in
                                    if let err = err {
                                        print(err)
                                    }
                                }
                            }
                        }
                        
                        group.enter()
                        DispatchQueue(label: "editUploadTask").async {
                            group.enter()
                            DispatchQueue(label: "editBGMUpload").async {
                                if bgmURL != URL(fileURLWithPath: "") {
                                    let storageRef = Storage.storage().reference()
                                    let bgmPath = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/bgm_\(UUID()).mp3"
                                    var bgmData = Data()
                                    let semaphore = DispatchSemaphore(value: 0)
                                    do {
                                        bgmData = try Data(contentsOf: bgmURL)
                                        semaphore.signal()
                                    } catch {
                                        print("failed to get data.")
                                        semaphore.signal()
                                    }
                                    semaphore.wait()
                                    
                                    let bgmMetadata = StorageMetadata()
                                    bgmMetadata.contentType = "music/mp3"
                                    let bgmRef = storageRef.child(bgmPath)
                                    let bgmUploadTask = bgmRef.putData(bgmData, metadata: bgmMetadata)
                                    ref.updateData(["bgm" : bgmPath])
                                    
                                    group.enter()
                                    bgmUploadTask.observe(.failure) { _ in
                                        info.bgm = ""
                                        info.bgmURL = URL(fileURLWithPath: "")
                                        info.bgmName = ""
                                        uploadFailed = true
                                        group.leave()
                                    }
                                    
                                    bgmUploadTask.observe(.success) { _ in
                                        group.leave()
                                    }
                                } else {
                                    if info.bgm == "" && worldInfo.bgm != "" {
                                        ref.updateData(["bgm": ""])
                                    }
                                }
                                group.leave()
                            }
                            
                            if info.backgroundImage != UIImage(named: "black") ?? UIImage() {
                                let storageRef = Storage.storage().reference()
                                let path = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/image_\(UUID()).png"
                                var imageData = Data()
                                if imageSelected {
                                    imageData = customCompressImage(image: info.backgroundImage, rate: 0.3)
                                } else {
                                    imageData = info.backgroundImage.jpegData(compressionQuality: 1) ?? Data()
                                }
                                let imageRef = storageRef.child(path)
                                let metadata = StorageMetadata()
                                metadata.contentType = "image/png"
                                let uploadTask = imageRef.putData(imageData, metadata: metadata)
                                
                                group.enter()
                                uploadTask.observe(.success) { _ in
                                    imageRef.downloadURL { url, err in
                                        if let url = url {
                                            let imageURL = url.absoluteString
                                            ref.updateData(["backgroundImage" : imageURL])
                                            info.backgroundURL = imageURL
                                        }
                                    }
                                    group.leave()
                                }
                            } else {
                                ref.updateData(["backgroundImage": ""])
                            }
                            group.leave()
                        }
                        
                        group.notify(queue: .main) {
                            var queryWords = [String]()
                            queryWords.append(contentsOf: searchMapArray(text: info.name))
                            queryWords.append(contentsOf: searchMapArray(text: accountInfo.name))
                            queryWords.append(contentsOf: searchMapArray(text: accountInfo.accountID))
                            for i in info.category {
                                queryWords.append(contentsOf: searchMapArray(text: i))
                            }
                            for i in info.tags {
                                queryWords.append(contentsOf: searchMapArray(text: i))
                            }
                            var searchMap: [String: Bool] = [:]
                            for i in queryWords {
                                searchMap[i] = true
                            }
                            
                            ref.updateData([
                                "description": info.explanation,
                                "name": info.name,
                                "categories": info.category,
                                "tags": info.tags,
                                "bgmName": bgmText,
                                "updatedDate": Date(),
                                "searchMap": searchMap
                            ])
                            
                            withAnimation(.linear(duration: 0.3)) {
                                loadObserver.opacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                loadObserver.isLoading = false
                            }
                            
                            worldInfo.id = info.id
                            worldInfo.backgroundImage = info.backgroundImage
                            worldInfo.backgroundURL = info.backgroundURL
                            worldInfo.name = info.name
                            worldInfo.explanation = info.explanation
                            worldInfo.bgm = info.bgm
                            worldInfo.bgmURL = info.bgmURL
                            worldInfo.bgmName = bgmText
                            worldInfo.tags = info.tags
                            worldInfo.category = info.category
                            
                            if uploadFailed == false {
                                uploadCompleted = true
                            }
                        }
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    }
                    .alert(isPresented: $uploadFailed, content: {
                        Alert(title: Text("Error"),
                              message: Text("Failed to upload BGM because the size is more than 10 MB."),
                              dismissButton: .default(Text("OK"), action: {
                                    uploadFailed = false
                                    dismiss()
                                })
                              )
                    })
                } else {
                    Text("Done")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                }
            }
        }
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "EditWorldInfoView"
                
                info.id = worldInfo.id
                info.backgroundImage = worldInfo.backgroundImage
                info.backgroundURL = worldInfo.backgroundURL
                info.name = worldInfo.name
                info.explanation = worldInfo.explanation
                info.bgm = worldInfo.bgm
                info.bgmURL = worldInfo.bgmURL
                info.bgmName = worldInfo.bgmName
                info.tags = worldInfo.tags
                info.category = worldInfo.category
            }
            bgmText = worldInfo.bgmName
            bgmURL = worldInfo.bgmURL
        }
        .onWillDisappear {
            name.name = "CreatorHomeView"
            if info.category.count == 0 {
                info.category.append("Others")
            }
        }
    }
    
    func categoryMenu(buttonBool: Bool) {
        if showCategory {
            withAnimation(.easeOut(duration: 0.2)) {
                menuOpacity = 0.0
                chevronRotation = 0.0
                showCategory = false
            }
        } else {
            if buttonBool {
                withAnimation(.easeOut(duration: 0.2)) {
                    chevronRotation = 180.0
                    showCategory = true
                }
            }
        }
    }
    
    private func generateTags() -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(0..<info.tags.count, id: \.self) { i in
                item(for: info.tags[i], index: i)
                    .padding(5)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > UIScreen.main.bounds.size.width - 40 {
                            width = 0
                            height -= tagHeight(text: info.tags[i-1]) + 5
                        }
                        let result = width
                        if info.tags[i] == info.tags.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if info.tags[i] == info.tags.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
      
    func item(for text: String, index: Int) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 20, weight: .medium))
            
            Button(action: {
                info.tags.remove(at: index)
            }) {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            }
        }
        .padding([.leading, .trailing], 5)
        .padding([.top, .bottom], 3)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 2)
        }
        .foregroundColor(.white)
        .card()
    }
    
    func tagHeight(text: String) -> CGFloat {
        let width = UIScreen.main.bounds.size.width - 40
        let height = text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .medium)], context: nil).height
        return height + 10
    }
}

//struct EditWorldInfoView_Previews: PreviewProvider {
    //static var previews: some View {
        //EditWorldInfoView()
    //}
//}
