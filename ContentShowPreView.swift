//
//  ContentShowPreView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/07/10.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ContentShowPreView: View {
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
    @State var isTitleShown = false
    @State var isImageShown = false
    @State var isTextShown = false
    @State var videoUpdate = false
    @State var thisName = "ContentShowPreView"
    @State var showImageName = UIImage()
    @State var showImageOpacity = 0.0
    @State var showProgress = false
    @State var progressOpacity = 0.0
    @State var progressCount = Double(0)
    @State var barHidden = false
    @State var uploadFailed = false
    @State var uploadCompleted = false
    @State var failedContentName = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var name: Name
    @ObservedObject var contentInfo: ContentInfo
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @ObservedObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @Binding var isPresent: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
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
            
            if showProgress {
                UploadProgressView(progressCount: $progressCount)
                    .opacity(progressOpacity)
            }
            
            GradientNavigationBar()
            
            if showImageBool {
                ShowImageView(image: showImageName, showImageBool: $showImageBool, barHidden: $barHidden, preName: $thisName, opacity: $showImageOpacity)
                    .opacity(showImageOpacity)
            }
        }
        .background(.black)
        .alert(isPresented: $uploadFailed, content: {
            Alert(title: Text("Error"),
                  message: Text(failedContentName + NSLocalizedString(": Failed to upload because the size is too large.", comment: "")),
                  dismissButton: .default(Text("OK"), action: {
                        withAnimation(.linear(duration: 0.1)) {
                            progressOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            progressCount = 0.0
                            showProgress = false
                            uploadFailed = false
                        }
                    })
                  )
        })
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    music.pauseBool.toggle()
                    if music.musicMuteBool == true {
                        music.musicMuteBool = false
                    }
                }) {
                    if music.musicMuteBool == false && music.pauseBool == false {
                        Image(systemName: "speaker")
                            .foregroundColor(.white)
                            .card()
                    } else {
                        Image(systemName: "speaker.slash")
                            .foregroundColor(.white)
                            .card()
                    }
                }
                
                Button(action: {
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
                    if worldInfo.id != "" && contentInfo.id == "" {
                        uploadData()
                    } else {
                        updateData()
                    }
                }) {
                    if worldInfo.id != "" {
                        Text("Upload")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    } else {
                        Text("Update")
                            .foregroundColor(.white)
                            .bold()
                            .card()
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
                    if contentInfo.showContents[contentCount].music != contentInfo.showContents[contentCount+1].music {
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
                    
                    videoUpdate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        videoUpdate = false
                    }
                }
            }
            
            if value.translation.width > 70 {
                dismiss()
            }
         }))
        .onWillAppear {
            name.name = "ContentShowPreView"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.appearBool = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                music.musicMuteBool = false
                music.pauseBool = false
                changeMusic(index: contentCount)
            }
        }
        .onChange(of: uploadCompleted) { newValue in
            if newValue {
                playAudio.player?.stop()
                isPresent = false
            }
        }
    }
    
    func uploadData() {
        let ref = Firestore.firestore().collection("contents")
        var queryWords = [String]()
        queryWords.append(contentsOf: searchMapArray(text: contentInfo.name))
        queryWords.append(contentsOf: searchMapArray(text: accountInfo.name))
        queryWords.append(contentsOf: searchMapArray(text: accountInfo.accountID))
        var searchMap: [String: Bool] = [:]
        for i in queryWords {
            searchMap[i] = true
        }
        let document = ref.addDocument(data: [
            "name": contentInfo.name,
            "description": contentInfo.explanation,
            "style": contentInfo.contentStyle,
            "createdDate": Date(),
            "updatedDate": Date(),
            "parentWorld": worldInfo.id,
            "parentCategory": worldInfo.contentCategory[categoryIndex ?? 0].id,
            "backgroundImage": "",
            "backgroundAspectFit": contentInfo.showContents[0].backgroundAspectFit,
            "createdUser": accountInfo.id,
            "likes": [String](),
            "viewCount": 0,
            "searchMap": searchMap
        ])
        
        contentInfo.createdDate = Date()
        contentInfo.updatedDate = Date()
        contentInfo.parentWorld = worldInfo.id
        contentInfo.parentCategory = worldInfo.contentCategory[categoryIndex ?? 0].id
        contentInfo.createdUserID = accountInfo.id
        contentInfo.createdUserName = accountInfo.name
        contentInfo.id = document.documentID
        contentInfo.backgroundImage = contentInfo.showContents[0].backgroundImage
        contentInfo.backgroundAspectFit = contentInfo.showContents[0].backgroundAspectFit
        contentInfo.gotContent = true
        
        uploadContents(documentID: document.documentID, ref: ref.document(document.documentID), worldInfoID: worldInfo.id)
    }
    
    func updateData() {
        let group = DispatchGroup()
        var queryWords = [String]()
        queryWords.append(contentsOf: searchMapArray(text: contentInfo.name))
        queryWords.append(contentsOf: searchMapArray(text: accountInfo.name))
        queryWords.append(contentsOf: searchMapArray(text: accountInfo.accountID))
        var searchMap: [String: Bool] = [:]
        for i in queryWords {
            searchMap[i] = true
        }
        let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
        ref.updateData([
            "name": contentInfo.name,
            "description": contentInfo.explanation,
            "updatedDate": Date(),
            "backgroundAspectFit": contentInfo.showContents[0].backgroundAspectFit,
            "searchMap": searchMap
        ])
        
        group.enter()
        ref.collection("showContent").getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            for i in snapshot.documents {
                ref.collection("showContent").document(i.documentID).delete()
            }
            group.leave()
        }
        
        deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(contentInfo.parentWorld)/contents/\(contentInfo.id)")
        
        group.notify(queue: .main) {
            uploadContents(documentID: contentInfo.id, ref: ref, worldInfoID: contentInfo.parentWorld)
        }
    }
    
    func uploadContents(documentID: String, ref: DocumentReference, worldInfoID: String) {
        showProgress = true
        withAnimation(.easeOut(duration: 0.3)) {
            progressOpacity = 1.0
        }
        var uploadContentCount = contentInfo.showContents.count
        if contentInfo.showContents[0].backgroundImage != UIImage(named: "black") ?? UIImage() {
            uploadContentCount += 1
        }
        
        let group = DispatchGroup()
        
        if contentInfo.showContents[0].backgroundImage != UIImage(named: "black") ?? UIImage() {
            let imageData = compressImageData(image: contentInfo.showContents[0].backgroundImage)
            var backgroundProgress = Double(0)
            group.enter()
            uploadToStorageObserve(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/backgroundImage\(UUID()).png", data: imageData, type: "image/png", document: ref, contentName: "backgroundImage") { progress, status in
                progressCount += (progress - backgroundProgress) / Double(uploadContentCount)
                backgroundProgress = progress
                if status == "failed" {
                    uploadFailed = true
                    failedContentName = NSLocalizedString("Background image", comment: "")
                    group.leave()
                } else if status == "succeeded" {
                    group.leave()
                }
            }
        } else {
            ref.updateData(["backgroundImage": ""])
        }
        
        let documentRef = Firestore.firestore().collection("contents").document(documentID).collection("showContent")
        group.enter()
        DispatchQueue(label: "uploadShowContent").async {
            for (index, i) in contentInfo.showContents.enumerated() {
                var pageContentCount = 0
                if i.backgroundImage != UIImage() {
                    pageContentCount += 1
                }
                if i.music != URL(fileURLWithPath: "") {
                    pageContentCount += 1
                }
                if i.video != URL(fileURLWithPath: "") || i.image != UIImage() {
                    pageContentCount += 1
                }
                
                let showDocument = documentRef.addDocument(data: [
                    "index": index,
                    "title": i.title,
                    "text": i.text,
                    "bgm": "",
                    "bgmLoop": i.loopPlay,
                    "backgroundImage": "",
                    "backgroundAspectFit": i.backgroundAspectFit,
                    "image": "",
                    "video": ""
                ])
                
                if i.backgroundImage != UIImage(named: "black") ?? UIImage() {
                    if index > 0 && i.backgroundImage == contentInfo.showContents[index - 1].backgroundImage {
                        showDocument.updateData(["backgroundImage": "same"])
                        progressCount += 100 / Double(uploadContentCount * pageContentCount)
                    } else {
                        let imgData = compressImageData(image: i.backgroundImage)
                        var preImageProgress = Double(0)
                        group.enter()
                        uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/showContent/backgroundImage\(index)_\(UUID()).png", data: imgData, type: "image/png", document: documentRef.document(showDocument.documentID), contentName: "backgroundImage") { progress, status in
                            progressCount += (progress - preImageProgress) / Double(uploadContentCount * pageContentCount)
                            preImageProgress = progress
                            if status == "failed" {
                                uploadFailed = true
                                failedContentIndexName(index: index)
                                group.leave()
                            } else if status == "succeeded" {
                                group.leave()
                            }
                        }
                    }
                }
                
                if i.image != UIImage() {
                    var imgData = Data()
                    do {
                        imgData = try Data(contentsOf: i.imageURL)
                    } catch {
                        print("Failed to convert imageURL to data.")
                    }
                    var preImageProgress = Double(0)
                    group.enter()
                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/showContent/image\(index)_\(UUID()).png", data: imgData, type: "image/png", document: documentRef.document(showDocument.documentID), contentName: "image") { progress, status in
                        progressCount += (progress - preImageProgress) / Double(uploadContentCount * pageContentCount)
                        preImageProgress = progress
                        if status == "failed" {
                            uploadFailed = true
                            failedContentIndexName(index: index)
                            group.leave()
                        } else if status == "succeeded" {
                            group.leave()
                        }
                    }
                }
                
                if i.music != URL(fileURLWithPath: "") {
                    if index > 0 && i.music == contentInfo.showContents[index - 1].music {
                        showDocument.updateData(["bgm": "same"])
                        progressCount += 100 / Double(uploadContentCount * pageContentCount)
                    } else {
                        var bgmData = Data()
                        group.enter()
                        do {
                            bgmData = try Data(contentsOf: i.music)
                            group.leave()
                        } catch {
                            print("Failed to get music data.")
                            group.leave()
                        }
                        var preMusicProgress = Double(0)
                        group.enter()
                        uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/showContent/bgm\(index)_\(UUID()).mp3", data: bgmData, type: "muslc/mp3", document: documentRef.document(showDocument.documentID), contentName: "bgm") { progress, status in
                            progressCount += (progress - preMusicProgress) / Double(uploadContentCount * pageContentCount)
                            preMusicProgress = progress
                            if status == "failed" {
                                uploadFailed = true
                                failedContentIndexName(index: index)
                                group.leave()
                            } else if status == "succeeded" {
                                group.leave()
                            }
                        }
                    }
                }
                
                if i.video != URL(fileURLWithPath: "") {
                    var data = Data()
                    group.enter()
                    do {
                        data = try Data(contentsOf: i.video)
                        group.leave()
                    } catch {
                        print("Failed to get video data.")
                        group.leave()
                    }
                    var preVideoProgress = Double(0)
                    group.enter()
                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/showContent/video\(index)_\(UUID()).mp4", data: data, type: "video/mp4", document: documentRef.document(showDocument.documentID), contentName: "video") { progress, status in
                        progressCount += (progress - preVideoProgress) / Double(uploadContentCount * pageContentCount)
                        preVideoProgress = progress
                        if status == "failed" {
                            uploadFailed = true
                            failedContentIndexName(index: index)
                            group.leave()
                        } else if status == "succeeded" {
                            group.leave()
                        }
                    }
                }
            }
            group.leave()
            
            group.notify(queue: .main) {
                if worldInfo.id != "" && categoryIndex != nil && worldInfo.contentCategory[categoryIndex ?? 0].contents.contains(where: { $0.id == contentInfo.id })  == false {
                    if contentInfo.showContents.count > 0 {
                        contentInfo.showContents.append(ShowContent(index: contentInfo.showContents.count, backgroundImage: contentInfo.showContents[contentInfo.showContents.count - 1].backgroundImage, backgroundAspectFit: contentInfo.showContents[contentInfo.showContents.count - 1].backgroundAspectFit, music: contentInfo.showContents[contentInfo.showContents.count - 1].music, musicData: Data(), loopPlay: contentInfo.showContents[contentInfo.showContents.count - 1].loopPlay))
                    }
                    worldInfo.contentCategory[categoryIndex ?? 0].contents.append(contentInfo)
                }
                
                if uploadFailed == false {
                    uploadCompleted = true
                    let nowCount = progressCount
                    if nowCount < 100 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if progressCount == nowCount {
                                isPresent = false
                            }
                        }
                    }
                }
            }
        }
        
        let worldRef = Firestore.firestore().collection("world").document(worldInfoID)
        worldRef.updateData(["updatedDate" : Date()])
    }
    
    func changeMusic(index: Int) {
        music.musicURL = contentInfo.showContents[index].music
        music.musicLoop = contentInfo.showContents[index].loopPlay
        music.finished = false
        playAudio.playAudio(url: contentInfo.showContents[index].music, muteBool: music.musicMuteBool, loop: music.musicLoop)
        if music.pauseBool == false {
            music.listPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                music.listPressed = false
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
            if contentInfo.showContents[contentCount].music != contentInfo.showContents[contentCount-1].music {
                changeMusic(index: contentCount - 1)
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
            
            videoUpdate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                videoUpdate = false
            }
        }
        
        if contentCount == 0 {
            if titlePadding != UIScreen.main.bounds.size.height/4 {
                titlePadding = UIScreen.main.bounds.size.height/4 - 20
            }
            titleSize = 36
        }
    }
    
    func failedContentIndexName(index: Int) {
        if index == 0 {
            failedContentName = NSLocalizedString("1st Page", comment: "")
        } else if index == 1 {
            failedContentName = NSLocalizedString("2nd Page", comment: "")
        } else if index == 2 {
            failedContentName = NSLocalizedString("3rd Page", comment: "")
        } else {
            failedContentName = "\(index + 1)" + NSLocalizedString("th Page", comment: "")
        }
    }
}

//struct ContentShowPreView_Previews: PreviewProvider {
    //static var previews: some View {
        //ContentShowPreView()
    //}
//}
