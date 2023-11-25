//
//  ChatPhotoShowView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/04/16.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ChatPhotoShowView: View {
    
    @Binding var images: [UIImage]
    @Binding var pageNumber: Int
    @EnvironmentObject var name: Name
    @EnvironmentObject var textingBool: TextingBool
    @Binding var showImageBool: Bool
    @Binding var preName: String
    @Binding var chat: Chat
    @StateObject var chatBoard: ChatBoard
    @State var barHidden = true
    @State var opacity = 0.0
    @State var resetZooming = false
    
    var body: some View {
        ZStack {
            TabView(selection: $pageNumber) {
                ForEach(Array(images.enumerated()), id: \.offset) { i, content in
                    ZoomableScrollView {
                        Image(uiImage: content)
                            .resizable()
                            .scaledToFit()
                            .tag(i)
                    }
                    .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .transition(.slide)
            .opacity(opacity)
            .onChange(of: pageNumber) { _ in
                resetZooming = true
            }
            
            GradientNavigationBar()
        }
        .onWillAppear {
            DispatchQueue.main.async {
                textingBool.bool = false
                name.name = "ChatPhotoShowView"
            }
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
            
            let ref = Firestore.firestore().collection("chatBoard").document(chatBoard.boardID).collection("chatContent").document(chat.id)
            ref.getDocument { document, err in
                if let err = err {
                    print("Error: \(err)")
                } else if let document = document {
                    let imageURLs = document.data()!["images"] as! [String]
                    let storage = Storage.storage()
                    for (index, u) in imageURLs.enumerated() {
                        if u != "" {
                            var included = false
                            for i in chat.chatImages {
                                if i.id == u {
                                    included = true
                                }
                            }
                            
                            if included {
                                if let elementIndex = chat.chatImages.firstIndex(where: { $0.id == u } ) {
                                    images[index] = chat.chatImages[elementIndex].image
                                }
                            } else {
                                storage.reference(forURL: u).getData(maxSize: 1024 * 1024 * 50) { data, err in
                                    if let err = err {
                                        print("Error: \(err)")
                                    } else if let data = data {
                                        if images.count == imageURLs.count {
                                            let image = UIImage(data: data) ?? UIImage()
                                            images[index] = image
                                            if let  chatIndex = chatBoard.chats.firstIndex(where: { $0.id == chat.id }) {
                                                chatBoard.chats[chatIndex].chatImages.append(ChatImage(id: u, image: image))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onWillDisappear {
            DispatchQueue.main.async {
                name.name = preName
            }
            
            images.removeAll()
        }
        .gesture(DragGesture()
                .onEnded({ value in
                    if value.translation.height > 50 || value.translation.height < -50 {
                        backFunc()
                    }
                }))
        .gesture(TapGesture().onEnded({ _ in
            barHidden.toggle()
            if name.name == "" {
                name.name = "ContentShowView"
            } else {
                name.name = ""
            }
        }))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    backFunc()
                }) {
                    Image(systemName: "chevron.left")
                        .card()
                }
            }
        }
        .background(.black.opacity(opacity))
        .navigationBarTitle(Text(""), displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
    }
    
    func backFunc() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showImageBool = false
            textingBool.bool = true
        }
    }
}

//struct ChatPhotoShowView_Previews: PreviewProvider {
    //static var previews: some View {
        //ChatPhotoShowView()
    //}
//}
