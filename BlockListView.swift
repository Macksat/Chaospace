//
//  BlockListView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/11/26.
//

import SwiftUI
import FirebaseFirestore

struct BlockListView: View {
    
    @Binding var backgroundImage: UIImage
    @State var blockedUsers: [(id: String, name: String, icon: UIImage)] = []
    @EnvironmentObject var accountInfo: AccountInfo
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                BackgroundUIImage(image: backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack {
                        Title(title: NSLocalizedString("Users You Blocked", comment: ""), size: 32)
                            .padding(.bottom, 20)
                        
                        ForEach(0..<blockedUsers.count, id: \.self) { i in
                            HStack {
                                Account(image: blockedUsers[i].icon, name: blockedUsers[i].name, imageSize: 45, textSize: 16)
                                
                                Spacer()
                                
                                Button(action: {
                                    let ref = Firestore.firestore().collection("users").document(accountInfo.id)
                                    ref.updateData(["blockedUsers": FieldValue.arrayRemove([blockedUsers[i].id])])
                                    accountInfo.blockedUsers.removeAll(where: { $0 == blockedUsers[i].id })
                                    blockedUsers.removeAll(where: { $0.id == blockedUsers[i].id })
                                }) {
                                    Text("Unblock")
                                        .font(.system(size: 16, weight: .medium))
                                        .padding([.top, .bottom], 3)
                                        .padding([.leading, .trailing], 5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 2)
                                        }
                                        .foregroundColor(.white)
                                        .card()
                                }
                            }
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10)
                }
                .ignoresSafeArea()
                
                GradientNavigationBar()
            }
        }
        .background(Color.chaosBlack)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .customBackButton()
        .onWillAppear {
            let group = DispatchGroup()
            var array = [(String, String, UIImage)]()
            
            group.enter()
            DispatchQueue(label: "getBlockedUser").async {
                for i in accountInfo.blockedUsers {
                    let ref = Firestore.firestore().collection("users").document(i)
                    group.enter()
                    getUserNameAndIcon(id: i) { name, icon in
                        array.append((i, name, icon))
                        group.leave()
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                blockedUsers.append(contentsOf: array)
            }
        }
    }
}

//struct BlockListView_Previews: PreviewProvider {
    //static var previews: some View {
       // BlockListView()
    //}
//}
