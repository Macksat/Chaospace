//
//  ContentListView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/27.
//

import SwiftUI
import FirebaseFirestore

struct ChatListView: View {
    
    @State var chatCreated = false
    @State var goCreateChat = false
    @State var showContents = false
    @State var chatPoint = -1
    @State var ref = Firestore.firestore().collection("chatBoard").limit(to: 20)
    @State var getNext = false
    @State var bottomY = CGFloat(0)
    @StateObject var chatBoard = ChatBoard()
    @StateObject var worldInfo: WorldInfo
    @EnvironmentObject var name: Name
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                NavigationLink(destination: ChatView(parentView: "ChatListView", backgroundImage: worldInfo.backgroundImage, selectedBoard: chatBoard, chatPoint: $chatPoint), isActive: $chatCreated) {
                    EmptyView()
                }
                .onChange(of: chatCreated) { newValue in
                    if newValue {
                        let boardInfo = worldInfo.chatBoards.first!
                        chatBoard.chatName = boardInfo.chatName
                        chatBoard.explanation = boardInfo.explanation
                        chatBoard.conditionBool = boardInfo.conditionBool
                        chatBoard.condition = boardInfo.condition
                        chatBoard.boardID = boardInfo.boardID
                        chatBoard.parentWorld = boardInfo.parentWorld
                        chatBoard.createdDate = boardInfo.createdDate
                        chatBoard.updatedDate = boardInfo.updatedDate
                        chatBoard.userID = boardInfo.userID
                        chatBoard.chats = boardInfo.chats
                        chatBoard.createdUserIcon = boardInfo.createdUserIcon
                        
                        getReadPointOfChat(boardID: chatBoard.boardID)
                    }
                }
                
                BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
                
