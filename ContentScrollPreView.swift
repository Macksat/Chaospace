//
//  ContentScrollPreView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/07/10.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ContentScrollPreView: View {
    
    @State var opacity = Double(0)
    @State var infoOpacity = Double(0)
    @State var muteBool = false
    @State var thisName = "ContentScrollPreView"
    @State var showImageBool = false
    @State var favBool = false
    @State var videoChangedBool = false
    @State var imageNum = 0
    @State var showImageName = UIImage()
    @State var checkWeb = false
    @State var showImageOpacity = 0.0
    @State var showProgress = false
    @State var progressOpacity = 0.0
    @State var progressCount = Double(0)
    @State var barHidden = false
    @State var uploadFailed = false
    @State var uploadCompleted = false
    @State var failedContentName = ""
    @ObservedObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @EnvironmentObject var name: Name
    @StateObject var contentInfo: ContentInfo
    @EnvironmentObject var music: Music
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var accountInfo: AccountInfo
    @Binding var isPresent: Bool
    
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
                }
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 50)
            }
            .opacity(opacity)
            
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
        .fullScreenCover(isPresented: $checkWeb) {
            WebView(viewName: "ContentScrollPreView", addBool: false, showWebView: ShowWebView(url: webViewVar.nowURL))
        }
        .onWillAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                music.musicURL = contentInfo.music
                music.musicLoop = contentInfo.loopPlay
                music.musicMuteBool = false
                music.pauseBool = false
                music.finished = false
                music.listIndex = -1
                playAudio.playAudio(url: contentInfo.music, muteBool: music.musicMuteBool, loop: contentInfo.loopPlay)
            }
            
            name.name = "ContentScrollPreView"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.opacity = 1
                }
            }
        }
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    music.musicURL = contentInfo.music
                    music.musicLoop = contentInfo.loopPlay
                    
                    if music.listIndex != -1 {
                        music.musicMuteBool = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            music.musicMuteBool = false
                            music.pauseBool = false
                        }
                    } else {
                        music.pauseBool.toggle()
                        music.musicMuteBool = false
                    }
                    
                    music.listPressed = false
                    music.listIndex = -1
                }) {
                    if music.pauseBool == true || music.listIndex != -1 {
                        Image(systemName: "speaker.slash")
                            .foregroundColor(.white)
                            .card()
                    } else {
                        Image(systemName: "speaker")
                            .foregroundColor(.white)
                            .card()
                    }
                }
                
                Button(action: {
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
        .edgesIgnoringSafeArea(.all)
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
            "bgm": "",
            "bgmLoop": contentInfo.loopPlay,
            "parentWorld": worldInfo.id,
            "parentCategory": worldInfo.contentCategory[categoryIndex ?? 0].id,
            "backgroundImage": "",
            "backgroundAspectFit": contentInfo.backgroundAspectFit,
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
            "bgm": "",
            "bgmLoop": contentInfo.loopPlay,
            "backgroundAspectFit": contentInfo.backgroundAspectFit,
            "searchMap": searchMap
        ])
        
        group.enter()
        ref.collection("scrollContent").getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            for i in snapshot.documents {
                ref.collection("scrollContent").document(i.documentID).delete()
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
        
        var uploadContentCount = contentInfo.scrollContents.count
        if contentInfo.backgroundImage != UIImage(named: "black") ?? UIImage() {
            uploadContentCount += 1
        }
        if contentInfo.music != URL(fileURLWithPath: "") {
            uploadContentCount += 1
        }
        
        let group = DispatchGroup()
        
        if contentInfo.backgroundImage != UIImage(named: "black") ?? UIImage() {
            let imageData = compressImageData(image: contentInfo.backgroundImage)
            var backgroundProgress = Double(0)
            group.enter()
            uploadToStorageObserve(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/backgroundImage\(UUID()).png", data: imageData, type: "image/png", document: ref, contentName: "backgroundImage") { progress, status in
                progressCount += (progress - backgroundProgress) / Double(uploadContentCount)
                backgroundProgress = progress
                if status == "failed" {
                    uploadFailed = true
                    failedContentName = "Background image"
                    group.leave()
                } else if status == "succeeded" {
                    group.leave()
                }
            }
        } else {
            ref.updateData(["backgroundImage": ""])
        }

        if contentInfo.music != URL(fileURLWithPath: "") {
            var bgmData = Data()
            group.enter()
            do {
                bgmData = try Data(contentsOf: contentInfo.music)
                group.leave()
            } catch {
                print("Failed to get music data.")
                group.leave()
            }
            
            var bgmProgress = Double(0)
            group.enter()
            uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/bgm\(UUID()).mp3", data: bgmData, type: "muslc/mp3", document: ref, contentName: "bgm") { progress, status in
                progressCount += (progress - bgmProgress) / Double(uploadContentCount)
                bgmProgress = progress
                if status == "failed" {
                    uploadFailed = true
                    failedContentName = "BGM"
                    group.leave()
                } else if status == "succeeded" {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                if contentInfo.scrollContents.count == 0 && uploadFailed == false {
                    isPresent = false
                }
            }
        }
        
        let documentRef = Firestore.firestore().collection("contents").document(documentID).collection("scrollContent")
        group.enter()
        DispatchQueue(label: "uploadScrollContent").async {
            for (index, i) in contentInfo.scrollContents.enumerated() {
                switch i.type {
                case "title":
                    documentRef.addDocument(data: [
                        "content1" : i.content,
                        "type": i.type,
                        "index": index
                    ])
                    progressCount += 100 / Double(uploadContentCount)
                case "text":
                    documentRef.addDocument(data: [
                        "content1" : i.content,
                        "type": i.type,
                        "index": index
                    ])
                    progressCount += 100 / Double(uploadContentCount)
                case "image":
                    var imgData = Data()
                    do {
                        imgData = try Data(contentsOf: i.imageURL)
                    } catch {
                        print("Failed to convert imageURL to Data.")
                    }
                    let d = documentRef.addDocument(data: [
                        "content1" : "",
                        "type": i.type,
                        "index": index
                    ])
                    var imageProgress = Double(0)
                    group.enter()
                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/scrollContent/image\(index)_\(UUID()).png", data: imgData, type: "image/png", document: documentRef.document(d.documentID), contentName: "content1") { progress, status in
                        progressCount += (progress - imageProgress) / Double(uploadContentCount)
                        imageProgress = progress
                        if status == "failed" {
                            uploadFailed = true
                            failedContentIndexName(index: index)
                            group.leave()
                        } else if status == "succeeded" {
                            group.leave()
                        }
                    }
                case "music":
                    let contentDocument = documentRef.addDocument(data: [
                        "type": i.type,
                        "index": index
                    ])
                    let musicDocumentRef = Firestore.firestore().collection("contents").document(documentID).collection("scrollContent").document(contentDocument.documentID).collection("musicList")
                    
                    var musicUploadedCount = 0
                    var preMusicProgress = Double(0)
                    for (musicIndex, j) in i.music.enumerated() {
                        let d = musicDocumentRef.addDocument(data: [
                            "music": "",
                            "musicName": i.musicName[musicIndex],
                            "index": musicIndex
                        ])
                        
                        do {
                            let data = try Data(contentsOf: j)
                            group.enter()
                            uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/scrollContent/music\(index)/\(UUID()).mp3", data: data, type: "music/mp3", document: musicDocumentRef.document(d.documentID), contentName: "music") { progress, status in
                                let musicProgress = (progress + 100.0 * Double(musicUploadedCount)) / Double(i.music.count)
                                progressCount += musicProgress - preMusicProgress
                                preMusicProgress = musicProgress
                                if status == "failed" {
                                    uploadFailed = true
                                    failedContentIndexName(index: index)
                                    group.leave()
                                } else if status == "succeeded" {
                                    musicUploadedCount += 1
                                    group.leave()
                                }
                            }
                        } catch {
                            print("Failed to get music data.")
                        }
                    }
                case "video":
                    let d = documentRef.addDocument(data: [
                        "content1" : "",
                        "type": i.type,
                        "index": index
                    ])
                    do {
                        let data = try Data(contentsOf: i.videoURL)
                        var videoProgress = Double(0)
                        group.enter()
                        uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/scrollContent/video\(index)_\(UUID()).mp4", data: data, type: "video/mp4", document: documentRef.document(d.documentID), contentName: "content1") { progress, status in
                            progressCount += (progress - videoProgress) / Double(uploadContentCount)
                            videoProgress = progress
                            if status == "failed" {
                                uploadFailed = true
                                failedContentIndexName(index: index)
                                group.leave()
                            } else if status == "succeeded" {
                                group.leave()
                            }
                        }
                    } catch {
                        print("Failed to get video data.")
                    }
                case "link":
                    let imgData = i.image.jpegData(compressionQuality: 0.1) ?? Data()
                    let d = documentRef.addDocument(data: [
                        "content1" : i.url,
                        "content2": i.content,
                        "content3": "",
                        "type": i.type,
                        "index": index
                    ])
                    var linkProgress = Double(0)
                    group.enter()
                    uploadToStorage(path: "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfoID)/contents/\(documentID)/scrollContent/link\(index)_\(UUID()).png", data: imgData, type: "image/png", document: documentRef.document(d.documentID), contentName: "content3") { progress, status in
                        progressCount += (progress - linkProgress) / Double(uploadContentCount)
                        linkProgress = progress
                        if status == "failed" {
                            uploadFailed = true
                            failedContentIndexName(index: index)
                            group.leave()
                        } else if status == "succeeded" {
                            group.leave()
                        }
                    }
                default:
                    break
                }
            }
            group.leave()
            
            group.notify(queue: .main) {
                if worldInfo.id != "" && categoryIndex != nil && worldInfo.contentCategory[categoryIndex ?? 0].contents.contains(where: { $0.id == contentInfo.id }) == false {
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
    
    func failedContentIndexName(index: Int) {
        if index == 0 {
            failedContentName = "1st content"
        } else if index == 1 {
            failedContentName = "2nd content"
        } else if index == 2 {
            failedContentName = "3rd content"
        } else {
            failedContentName = "\(index + 1)" + NSLocalizedString("th content", comment: "")
        }
    }
}

//struct ContentScrollPreView_Previews: PreviewProvider {
    //static var previews: some View {
        //ContentScrollPreView()
    //}
//}

struct ContentScrollSubView: View {
    
    @Binding var videoChangedBool: Bool
    @Binding var showImageName: UIImage
    @State var nowPlaying = 0
    @Binding var checkWeb: Bool
    @Binding var showImageBool: Bool
    @StateObject var contentInfo: ContentInfo
    var content: ScrollContent
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    var body: some View {
        switch content.type {
        case "image":
            ZStack(alignment: .topTrailing) {
                Image(uiImage: content.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageFrame(image: content.image).width, height: imageFrame(image: content.image).height)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                    .gesture(TapGesture().onEnded({ _ in
                        showImageName = content.image
                        withAnimation(.easeOut(duration: 0.3)) {
                            showImageBool.toggle()
                        }
                    }))
            }
            
        case "text":
            Text(content.content)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.leading)
                .card()
        case "title":
            HStack {
                Spacer()
                
                Text(content.content)
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                    .padding(.top, 40)
                
                Spacer()
            }
        case "music":
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 45 * CGFloat(content.music.count))
                        .foregroundColor(.black.opacity(0.7))
                        .cornerRadius(15)
                    
                    HStack(alignment: .top, spacing: 0) {
                        if content.music.count > 0 {
                            Button(action: {
                                if music.listIndex != contentInfo.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                                    if nowPlaying < content.data.count {
                                        playAudio.playAudioFromData(data: content.data[nowPlaying], muteBool: false, loop: false)
                                    } else {
                                        playAudio.playAudio(url: content.music[nowPlaying], muteBool: false, loop: false)
                                    }
                                    music.musicMuteBool = true
                                    nowPlaying = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        music.musicMuteBool = false
                                        music.pauseBool = false
                                    }
                                } else {
                                    if music.musicURL != content.music[nowPlaying] {
                                        if nowPlaying < content.data.count {
                                            playAudio.playAudioFromData(data: content.data[nowPlaying], muteBool: false, loop: false)
                                        } else {
                                            playAudio.playAudio(url: content.music[nowPlaying], muteBool: false, loop: false)
                                        }
                                    }
                                    music.musicMuteBool = false
                                    music.pauseBool.toggle()
                                }
                                
                                music.musicURL = content.music[nowPlaying]
                                music.musicLoop = false
                                music.finished = false
                                music.listIndex = contentInfo.scrollContents.firstIndex(where: { $0 == content } ) ?? 0
                            }) {
                                if music.pauseBool || music.listIndex != contentInfo.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                                    Image(systemName:"play.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.white)
                                        .padding([.leading, .trailing], 8)
                                        .padding(.top, 8)
                                } else {
                                    Image(systemName:"pause.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.white)
                                        .padding([.leading, .trailing], 8)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        
                        List {
                            ForEach(0..<content.music.count, id: \.self) { j in
                                HStack {
                                    Text(content.musicName[j])
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                        .lineLimit(1)
                                        .gesture(TapGesture().onEnded({ _ in
                                            if j < content.data.count {
                                                playAudio.playAudioFromData(data: content.data[j], muteBool: false, loop: false)
                                            } else {
                                                playAudio.playAudio(url: content.music[j], muteBool: false, loop: false)
                                            }
                                            music.musicURL = content.music[j]
                                            music.musicLoop = false
                                            music.musicMuteBool = false
                                            music.pauseBool = false
                                            music.finished = false
                                            self.nowPlaying = j
                                            music.listPressed = true
                                            music.listIndex = contentInfo.scrollContents.firstIndex(where: { $0 == content } ) ?? 0
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                music.listPressed = false
                                            }
                                        }))
                                }
                                .listRowBackground(Color.clear)
                                .padding([.leading, .trailing], 0)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 88, height: 45 * CGFloat(content.music.count))
                        .listStyle(.plain)
                        .background(.clear)
                    }
                    .padding([.leading, .trailing], 0)
                }
                .cornerRadius(15)
            }
            .onChange(of: music.finished) { newValue in
                if newValue == true && music.listIndex == contentInfo.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                    if self.nowPlaying < content.music.count - 1 {
                        if self.nowPlaying + 1 < content.data.count  {
                            playAudio.playAudioFromData(data: content.data[self.nowPlaying + 1], muteBool: false, loop: false)
                        } else {
                            playAudio.playAudio(url: content.music[self.nowPlaying + 1], muteBool: false, loop: false)
                        }
                        music.listPressed = true
                        music.musicURL = content.music[self.nowPlaying + 1]
                        music.musicMuteBool = false
                        music.pauseBool = false
                        music.finished = false
                        music.musicLoop = false
                        self.nowPlaying += 1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            music.listPressed = false
                        }
                    } else {
                        self.nowPlaying = 0
                        music.pauseBool = true
                        music.musicMuteBool = true
                        music.musicURL = URL(fileURLWithPath: "")
                    }
                }
            }
        case "video":
            PlayVideoView(url: content.videoURL, didChange: $videoChangedBool)
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)*9/16)
                .cornerRadius(20)
                .shadow(color: .black, radius: 15, x: 0, y: 0)
        case "link":
            Button(action: {
                webViewVar.nowURL = content.url
                checkWeb = true
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.7))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
                        .cornerRadius(15)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(content.content)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(content.url)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))
                                .lineLimit(1)
                        }
                        .padding([.top, .bottom], 8)
                        
                        Spacer()
                        
                        Image(uiImage: content.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 40)/5 - 16, height: (UIScreen.main.bounds.size.width - 40)/5 - 16)
                            .cornerRadius(10)
                    }
                    .padding([.leading, .trailing], 8)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
        default:
            EmptyView()
        }
    }
    
    func imageFrame(image: UIImage) -> CGRect {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: image.size.height*(UIScreen.main.bounds.size.width - 40)/image.size.width)
        
        return frame
    }
}
