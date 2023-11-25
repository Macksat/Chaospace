//
//  CreateChatBoardView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/02.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

struct CreateChatBoardView: View {
    
    @State var createButtonBool = false
    @State var showImagePicker = false
    @State var nameHeight = CGFloat(52)
    @State var bottomPadding = CGFloat(0)
    @State var explanationHeight = CGFloat(80)
    @State var thisName = "CreateChatBoardView"
    @State var boardName = ""
    @State var explanation = ""
    @State var chatBoard = ChatBoard()
    @StateObject var worldInfo: WorldInfo
    @Binding var chatCreated: Bool
    @EnvironmentObject var name: Name
    @EnvironmentObject var accountInfo: AccountInfo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Chat Name")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            .padding([.leading, .trailing], 20)
                        
                        ContentTextingView(text: $boardName, height: $nameHeight, viewBottomHeight: $bottomPadding, originalHeight: 52, fontSize: 28, fontWeight: .bold, textAlignment: .left, placeholder: NSLocalizedString("Chat Name", comment: ""))
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: nameHeight)
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
                        
                        ContentTextingView(text: $explanation, height: $explanationHeight, viewBottomHeight: $bottomPadding, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Description of Chat", comment: ""))
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: explanationHeight)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 20)
                    }
                    .padding(.bottom, bottomPadding + UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                }
                .ignoresSafeArea()
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .gesture(TapGesture().onEnded({ _ in
            UIApplication.shared.closeKeyboard()
        }))
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreateChatBoardView"
            }
            
            chatBoard.chatName = ""
            chatBoard.explanation = ""
            chatBoard.conditionBool = false
            chatBoard.condition = 0
            chatBoard.boardID = ""
            boardName = ""
            explanation = ""
        }
        .onChange(of: boardName, perform: { _ in
            chatBoard.chatName = boardName
            createButtonCondition()
        })
        .onChange(of: explanation, perform: { _ in
            chatBoard.explanation = explanation
            createButtonCondition()
        })
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
                if createButtonBool == true {
                    Button(action: {
                        let ref = Firestore.firestore().collection("chatBoard")
                        chatBoard.createdDate = Date()
                        chatBoard.updatedDate = Date()
                        let document = ref.addDocument(data: [
                            "conditionBool": chatBoard.conditionBool,
                            "userID": accountInfo.id,
                            "explanation": chatBoard.explanation,
                            "name": chatBoard.chatName,
                            "point": chatBoard.condition,
                            "worldID": worldInfo.id,
                            "createdDate": chatBoard.createdDate,
                            "updatedDate": chatBoard.updatedDate
                        ])
                        
                        let worldRef = Firestore.firestore().collection("world").document(worldInfo.id)
                        worldRef.updateData(["updatedDate" : Date()])
                        
                        chatBoard.boardID = document.documentID
                        chatBoard.createdUser = accountInfo.name
                        chatBoard.userID = accountInfo.id
                        chatBoard.createdUserIcon = accountInfo.iconImage
                        worldInfo.chatBoards.insert(chatBoard, at: 0)
                        
                        dismiss()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            chatCreated = true
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
    
    func createButtonCondition() {
        if chatBoard.chatName != "" && chatBoard.explanation != "" {
            createButtonBool = true
        } else {
            createButtonBool = false
        }
    }
}

//struct CreateChatBoardView_Previews: PreviewProvider {
    //static var previews: some View {
        //CreateChatBoardView()
    //}
//}
