//
//  CreateWorldView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/31.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct CreateWorldView: View {
    
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var name: Name
    @State var explanationHeight = CGFloat(80)
    @State var nameHeight = CGFloat(42)
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var viewName = "CreateWorldView"
    @State var showImagePicker = false
    @State var showFile = false
    @State var showCategory = false
    @State var menuOpacity = 0.0
    @State var chevronRotation = 0.0
    @State var tagText = ""
    @State var bgmText = ""
    @State var choosePhotoSource = false
    @State var showImage = false
    @State var chooseMenuPadding = CGFloat(-20)
    @State var chooseMenuOpacity = Double(0)
    @State var showImageOpacity = 0.0
    @State var fileurls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerimages = [UIImage]()
    @State var barHidden = false
    @State var uploadFailed = false
    @State var uploadCompleted = false
    @StateObject var info: WorldInfo
    @StateObject var loadObserver = LoadObserver()
    @Binding var worldCreated: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                BackgroundUIImage(image: info.backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
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
                                    
                                    if info.bgm == "" {
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
                    ShowImageView(image: info.backgroundImage, showImageBool: $showImage, barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
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
        .alert(isPresented: $uploadFailed, content: {
            Alert(title: Text("Error"),
                  message: Text("Failed to upload BGM because the size is more than 10 MB."),
                  dismissButton: .default(Text("OK"), action: {
                        uploadFailed = false
                        dismiss()
                
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            worldCreated = true
                        }
                    })
                  )
        })
        .gesture(TapGesture().onEnded({ _ in
            categoryMenu(buttonBool: false)
        }))
        .onChange(of: info.bgm, perform: { value in
            if value != "" {
                bgmText = info.bgmName
                bgmText.removeLast(4)
            }
        })
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
            if viewName == "WorldViewPhoto" {
                FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
            } else {
                FileView(multipleSelection: false, fileType: "music", urls: $fileurls)
            }
        })
        .onChange(of: showFile, perform: { value in
            if value == false && fileurls.count > 0 {
                if viewName == "CreateWorldView" {
                    info.bgm = fileurls[0].absoluteString
                    info.bgmURL = fileurls[0]
                    info.bgmName = fileurls[0].lastPathComponent
                } else {
                    do {
                        let data = try Data(contentsOf: fileurls[0])
                        if let image = UIImage(data: data) {
                            info.backgroundImage = image
                        }
                    } catch {
                        print("Failed to get background image from url.")
                    }
                    viewName = "CreateWorldView"
                }
                fileurls.removeAll()
            } else if value == false && fileurls.count == 0 {
                viewName = "CreateWorldView"
            }
        })
        .ignoresSafeArea()
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreateWorldView"
            }
        }
        .onChange(of: uploadCompleted) { newValue in
            if newValue {
                dismiss()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    worldCreated = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
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
                        if info.category.count == 0 {
                            info.category.append("Others")
                        }
                        
                        loadObserver.isLoading = true
                        withAnimation(.linear(duration: 0.3)) {
                            loadObserver.opacity = 1.0
                        }
                        
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
                        
                        let group = DispatchGroup()
                        let ref = Firestore.firestore().collection("world")
                        let worldDocument = ref.addDocument(data: [
                            "backgroundImage": "",
                            "createdUser": accountInfo.id,
                            "description": info.explanation,
                            "name": info.name,
                            "categories": info.category,
                            "tags": info.tags,
                            "bgm": "",
                            "bgmName": bgmText,
                            "createdDate": Date(),
                            "updatedDate": Date(),
                            "followers": [String](),
                            "followerTokens": [String](),
                            "searchMap": searchMap
                        ])
                        
                        let categoryRef = Firestore.firestore().collection("world").document(worldDocument.documentID).collection("contentCategory")
                        categoryRef.addDocument(data: [
                            "name": NSLocalizedString("New Category", comment: ""),
                            "description": "",
                            "backgroundImage": "",
                            "index": 0
                        ])
                        
                        let storage = Storage.storage()
                        let reference = storage.reference()
                        
                        let bgmPath = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldDocument.documentID)/bgm_\(UUID()).mp3"
                        var bgmData = Data()
                        let bgmMetadata = StorageMetadata()
                        bgmMetadata.contentType = "music/mp3"
                        let bgmRef = reference.child(bgmPath)
                        
                        if info.backgroundImage != UIImage(named: "black") ?? UIImage() {
                            let imagePath = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldDocument.documentID)/image_\(UUID()).png"
                            let imageData = customCompressImage(image: info.backgroundImage, rate: 0.3)
                            let imageRef = reference.child(imagePath)
                            let imageMetadata = StorageMetadata()
                            imageMetadata.contentType = "image/png"
                            let imageUploadTask = imageRef.putData(imageData, metadata: imageMetadata)
                            group.enter()
                            imageUploadTask.observe(.success) { _ in
                                group.enter()
                                imageRef.downloadURL { url, error in
                                    if let url = url {
                                        let imageStr = url.absoluteString
                                        worldDocument.updateData(["backgroundImage": imageStr])
                                    }
                                    group.leave()
                                }
                                group.leave()
                            }
                        }
                        
                        group.enter()
                        DispatchQueue(label: "uploadTasks").async {
                            group.enter()
                            DispatchQueue(label: "uploadWorldBGM").async {
                                if info.bgmURL != URL(fileURLWithPath: "") {
                                    let semaphore = DispatchSemaphore(value: 0)
                                    do {
                                        bgmData = try Data(contentsOf: info.bgmURL)
                                        semaphore.signal()
                                    } catch {
                                        print("failed to get data.")
                                        semaphore.signal()
                                    }
                                    semaphore.wait()
                                    
                                    let bgmUploadTask = bgmRef.putData(bgmData, metadata: bgmMetadata)
                                    worldDocument.updateData(["bgm": bgmPath])
                                    
                                    group.enter()
                                    bgmUploadTask.observe(.failure) { _ in
                                        uploadFailed = true
                                        info.bgm = ""
                                        info.bgmURL = URL(fileURLWithPath: "")
                                        info.bgmName = ""
                                        group.leave()
                                    }
                                    
                                    bgmUploadTask.observe(.success) { _ in
                                        group.leave()
                                    }
                                }
                                group.leave()
                            }
                            group.leave()
                        }
                        
                        group.notify(queue: .main) {
                            info.id = worldDocument.documentID
                            info.createdUser = accountInfo.id
                            info.createdUserName = accountInfo.name
                            info.createdUserIcon = accountInfo.iconImage
                            
                            withAnimation(.linear(duration: 0.3)) {
                                loadObserver.opacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                loadObserver.isLoading = false
                            }
                            
                            if uploadFailed == false {
                                uploadCompleted = true
                            }
                        }
                    }) {
                        Text("Create")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    }
                } else {
                    Text("Create")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                }
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

//struct CreateWorldView_Previews: PreviewProvider {
    //static var previews: some View {
        //CreateWorldView()
    //}
//}
