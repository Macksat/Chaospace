//
//  AccountListView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/10/29.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct AccountListView: View {
    
    var backgroundImage: UIImage
    var aspectFit: Bool = false
    var documentRef: DocumentReference
    var fieldName: String
    @State var bottomY = CGFloat(0)
    @State var getNext = false
    @State var users = [String]()
    @State var showContent = false
    @State var accounts = [AccountInfo]()
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                ContentBackgroundImage(image: backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.2, aspectFit: aspectFit)
                
                ScrollViewReader { reader in
                    ScrollView {
                        if showContent {
                            VStack {
                                AdMobBannerView()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                                    .padding([.leading, .trailing], 20)
                                    .padding(.bottom, 40)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width - 40)/2 - 20), alignment: .top)], alignment: .center) {
                                    ForEach(0..<accounts.count, id: \.self) { i in
                                        NavigationLink(destination: OtherAccountView(accountID: accounts[i].id)) {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Image(uiImage: accounts[i].iconImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                                    .clipShape(Circle())
                                                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                                                
                                                Text(accounts[i].name)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.white)
                                                    .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .center)
                                                    .lineLimit(1)
                                                    .card()
                                            }
                                        }
                                    }
                                }
                                .padding([.leading, .trailing], 20)
                            }
                            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
                            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            
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
                    }
                    .coordinateSpace(name: "refresh")
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "AccountListView"
            }
            
            documentRef.getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                users = snapshot.data()?[fieldName] as? [String] ?? []
                
                var loadCount = 10
                if users.count < loadCount {
                    loadCount = users.count
                    if loadCount == 0 {
                        showContent = true
                    }
                }
                let group = DispatchGroup()
                
                group.enter()
                DispatchQueue(label: "loadAccounts").async {
                    for i in 0..<loadCount {
                        let userRef = Firestore.firestore().collection("users").document(users[i])
                        group.enter()
                        userRef.getDocument { userSnapshot, _ in
                            guard let userSnapshot = userSnapshot else { return }
                            if accounts.contains(where: { $0.id == userSnapshot.documentID }) == false {
                                let account = AccountInfo()
                                account.id = userSnapshot.documentID
                                group.enter()
                                getUserNameAndIcon(id: userSnapshot.documentID) { name, icon in
                                    account.name = name
                                    account.iconImage = icon
                                    accounts.append(account)
                                    group.leave()
                                }
                            }
                            group.leave()
                        }
                    }
                    group.leave()
                    
                    group.notify(queue:.main) {
                        showContent = true
                    }
                }
            }
        }
        .onChange(of: getNext, perform: { value in
            if value && users.count > accounts.count {
                var loadCount = 10
                if users.count - accounts.count < loadCount {
                    loadCount = users.count - accounts.count
                }
                let group = DispatchGroup()
                var accountArray = [AccountInfo]()
                
                group.enter()
                DispatchQueue(label: "addAccounts").async {
                    for i in accounts.count..<accounts.count + loadCount {
                        let userRef = Firestore.firestore().collection("users").document(users[i])
                        group.enter()
                        userRef.getDocument { userSnapshot, _ in
                            guard let userSnapshot = userSnapshot else { return }
                            if accounts.contains(where: { $0.id == userSnapshot.documentID }) == false {
                                let account = AccountInfo()
                                account.id = userSnapshot.documentID
                                group.enter()
                                getUserNameAndIcon(id: userSnapshot.documentID) { name, icon in
                                    account.name = name
                                    account.iconImage = icon
                                    accountArray.append(account)
                                    group.leave()
                                }
                            }
                            group.leave()
                        }
                    }
                    group.leave()
                    
                    group.notify(queue:.main) {
                        accounts.append(contentsOf: accountArray)
                        getNext = false
                    }
                }
            }
        })
        .ignoresSafeArea()
        .customBackButton()
        .navigationBarTitle(Text(""), displayMode: .inline)
    }
}
