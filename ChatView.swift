//
//  ChatView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ChatView: View {
    
    let imageGridItems = [
        GridItem(.flexible(minimum: 40), spacing: 2, alignment: .top),
        GridItem(.flexible(minimum: 40), spacing: 2, alignment: .top)
    ]
    let parentView: String
    @State var textFieldText = ""
    @State var offsetY = CGFloat(0)
    @State var lastChatHeight = CGFloat(0)
    @State var showImageBool = false
    @State var pageNumber = 0
    @State var selectedImages = [UIImage]()
    @State var selectedChat = Chat()
    @State var thisName = "ChatView"
    @State var barHidden = false
    @State var url = ""
    @State var goWeb = false
    @State var infoBool = false
    @State var bottomY = CGFloat(0)
    @State var bottomButtonOpacity = Double(0)
    @State var refreshBottomY = true
    @State var infoOpacity = 0.0
    @State var contentOpacity = 1.0
    @State var showChats = false
    @State var chatAdded = false
    @State private var listener: ListenerRegistration?
    @State var getPrevious = false
    @State var previousAddedCount = 0
    @State var getNext = false
    @State var lastChatShown = false
    @State var chatRef = Firestore.firestore().collection("chatBoards").document().collection("chatContents").limit(to: 1)
    @State var snapshotCount = 0
    @State var createdUserName = ""
    @State var createdUserIcon = UIImage()
    var backgroundImage: UIImage
    @StateObject var selectedBoard: ChatBoard
    @Binding var chatPoint: Int
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @EnvironmentObject var chatBoardID: ChatBoardID
    @EnvironmentObject var name: Name
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var textingBool: TextingBool
    @EnvironmentObject var tabBarHidden: TabBarHidden
    
    struct OffsetYPreferenceKey: PreferenceKey {
        typealias Value = [CGFloat]
        static var defaultValue: [CGFloat] = [0]
        static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    func textFrame(text: String) -> CGRect {
        let textWidth = UIScreen.main.bounds.size.width - 120
        
        let textHeight = text.boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)], context: nil).height
                        
        return CGRect(x: 0, y: 0, width: textWidth, height: textHeight)
    }
    
    func chatFrame(text: String, name: String, images: [UIImage],  proxy: GeometryProxy) -> CGSize {
        let width = proxy.size.width - 100
        let nameHeight = name.boundingRect(with: CGSize(width: 50000, height: 50000), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)], context: nil).height + 18
        
        if images.count == 0 {
            let textWidth = text.boundingRect(with: CGSize(width: proxy.size.width - 118, height: 50000), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)], context: nil).width
            
            let textHeight = text.boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)], context: nil).height
            
            return CGSize(width: width, height: textHeight + nameHeight*2)
        } else {
            if images.count == 1 {
                let imageHeight = (images[0].size.height )*(proxy.size.width - 120)/images[0].size.width
            
                return CGSize(width: width, height: imageHeight + nameHeight*2)
            } else {
                let num = images.count % 2
                var imageHeight = CGFloat()
                if num == 0 {
                    imageHeight = (proxy.size.width - 120)*CGFloat(images.count)/4
                } else {
                    imageHeight = (proxy.size.width - 120)*CGFloat(images.count + 1)/4
                }
                
                return CGSize(width: width, height: imageHeight + nameHeight*2)
            }
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                BackgroundUIImage(image: backgroundImage, opacity: 0.2)
                
                ScrollViewReader { reader in
                    ZStack(alignment: .bottomLeading) {
                        ScrollView {
                            GeometryReader { refreshProxy in
                                Rectangle()
                                    .frame(width: 0)
                                    .onChange(of: refreshProxy.frame(in: .named("chatRefresh")).maxY) { value in
                                        if value > 0 {
                                            getPrevious = true
                                        }
                                    }
                            }
                            
                            VStack(alignment: .leading) {
                                if showChats {
                                    ForEach(0..<selectedBoard.chats.count, id: \.self) { i in
                                        if selectedBoard.chats[i].content != "" || selectedBoard.chats[i].images.count > 0 {
                                            HStack(alignment: .top) {
                                                NavigationLink(destination: OtherAccountView(accountID: selectedBoard.chats[i].userID)) {
                                                    Image(uiImage: selectedBoard.chats[i].icon)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 45, height: 45)
                                                        .clipShape(Circle())
                                                        .card()
                                                        .padding(.leading, 20)
                                                }
                                                
                                                ZStack(alignment: .topLeading) {
                                                    Rectangle()
                                                        .frame(width: chatFrame(text: selectedBoard.chats[i].content, name: selectedBoard.chats[i].name, images: selectedBoard.chats[i].images, proxy: proxy).width, height: chatFrame(text: selectedBoard.chats[i].content, name: selectedBoard.chats[i].name, images: selectedBoard.chats[i].images, proxy: proxy).height)
                                                        .foregroundColor(.black.opacity(0.5))
                                                        .cornerRadius(15)
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(selectedBoard.chats[i].name)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 16, weight: .regular))
                                                            .multilineTextAlignment(.leading)
                                                            .lineLimit(1)
                                                            .padding(.top, 5)
                                                            .padding(.bottom, 1)
                                                        
                                                        switch selectedBoard.chats[i].images.count {
                                                        case 0:
                                                            Text(selectedBoard.chats[i].content)
                                                                .font(.system(size: 16, weight: .medium))
                                                                .foregroundColor(.white)
                                                                .frame(width: UIScreen.main.bounds.size.width - 120, alignment: .leading)
                                                                .padding(.trailing, 10)
                                                        default:
                                                            switch selectedBoard.chats[i].images.count {
                                                            case 1:
                                                                Button(action: {
                                                                    pageNumber = 0
                                                                    selectedChat = selectedBoard.chats[i]
                                                                    selectedImages = selectedBoard.chats[i].images
                                                                    barHidden = true
                                                                    showImageBool.toggle()
                                                                }) {
                                                                    Image(uiImage: selectedBoard.chats[i].images[0])
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: proxy.size.width - 120, height: (selectedBoard.chats[i].images[0].size.height )*(proxy.size.width - 120)/selectedBoard.chats[i].images[0].size.width)
                                                                        .clipped()
                                                                        .cornerRadius(10)
                                                                        .padding(.trailing, 10)
                                                                }
                                                            default:
                                                                LazyVGrid(columns: imageGridItems, alignment: .leading, spacing: 2) {
                                                                    ForEach(0..<selectedBoard.chats[i].images.count, id: \.self) { j in
                                                                        Button(action: {
                                                                            pageNumber = j
                                                                            selectedImages = selectedBoard.chats[i].images
                                                                            selectedChat = selectedBoard.chats[i]
                                                                            barHidden = true
                                                                            showImageBool.toggle()
                                                                        }) {
                                                                            Image(uiImage: selectedBoard.chats[i].images[j])
                                                                                .resizable()
                                                                                .scaledToFill()
                                                                                .frame(width: (proxy.size.width - 120)/2 - 1, height: (proxy.size.width - 120)/2 - 1)
                                                                                .clipped()
                                                                                .cornerRadius(5)
                                                                        }
                                                                    }
                                                                }
                                                                .cornerRadius(10)
                                                                .padding(.trailing, 12)
                                                            }
                                                        }
                                                        
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Text(selectedBoard.chats[i].date)
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 16, weight: .regular))
                                                                .multilineTextAlignment(.trailing)
                                                                .padding(.trailing, 10)
                                                        }
                                                        .padding(.top, 1)
                                                    }
                                                    .padding(.leading, 10)
                                                }
                                                .padding(.leading, 5)
                                                .padding(.trailing, 20)
                                            }
                                        }
                                    }
                                    
                                    EmptyView()
                                        .id(selectedBoard.chats.count - 1)
                                }
                            }
                            .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize() + 10)
                            .padding(.bottom, textingBool.bottomPadding + 10)
                            
                            GeometryReader { refreshProxy in
                                Rectangle()
                                    .frame(width: 0)
                                    .onChange(of: refreshProxy.frame(in: .named("chatRefresh")).maxY) { value in
                                        if refreshBottomY {
                                            bottomY = value
                                            refreshBottomY = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                refreshBottomY = true
                                            }
                                        }
                                        if value < proxy.frame(in: .named("chatRefresh")).maxY {
                                            bottomY = value
                                            getNext = true
                                        }
                                    }
                                    .onChange(of: selectedBoard.chats.count) { _ in
                                        if lastChatShown && refreshProxy.frame(in: .named("chatRefresh")).maxY < proxy.frame(in: .named("chatRefresh")).maxY + UIScreen.main.bounds.size.height {
                                            withAnimation(.easeOut(duration: 0.15)) {
                                                reader.scrollTo(selectedBoard.chats.count - 1)
                                            }
                                        }
                                    }
                            }
                        }
                        .coordinateSpace(name: "chatRefresh")
                        .frame(width: UIScreen.main.bounds.size.width)
                        .onChange(of: showChats) { _ in
                            if chatPoint < snapshotCount - 1 {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    reader.scrollTo(selectedBoard.chats.count / 2 - 1, anchor: .center)
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    reader.scrollTo(selectedBoard.chats.count - 1)
                                }
                            }
                        }
                        .onChange(of: getPrevious, perform: { value in
                            if value == false && previousAddedCount > 0 {
                                reader.scrollTo(previousAddedCount, anchor: .center)
                            }
                        })
                        .onChange(of: textingBool.keyboardHeight) { _ in
                            withAnimation(.easeOut(duration: 0.25)) {
                                if textingBool.keyboardHeight > 0 {
                                    textingBool.bottomPadding = textingBool.keyboardHeight + 40
                                }
                            }
                        }
                        .onChange(of: chatBoardID.chatAdded, perform: { value in
                            if value == true {
                                getCurrentChats(reader: reader)
                                chatBoardID.chatAdded = false
                            }
                        })
                        .opacity(contentOpacity)
                        
                        Button(action: {
                            if bottomY > UIScreen.main.bounds.size.height * 2 || chatPoint < snapshotCount - 1 {
                                if lastChatShown == false {
                                    getCurrentChats(reader: reader)
                                } else {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        reader.scrollTo(selectedBoard.chats.count - 1)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            bottomButtonOpacity = 0.0
                                        }
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "arrow.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.black)
                                .padding(8)
                                .background(.white.opacity(0.7))
                                .cornerRadius(16)
                                .card()
                                .opacity(bottomButtonOpacity)
                                .onChange(of: bottomY, perform: { newValue in
                                    if bottomY > UIScreen.main.bounds.size.height*2 {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            bottomButtonOpacity = 1.0
                                        }
                                    } else {
                                        if chatPoint == snapshotCount - 1 {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                bottomButtonOpacity = 0.0
                                            }
                                        } else {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                bottomButtonOpacity = 1.0
                                            }
                                        }
                                    }
                                })
                                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 40)
                                .padding(.leading, 10)
                        }
                        .opacity(contentOpacity)
                        
                        if showImageBool {
                            ChatPhotoShowView(images: $selectedImages, pageNumber: $pageNumber, showImageBool: $showImageBool, preName: $thisName, chat: $selectedChat, chatBoard: selectedBoard)
                                .onAppear {
                                    UIApplication.shared.closeKeyboard()
                                    textingBool.bottomHeight = bottomInsetHeight()
                                    textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
                                }
                        }
                        
                        GradientNavigationBar()
                        
                        if infoBool {
                            ZStack {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                                    .foregroundColor(.black.opacity(0.4))
                                    .ignoresSafeArea()
                            
                                ChatInfoView(title: selectedBoard.chatName, explanation: selectedBoard.explanation, backgroundImage: backgroundImage, createdDate: selectedBoard.createdDate, postCount: $snapshotCount, userName: createdUserName, iconImage: createdUserIcon, userID: selectedBoard.userID)
                            }
                            .opacity(infoOpacity)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
        .background(.black)
        .gesture(TapGesture().onEnded({ value in
            UIApplication.shared.closeKeyboard()
            textingBool.bottomHeight = bottomInsetHeight()
            textingBool.keyboardHeight = 0.0
            textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
        }))
        .onChange(of: chatPoint, perform: { chatPoint in
            chatRef = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent")
                .order(by: "date")
            
            if selectedBoard.boardID != "" && selectedBoard.chats.count == 0 && lastChatShown == false {
                var minNum = chatPoint - 10
                var maxNum = chatPoint + 10
                
                chatRef.getDocuments { documents, err in
                    if let err = err {
                        print("Error: \(err)")
                    } else if let documents = documents {
                        if minNum < 0 {
                            minNum = 0
                        }
                        if maxNum > documents.documents.count {
                            maxNum = documents.documents.count
                        }
                        snapshotCount = documents.documents.count
                        
                        if documents.documentChanges.count > 0 {
                            var chats = [Chat]()
                            let group = DispatchGroup()
                            
                            group.enter()
                            DispatchQueue(label: "firstGetChatDocument").async {
                                for i in minNum..<maxNum {
                                    if documents.documentChanges[i].type == .added && selectedBoard.chats.contains(where: { $0.id == documents.documentChanges[i].document.documentID }) == false {
                                        group.enter()
                                        requestData2(d: documents.documentChanges[i].document, errorCount: 0) { chat in
                                            chats.append(chat)
                                            group.leave()
                                        }
                                    }
                                }
                                group.leave()
                                
                                group.notify(queue: .main) {
                                    selectedBoard.chats.append(contentsOf: chats)
                                    
                                    selectedBoard.chats.sort { a, b in
                                        a.dateValue < b.dateValue
                                    }
                                    showChats = true
                                    chatAdded = true
                                    if self.chatPoint == snapshotCount - 1 || selectedBoard.chats.count == snapshotCount {
                                        self.chatPoint = snapshotCount - 1
                                        lastChatShown = true
                                    } else {
                                        self.chatPoint += selectedBoard.chats.count / 2 - 1
                                    }
                                }
                            }
                        } else {
                            chatAdded = true
                            showChats = true
                        }
                    }
                }
            } else {
                if selectedBoard.chats.count > 0 && showChats == false {
                    chatRef.getDocuments { snapshot, _ in
                        guard let snapshot = snapshot else { return }
                        snapshotCount = snapshot.documents.count
                        showChats = true
                        chatAdded = true
                    }
                }
            }
        })
        .onChange(of: getPrevious, perform: { value in
            if value == true && chatAdded {
                let group = DispatchGroup()
                var chats = [Chat]()
                var minNum = chatPoint - selectedBoard.chats.count - 20
                var maxNum = chatPoint - selectedBoard.chats.count + 1
                
                group.enter()
                chatRef.getDocuments { snapshot, _ in
                    if let snapshot = snapshot {
                        if minNum < 0 {
                            minNum = 0
                        }
                        if maxNum > snapshot.documentChanges.count {
                            maxNum = snapshot.documentChanges.count
                        }
                        snapshotCount = snapshot.documentChanges.count
                        
                        if minNum < maxNum {
                            for i in minNum..<maxNum {
                                if snapshot.documentChanges[i].type == .added && selectedBoard.chats.contains(where: { $0.id == snapshot.documentChanges[i].document.documentID }) == false {
                                    group.enter()
                                    requestData2(d: snapshot.documentChanges[i].document, errorCount: 0) { chat in
                                        chats.append(chat)
                                        group.leave()
                                    }
                                }
                            }
                        }
                    }
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    selectedBoard.chats.insert(contentsOf: chats, at: 0)
                    selectedBoard.chats.sort { a, b in
                        return a.dateValue < b.dateValue
                    }
                    previousAddedCount = chats.count
                    chats.removeAll()
                    getPrevious = false
                }
            }
        })
        .onChange(of: getNext, perform: { value in
            if value == true && chatAdded && lastChatShown == false {
                let group = DispatchGroup()
                var chats = [Chat]()
                var minNum = chatPoint + 1
                var maxNum = chatPoint + 21
                
                group.enter()
                chatRef.getDocuments { snapshot, _ in
                    if let snapshot = snapshot {
                        if minNum < 0 {
                            minNum = 0
                        }
                        if maxNum > snapshot.documentChanges.count {
                            maxNum = snapshot.documentChanges.count
                        }
                        snapshotCount = snapshot.documentChanges.count
                        
                        if minNum < maxNum {
                            for i in minNum..<maxNum {
                                if snapshot.documentChanges[i].type == .added {
                                    group.enter()
                                    requestData2(d: snapshot.documentChanges[i].document, errorCount: 0) { chat in
                                        chats.append(chat)
                                        group.leave()
                                    }
                                }
                            }
                        }
                        group.leave()
                        
                        group.notify(queue: .main) {
                            selectedBoard.chats.append(contentsOf: chats)
                            selectedBoard.chats.sort { a, b in
                                return a.dateValue < b.dateValue
                            }
                            chatPoint += chats.count
                            if chatPoint == snapshot.documentChanges.count - 1 {
                                lastChatShown = true
                            }
                            chats.removeAll()
                            getNext = false
                        }
                    } else {
                        group.leave()
                    }
                }
            }
        })
        .onChange(of: lastChatShown, perform: { value in
            if value {
                var chatDocument = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent").document()
                if selectedBoard.chats.count > 0 {
                    chatDocument = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent").document((selectedBoard.chats.last!).id)
                }
                chatDocument.getDocument { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    var ref = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent")
                        .order(by: "date")
                    if selectedBoard.chats.count > 0 {
                        ref = ref.start(atDocument: snapshot)
                    }
                    
                    listener = ref.addSnapshotListener { snapshot, _ in
                        guard let snapshot = snapshot else { return }
                        chatRef.getDocuments { chatRefSnapshot, _ in
                            guard let chatRefSnapshot = chatRefSnapshot else { return }
                            snapshotCount = chatRefSnapshot.documents.count
                        }
                        let group = DispatchGroup()
                        var chats = [Chat]()
                        
                        for i in snapshot.documentChanges {
                            if i.type == .added && selectedBoard.chats.contains(where: { $0.id == i.document.documentID }) == false {
                                group.enter()
                                requestData2(d: i.document, errorCount: 0) { chat in
                                    chats.append(chat)
                                    group.leave()
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            selectedBoard.chats.append(contentsOf: chats)
                            selectedBoard.chats.sort { a, b in
                                return a.dateValue < b.dateValue
                            }
                            chatPoint = snapshotCount - 1
                        }
                    }
                }
            }
        })
        .pauseMusic(music: music, playAudio: playAudio)
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "ChatView"
                if infoBool {
                    textingBool.bool = false
                } else {
                    textingBool.bool = true
                }
                chatBoardID.id = selectedBoard.boardID
            }
            
            getUserNameAndIcon(id: selectedBoard.userID) { name, icon in
                createdUserName = name
                createdUserIcon = icon
            }
            
            if selectedBoard.chats.count > 0 {
                for (index, i) in selectedBoard.chats.enumerated() {
                    if accountInfo.blockedUsers.contains(where: { $0 == i.userID }) {
                        selectedBoard.chats[index].content = ""
                        selectedBoard.chats[index].images.removeAll()
                    } else {
                        if i.content == "" && i.images.count == 0 {
                            let ref = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent").document(i.id)
                            ref.getDocument { snapshot, _ in
                                guard let d = snapshot else { return }
                                let urls = d.data()!["resizeImages"] as! [String]
                                var images = [(image: UIImage, index: Int)]()
                                let storage = Storage.storage()
                                let group = DispatchGroup()
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                                let date = d.data()!["date"] as! Timestamp
                                let dateStr = formatter.string(from: date.dateValue())
                                let text = d.data()!["content"] as! String
                                
                                var userName = ""
                                var iconImage = UIImage(named: "black") ?? UIImage()
                                let userID = d.data()!["userID"] as! String
                                
                                group.enter()
                                getUserNameAndIcon(id: d.data()!["userID"] as! String) { name, icon in
                                    userName = name
                                    iconImage = icon
                                    group.leave()
                                }
                                
                                group.notify(queue: .main) {
                                    var element = Chat(id: d.documentID, name: userName, icon: iconImage, userID: userID, content: text, images: [], date: dateStr, dateValue: date.dateValue(), height: textFrame(text: text).height)
                                    
                                    if urls.count > 0 {
                                        for (index, u) in urls.enumerated() {
                                            if u != "" {
                                                group.enter()
                                                storage.reference(forURL: u).getData(maxSize: 1024 * 1024 * 10) { data, err in
                                                    if let err = err {
                                                        print("Error: \(err)")
                                                        group.leave()
                                                    } else if let data = data {
                                                        images.append((UIImage(data: data) ?? UIImage(), index))
                                                        if images.count == urls.count {
                                                            images.sort { a, b in
                                                                a.index < b.index
                                                            }
                                                            
                                                            let imageArray = images.map( { $0.image } )
                                                            element.images = imageArray
                                                        }
                                                        group.leave()
                                                    }
                                                }
                                            }
                                        }
                                        
                                        group.notify(queue: .main) {
                                            selectedBoard.chats[index] = element
                                        }
                                    } else {
                                        selectedBoard.chats[index] = element
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onWillDisappear {
            chatBoardID.id = ""
            textingBool.bool = false
            textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10

            listener?.remove()
            
            let noSaveViews = ["ContentShowView", "ContentScrollView"]
            if noSaveViews.contains(parentView) == false {
                let ref = Firestore.firestore().collection("users").document(accountInfo.id).collection("readChats").document(accountInfo.readChats.filter({ $0.chatID == selectedBoard.boardID }).first!.readID)
                let chatRef = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent")
                chatRef.getDocuments { snapshot, err in
                    guard let snapshot = snapshot else { return }
                    var documentCount = snapshot.documents.count
                    if documentCount > 0 {
                        documentCount -= 1
                    }
                    ref.updateData(["readPoint": documentCount])
                    for i in 0..<accountInfo.readChats.count {
                        if accountInfo.readChats[i].chatID == selectedBoard.boardID {
                            accountInfo.readChats[i].readPoint = documentCount
                        }
                    }
                }
            }
        }
        .onChange(of: showImageBool, perform: { _ in
            if showImageBool == false {
                barHidden = false
            }
        })
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if barHidden == false {
                    Button(action: {
                        infoButtonFunc()
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                            .card()
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
                    
                    ReportButton(accountID: accountInfo.id, contentType: "chatBoard", contentID: selectedBoard.boardID, contentName: selectedBoard.chatName)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if barHidden == false {
                    if infoBool == false {
                        CustomBackButtonView()
                    } else {
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
        }
        .navigationBarTitle(Text(selectedBoard.chatName), displayMode: .inline)
        .fullScreenCover(isPresented: $goWeb) {
            WebView(addBool: false, showWebView: ShowWebView(url: url))
                .onAppear {
                    UIApplication.shared.closeKeyboard()
                    textingBool.bottomHeight = bottomInsetHeight()
                    textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
                }
        }
    }

    func infoButtonFunc() {
        if infoBool == false {
            infoBool.toggle()
            textingBool.bool = false
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
                self.textingBool.bool = true
            }
        }
    }
    
    func requestData2(d: QueryDocumentSnapshot, errorCount: Int, _ completion: @escaping(_ chat: Chat) -> Void) {
        let urls = d.data()["resizeImages"] as! [String]
        var images = [(image: UIImage, index: Int)]()
        let storage = Storage.storage()
        var errorBool = false
        let group = DispatchGroup()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = d.data()["date"] as! Timestamp
        let dateStr = formatter.string(from: date.dateValue())
        let text = d.data()["content"] as! String
        
        var userName = ""
        var iconImage = UIImage(named: "black") ?? UIImage()
        let userID = d.data()["userID"] as! String
        
        if accountInfo.blockedUsers.contains(where: { $0 == userID }) == false {
            group.enter()
            getUserNameAndIcon(id: d.data()["userID"] as! String) { name, icon in
                userName = name
                iconImage = icon
                group.leave()
            }
            
            group.notify(queue: .main) {
                var element = Chat(id: d.documentID, name: userName, icon: iconImage, userID: userID, content: text, images: [], date: dateStr, dateValue: date.dateValue(), height: textFrame(text: text).height)
                
                if urls.count > 0 {
                    for (index, u) in urls.enumerated() {
                        if u != "" {
                            group.enter()
                            storage.reference(forURL: u).getData(maxSize: 1024 * 1024 * 10) { data, err in
                                if let err = err {
                                    print("Error: \(err)")
                                    errorBool = true
                                    group.leave()
                                } else if let data = data {
                                    images.append((UIImage(data: data) ?? UIImage(), index))
                                    if images.count == urls.count {
                                        images.sort { a, b in
                                            a.index < b.index
                                        }
                                        
                                        let imageArray = images.map( { $0.image } )
                                        element.images = imageArray
                                        completion(element)
                                    }
                                    group.leave()
                                }
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        if errorBool && errorCount < 20 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let errCount = errorCount + 1
                                requestData2(d: d, errorCount: errCount) { chat in
                                    completion(chat)
                                }
                            }
                        }
                    }
                } else {
                    completion(element)
                }
            }
        } else {
            completion(Chat(id: d.documentID, userID: userID, date: dateStr, dateValue: date.dateValue()))
        }
    }
    
    func getCurrentChats(reader: ScrollViewProxy) {
        let ref = Firestore.firestore().collection("chatBoard").document(selectedBoard.boardID).collection("chatContent")
            .order(by: "date", descending: true)
            .limit(to: 10)
        var chats = [Chat]()
        let group = DispatchGroup()
        
        ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            for i in snapshot.documents {
                group.enter()
                requestData2(d: i, errorCount: 0) { chat in
                    chats.append(chat)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                chats.sort { a, b in
                    return a.dateValue < b.dateValue
                }
                selectedBoard.chats.removeAll()
                selectedBoard.chats.append(contentsOf: chats)
                lastChatShown = true
                chatRef.getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    snapshotCount = snapshot.documents.count
                    chatPoint = snapshotCount - 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            reader.scrollTo(selectedBoard.chats.count - 1)
                        }
                    }
                }
            }
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
    //static var previews: some View {
        //ChatView()
    //}
//}

struct ChatInfoView: View {
    
    var title: String
    var explanation: String
    @State var backgroundImage = UIImage()
    @State var dateStr = ""
    var createdDate: Date
    @Binding var postCount: Int
    let userName: String
    let iconImage: UIImage
    let userID: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    
                    Title(title: title, size: 32)
                    
                    Spacer()
                }
                
                Text(explanation)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: UIScreen.main.bounds.size.width - 40)
                    .card()
                    .padding(.top, 40)
                    .padding([.leading, .trailing], 20)
                
                // credit condition here.
                
                Text("User Created This Chat")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .card()
                    .padding(.top, 56)
                    .padding([.leading, .trailing], 20)
                
                HStack(spacing: 16) {
                    NavigationLink(destination: OtherAccountView(accountID: userID)) {
                        Image(uiImage: iconImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 60)/4, height: (UIScreen.main.bounds.size.width - 60)/4)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(userName)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))
                            
                            //HStack {
                            //Image(systemName: "p.circle")
                            //.resizable()
                            //.scaledToFit()
                            //.frame(width: 16, height: 16)
                            //.foregroundColor(.white)
                            
                            //Text("\(80)")
                            //.foregroundColor(.white)
                            //.font(.system(size: 16, weight: .regular))
                            //.multilineTextAlignment(.center)
                            //.lineLimit(1)
                            //}
                        }
                    }
                }
                .card()
                .padding(.top, 24)
                .padding([.leading, .trailing], 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(postCount)")
                          .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Posts")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                    }
                    
                    HStack {
                        Text("Created Date")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                        
                        Text(dateStr)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .card()
                .padding(.top, 64)
                .padding(.leading, 20)
            }
            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight())
        }
        .onWillAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            dateStr = formatter.string(from: createdDate)
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
