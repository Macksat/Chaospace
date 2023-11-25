//
//  EditCategoryInfoView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/07.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EditCategoryInfoView: View {
    
    @State var info: (name: String, description: String, backgroundImage: UIImage) = ("", "", UIImage())
    @State var explanationHeight = CGFloat(80)
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30
    @State var viewName = "EditCategoryInfoView"
    @State var showImagePicker = false
    @State var showFile = false
    @State var choosePhotoSource = false
    @State var showImage = false
    @State var chooseMenuPadding = CGFloat(-20)
    @State var chooseMenuOpacity = Double(0)
    @State var fileurls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerimages = [UIImage]()
    @State var preImageURL = ""
    @State var gotContent = false
    @State var showImageOpacity = 0.0
    @State var createContentBool = false
    @State var barHidden = false
    @State var showDeleteAlert = false
    @ObservedObject var worldInfo: WorldInfo
    @Binding var categoryIndex: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                BackgroundUIImage(image: info.backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Category Name")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            .padding([.leading, .trailing], 20)
                        
                        TextField("Edit Category Name", text: $info.name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                            .background(.white.opacity(0.7))
                            .cornerRadius(15)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 20)
                        
                        Text("Description")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                            .padding([.leading, .trailing], 20)
                        
                        ContentTextingView(text: $info.description, height: $explanationHeight, viewBottomHeight: $bottomHeight, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Description of This Category", comment: ""), textLimit: 300)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: explanationHeight)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 20)
                        
                        HStack {
                            Spacer()
                            
                            Text("\(info.description.count)/300")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                                .card()
                        }
                        .padding(.top, 5)
                        .padding([.leading, .trailing], 20)
                        
                        Group {
                            Text("Background Image")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            ChooseBackgroundView(showContentMenu: $choosePhotoSource, image: $info.backgroundImage, showImage: $showImage, text: NSLocalizedString("Tap to Choose Image", comment: ""))
                            .padding(.top, 10)
                            
                            Button(action: {
                                info.backgroundImage = worldInfo.backgroundImage
                                preImageURL = worldInfo.contentCategory[categoryIndex].backgroundURL
                            }) {
                                HStack {
                                    Text("Select the Same Background as Home")
                                        .underline()
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .regular))
                                        .card()
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding([.leading, .trailing], 20)
                       
                        Group {
                            HStack {
                                Text("Creations")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Button(action: {
                                    createContentBool.toggle()
                                }) {
                                    Image(systemName: "square.and.pencil")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40)
                            .card()
                            .padding(.top, 40)
                            .padding([.leading, .trailing], 20)
                            
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 10) {
                                    ForEach(0..<checkContentCount(), id: \.self) { i in
                                        NavigationLink(destination: contentSegueView(contentInfo: worldInfo.contentCategory[categoryIndex].contents[i])) {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Image(uiImage: worldInfo.contentCategory[categoryIndex].contents[i].backgroundImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: (UIScreen.main.bounds.width - 60)/3, height: (UIScreen.main.bounds.width - 60)/3)
                                                    .cornerRadius(((UIScreen.main.bounds.width - 60)/3)*0.15)
                                                    .card()
                                                
                                                Text(worldInfo.contentCategory[categoryIndex].contents[i].name)
                                                    .font(.system(size: 16))
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.white)
                                                    .frame(width: (UIScreen.main.bounds.width - 60)/3)
                                                    .lineLimit(2)
                                                    .card()
                                            }
                                        }
                                        .simultaneousGesture(TapGesture().onEnded({ _ in
                                            addViewCount(id: worldInfo.contentCategory[categoryIndex].contents[i].id, collection: "contents")
                                            
                                            let group = DispatchGroup()
                                            if worldInfo.contentCategory[categoryIndex].contents[i].gotContent == false {
                                                if worldInfo.contentCategory[categoryIndex].contents[i].contentStyle == "scroll" {
                                                    group.enter()
                                                    getScrollContents(contentInfo: worldInfo.contentCategory[categoryIndex].contents[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                                        worldInfo.contentCategory[categoryIndex].contents[i].scrollContents = scrollContents
                                                        worldInfo.contentCategory[categoryIndex].contents[i].backgroundImage = backgroundImage
                                                        worldInfo.contentCategory[categoryIndex].contents[i].music = musicURL
                                                        worldInfo.contentCategory[categoryIndex].contents[i].musicData = musicData
                                                        worldInfo.contentCategory[categoryIndex].contents[i].gotContent = true
                                                        group.leave()
                                                    }
                                                } else if worldInfo.contentCategory[categoryIndex].contents[i].contentStyle == "show" {
                                                    group.enter()
                                                    getShowContents(contentInfo: worldInfo.contentCategory[categoryIndex].contents[i]) { showContents in
                                                        worldInfo.contentCategory[categoryIndex].contents[i].showContents = showContents
                                                        worldInfo.contentCategory[categoryIndex].contents[i].gotContent = true
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
                                .padding([.leading, .trailing], 20)
                                .frame(height: (UIScreen.main.bounds.width - 60)/3 + 65)
                            }
                            .padding(.top, 10)
                            
                            if categoryIndex < worldInfo.contentCategory.count,  worldInfo.contentCategory[categoryIndex].contents.count > 4 {
                                NavigationLink(destination: SeeMoreView(backgroundImage: worldInfo.contentCategory[categoryIndex].backgroundImage, contents: worldInfo.contentCategory[categoryIndex].contents)) {
                                    Text("See more")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                        .underline()
                                        .multilineTextAlignment(.center)
                                        .card()
                                        .padding(.top, 10)
                                }
                                .padding([.leading, .trailing], 20)
                            }
                        }
                        
                        Button(action: {
                            showDeleteAlert.toggle()
                        }) {
                            Text("Delete Category")
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
                        .alert(isPresented: $showDeleteAlert, content: {
                            Alert(title: Text("Caution"),
                                  message: Text("Do you want to delete this category?"),
                                  primaryButton: .default(Text("Cancel"), action: {
                                        showDeleteAlert = false
                                    }),
                                  secondaryButton: .destructive(Text("Delete"), action: {
                                        let group = DispatchGroup()
                                        let announcementRef = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements")
                                        group.enter()
                                        announcementRef.getDocuments { snapshot, _ in
                                            var batch = Firestore.firestore().batch()
                                            guard let snapshot = snapshot else { return }
                                            for (iIndex, i) in snapshot.documents.enumerated() {
                                                if worldInfo.contentCategory[categoryIndex].contents.contains(where: { $0.id == (i.data()["contentID"] as? String) }) {
                                                    batch.deleteDocument(i.reference)
                                                    if iIndex == snapshot.documents.count - 1 {
                                                        batch.commit()
                                                    }
                                                }
                                            }
                                            group.leave()
                                        }
                                        for (index, i) in worldInfo.announcements.enumerated() {
                                            if worldInfo.contentCategory[categoryIndex].contents.contains(where: { $0.id == i.content }) {
                                                worldInfo.announcements.remove(at: index)
                                            }
                                        }
                                
                                        let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory").document(worldInfo.contentCategory[categoryIndex].id)
                                        ref.delete()
                                        
                                        deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/categories/\(worldInfo.contentCategory[categoryIndex].id)")
                                        
                                        let contentReference = Firestore.firestore().collection("contents")
                                        let contentRef = contentReference
                                            .whereField("parentWorld", isEqualTo: worldInfo.id)
                                            .whereField("parentCategory", isEqualTo: worldInfo.contentCategory[categoryIndex].id)
                                        group.enter()
                                        contentRef.getDocuments { snapshot, _ in
                                            guard let snapshot = snapshot else { return }
                                            for i in snapshot.documents {
                                                var batch = Firestore.firestore().batch()
                                                switch i.data()["style"] as? String {
                                                case "scroll":
                                                    let scrollRef = contentReference.document(i.documentID).collection("scrollContent")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: scrollRef, whereField: "", equalTo: "") { scrollSnapshot in
                                                        var musicBatch = Firestore.firestore().batch()
                                                        for (jIndex, j) in scrollSnapshot.documents.enumerated() {
                                                            let musicRef = scrollRef.document(j.documentID).collection("musicList")
                                                            group.enter()
                                                            requestFirebaseSnapshot(ref: musicRef, whereField: "", equalTo: "") { musicSnapshot in
                                                                for (kIndex, k) in musicSnapshot.documents.enumerated() {
                                                                    musicBatch.deleteDocument(k.reference)
                                                                    if (kIndex + 1) % 500 == 0 || kIndex == musicSnapshot.documents.count - 1 {
                                                                        musicBatch.commit()
                                                                        musicBatch = Firestore.firestore().batch()
                                                                    }
                                                                }
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
                                                    let showRef = contentReference.document(i.documentID).collection("showContent")
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
                                                    let articleRef = contentReference.document(i.documentID).collection("articleContent")
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
                                                
                                                deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/contents/\(i.documentID)")
                                                batch.deleteDocument(Firestore.firestore().collection("contents").document(i.documentID))
                                            }
                                            group.leave()
                                        }
                                        
                                
                                        group.notify(queue: .main) {
                                            dismiss()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                worldInfo.contentCategory[categoryIndex].contents.removeAll()
                                                worldInfo.contentCategory.remove(at: categoryIndex)
                                                
                                                for (index, d) in worldInfo.contentCategory.enumerated() {
                                                    if d.index != index {
                                                        let contentRef = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory").document(d.id)
                                                        contentRef.updateData(["index": index])
                                                        d.index = index
                                                    }
                                                }
                                            }
                                        }
                                    })
                                  )
                        })
                        .padding(.top, 40)
                        .padding([.leading, .trailing], 20)
                    }
                    .padding(.bottom, bottomHeight)
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
                    ShowImageView(image: info.backgroundImage, showImageBool: $showImage, barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
                        .opacity(showImageOpacity)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .sheet(isPresented: $showImagePicker, content: {
            SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerimages)
        })
        .onChange(of: showImagePicker, perform: { value in
            if value == false && pickerimages.count > 0 {
                info.backgroundImage = pickerimages[0]
                pickerimages.removeAll()
            }
        })
        .sheet(isPresented: $showFile, content: {
            FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
        })
        .onChange(of: fileurls.count, perform: { count in
            if count > 0 {
                do {
                    let data = try Data(contentsOf: fileurls[0])
                    if let image = UIImage(data: data) {
                        info.backgroundImage = image
                        preImageURL = worldInfo.contentCategory[categoryIndex].backgroundURL
                    }
                    fileurls.removeAll()
                } catch {
                    print("catch")
                    fileurls.removeAll()
                }
            }
        })
        .ignoresSafeArea()
        .customBackButton()
        .onWillAppear {
            name.name = "EditCategoryInfoView"
            gotContent = false
        }
        .onAppear {
            info.name = worldInfo.contentCategory[categoryIndex].name
            info.description = worldInfo.contentCategory[categoryIndex].description
            info.backgroundImage = worldInfo.contentCategory[categoryIndex].backgroundImage
        }
        .fullScreenCover(isPresented: $createContentBool, content: {
            NavigationView {
                CreateContentView(worldInfo: worldInfo, categoryIndex: categoryIndex, isPresent: $createContentBool)
            }
            .accentColor(.white)
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    worldInfo.contentCategory[categoryIndex].name = info.name
                    worldInfo.contentCategory[categoryIndex].description = info.description
                    let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory").document(worldInfo.contentCategory[categoryIndex].id)
                    let group = DispatchGroup()
                    
                    ref.updateData([
                        "name": info.name,
                        "description": info.description,
                    ])
                    
                    Storage.storage().reference(forURL: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/categories/\(worldInfo.contentCategory[categoryIndex].id)").listAll() { result, _ in
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
                    DispatchQueue(label: "updateCategoryInfo").async {
                        worldInfo.contentCategory[categoryIndex].backgroundImage = info.backgroundImage
                        
                        if info.backgroundImage == worldInfo.backgroundImage {
                            ref.updateData([
                                "backgroundImage": worldInfo.backgroundURL
                            ])
                        } else {
                            let storageRef = Storage.storage().reference()
                            var data = Data()
                            if info.backgroundImage == worldInfo.backgroundImage {
                                data = info.backgroundImage.jpegData(compressionQuality: 1) ?? Data()
                            } else {
                                data = customCompressImage(image: info.backgroundImage, rate: 0.3)
                            }
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/png"
                            let path = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/categories/\(worldInfo.contentCategory[categoryIndex].id)/image_\(UUID()).png"
                            let imageRef = storageRef.child(path)
                            let uploadTask = imageRef.putData(data, metadata: metadata)
                            
                            group.enter()
                            uploadTask.observe(.success) { _ in
                                group.enter()
                                imageRef.downloadURL { url, error in
                                    if let url = url {
                                        let imageURL = url.absoluteString
                                        worldInfo.contentCategory[categoryIndex].backgroundURL = imageURL
                                        ref.updateData([
                                            "backgroundImage": imageURL
                                        ])
                                    }
                                    group.leave()
                                }
                                
                                if preImageURL != "" {
                                    let preImageRef = Storage.storage().reference(forURL: preImageURL)
                                    group.enter()
                                    preImageRef.delete { err in
                                        if let err = err {
                                            print("Could not delete image(\(err)).")
                                        } else {
                                            preImageURL = ""
                                        }
                                        group.leave()
                                    }
                                }
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                    
                    group.notify(queue: .main) {
                        let worldRef = Firestore.firestore().collection("world").document(worldInfo.id)
                        worldRef.updateData(["updatedDate" : Date()])
                        
                        dismiss()
                    }
                }) {
                    Text("Done")
                        .bold()
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
    }
    
    func checkContentCount() -> Int {
        var count = 10
        if categoryIndex < worldInfo.contentCategory.count,  worldInfo.contentCategory[categoryIndex].contents.count < 10 {
            count = worldInfo.contentCategory[categoryIndex].contents.count
        }

        return count
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent)
        }
    }
}

//struct EditCategoryInfoView_Previews: PreviewProvider {
    //static var previews: some View {
        //EditCategoryInfoView()
    //}
//}