                ScrollViewReader { reader in
                    ScrollView {
                        VStack {
                            Title(title: NSLocalizedString("Forum", comment: ""), size: 36)
                                .padding(.bottom, 20)
                            
                            AdMobBannerView()
                                .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                                .padding(.bottom, 40)
                            
                            if showContents {
                                ForEach(0..<worldInfo.chatBoards.count, id: \.self) { i in
                                    NavigationLink(destination: ChatView(parentView: "ChatListView", backgroundImage: worldInfo.backgroundImage, selectedBoard: worldInfo.chatBoards[i], chatPoint: $chatPoint)) {
                                        ZStack(alignment: .topLeading) {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                                .background(.ultraThinMaterial)
                                                .cornerRadius(20)
                                            
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(worldInfo.chatBoards[i].chatName)
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 20, weight: .semibold))
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(1)
                                                        .card()
                                                    
                                                    Spacer()
                                                    
                                                    HStack {
                                                        Account(image: worldInfo.chatBoards[i].createdUserIcon, name: worldInfo.chatBoards[i].createdUser, imageSize: ((UIScreen.main.bounds.size.width - 40) - 20)/10, textSize: 16)
                                                            .card()
                                                        
                                                        if worldInfo.chatBoards[i].conditionBool {
                                                            Spacer()
                                                            
                                                            Image(systemName: "p.circle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 16, height: 16)
                                                                .foregroundColor(.white)
                                                                .card()
                                                            
                                                            Text("\(worldInfo.chatBoards[i].condition)")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 16, weight: .medium))
                                                                .card()
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(width: UIScreen.main.bounds.size.width - 60, alignment: .leading)
                                            .padding(10)
                                        }
                                    }
                                    .padding(.top, 10)
                                    .simultaneousGesture(TapGesture().onEnded({ _ in
                                        getReadPointOfChat(boardID: worldInfo.chatBoards[i].boardID)
                                    }))
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width)
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                        
                        GeometryReader { refreshProxy in
                            Rectangle()
                                .frame(width: 0)
                                .onChange(of: refreshProxy.frame(in: .named("refresh")).maxY) { value in
                                    bottomY = value
                                    if value < proxy.frame(in: .named("refresh")).maxY && getNext == false {
                                        getNext = true
                                    }
                                }
                        }
                    }
                    .coordinateSpace(name: "refresh")
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .onWillAppear {
            ref = Firestore.firestore().collection("chatBoard")
                .whereField("worldID", isEqualTo: worldInfo.id)
                .order(by: "createdDate", descending: true)
                .limit(to: 20)
            DispatchQueue.main.async {
                name.name = "ChatListView"
            }
            chatPoint = -1
            getDocuments()
            if worldInfo.chatBoards.count > 0 {
                for i in worldInfo.chatBoards {
                    if accountInfo.blockedUsers.contains(where: { $0 == i.userID }) {
                        worldInfo.chatBoards.removeAll(where: { $0.userID == i.userID })
                    }
                }
            }
            if worldInfo.chatBoards.count > 0 {
                showContents = true
            }
        }
        .onChange(of: getNext, perform: { value in
            if value {
                ref.getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    guard let lastDocument = snapshot.documents.last else { return }
                    
                    ref = Firestore.firestore().collection("chatBoard")
                        .whereField("worldID", isEqualTo: worldInfo.id)
                        .order(by: "createdDate", descending: true)
                        .start(afterDocument: lastDocument)
                        .limit(to: 20)
                    getDocuments()
                }
            }
        })
        .pauseMusic(music: music, playAudio: playAudio)
        .ignoresSafeArea()
        .customBackButton()
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
                
                Button(action: {
                    goCreateChat.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .fullScreenCover(isPresented: $goCreateChat) {
            NavigationView {
                CreateChatBoardView(worldInfo: worldInfo, chatCreated: $chatCreated)
            }
            .accentColor(.white)
        }
    }
    
    func getReadPointOfChat(boardID: String) {
        let ref = Firestore.firestore().collection("users").document(accountInfo.id).collection("readChats")
        let estimateDocument = ref.whereField("chatID", isEqualTo: boardID)
        var readChat = ("", "", 0)
        let group = DispatchGroup()
        group.enter()
        estimateDocument.getDocuments(completion: { snapshot, err in
            if let snapshot = snapshot {
                if let document = snapshot.documents.first {
                    if accountInfo.readChats.filter({ $0.chatID == document.data()["chatID"] as! String }).count == 0 {
                        readChat = (document.documentID, document.data()["chatID"] as! String, document.data()["readPoint"] as! Int)
                        accountInfo.readChats.append(readChat)
                    } else {
                        let readChatElement = accountInfo.readChats.filter({ $0.chatID == document.data()["chatID"] as! String }).first!
                        readChat = readChatElement
                    }
                } else {
                    let document = ref.addDocument(data: [
                        "chatID": boardID,
                        "readPoint": 0
                    ])
                    readChat = (document.documentID, boardID, 0)
                    accountInfo.readChats.append(readChat)
                }
            }
            group.leave()
        })
        
        group.notify(queue: .main) {
            chatPoint = readChat.2
        }
    }
    
    func getDocuments() {
        var chatBoards = [ChatBoard]()
        let group = DispatchGroup()
        ref.getDocuments() { documents, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                guard let documents = documents else { return }
                group.enter()
                DispatchQueue(label: "getChatboard").async {
                    for document in documents.documents {
                        if worldInfo.chatBoards.filter({ $0.boardID == document.documentID }).count == 0 {
                            let createdDate = document.data()["createdDate"] as! Timestamp
                            let updatedDate = document.data()["updatedDate"] as! Timestamp
                            let chatBoard = ChatBoard()
                            chatBoard.chatName = document.data()["name"] as! String
                            chatBoard.explanation = document.data()["explanation"] as! String
                            chatBoard.boardID = document.documentID
                            chatBoard.condition = document.data()["point"] as! Int
                            chatBoard.conditionBool = document.data()["conditionBool"] as! Bool
                            chatBoard.userID = document.data()["userID"] as! String
                            chatBoard.parentWorld = document.data()["worldID"] as! String
                            chatBoard.createdDate = createdDate.dateValue()
                            chatBoard.updatedDate = updatedDate.dateValue()
                            
                            if accountInfo.blockedUsers.contains(where: { $0 == chatBoard.userID }) == false {
                                group.enter()
                                getUserNameAndIcon(id: chatBoard.userID) { userName, iconImage in
                                    chatBoard.createdUser = userName
                                    chatBoard.createdUserIcon = iconImage
                                    group.leave()
                                }
                                
                                group.notify(queue: .main) {
                                    chatBoards.append(chatBoard)
                                }
                            }
                        }
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        worldInfo.chatBoards.append(contentsOf: chatBoards)
                        worldInfo.chatBoards.sort(by: { a, b in
                            a.updatedDate > b.updatedDate
                        })
                        getNext = false
                        
                        withAnimation(.linear(duration: 0.3)) {
                            showContents = true
                        }
                    }
                }
            }
        }
    }
}

//struct ChatListView_Previews: PreviewProvider {
    //static var previews: some View {
        //ChatListView()
    //}
//}
