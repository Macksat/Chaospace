//
//  ContentHomeView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/12/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import StoreKit

struct ContentHomeView: View {
    
    @State var collectionLimitCount = 10
    @State var contentInfoArray = [ContentInfo]()
    @State var selection = 0
    @State var nowRef = Firestore.firestore().collection("contents").limit(to: 10)
    @State var searchText = ""
    @State var isCancelSearching = false
    @Binding var isSearch: Bool
    @State var gotSearchResult = false
    @State var searchBarOpacity = Double(0)
    @State var searchBarOffset = CGFloat(40)
    @State var resultViewOpacity = Double(0)
    @State var searchResults = [ContentInfo]()
    @State var gotContent = false
    @StateObject var loadObserver = LoadObserver()
    @StateObject var authObserver = FirebaseAuthStateObserver()
    @ObservedObject var accountInfo: AccountInfo
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                if contentInfoArray.count > 0 {
                    TabView(selection: $selection) {
                        ForEach(0..<contentInfoArray.count, id: \.self) { i in
                            switch contentInfoArray[i].id {
                            case "":
                                HomeViewAd()
                            default:
                                ZStack(alignment: .top) {
                                    Image(uiImage: contentInfoArray[i].backgroundImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: proxy.size.width, height: proxy.size.height)
                                        .clipped()
                                    
                                    Rectangle()
                                        .foregroundColor(.black.opacity(0.2))
                                        .frame(width: proxy.size.width, height: proxy.size.height)
                                    
                                    VStack {
                                        NavigationLink(destination: OtherAccountView(accountID: contentInfoArray[i].createdUserID)) {
                                            HStack {
                                                Account(image: contentInfoArray[i].createdUserIcon, name: contentInfoArray[i].createdUserName, imageSize: 45, textSize: 16)
                                                    .card()
                                                    .padding(.leading, 20)
                                                
                                                Spacer()
                                            }
                                            
                                        }
                                        .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 20)
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text(contentInfoArray[i].name)
                                                .bold()
                                                .font(.system(size: 36))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .card()
                                                .padding([.leading, .trailing], 20)
                                                .padding(.top, 20)
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text(contentInfoArray[i].explanation)
                                                .shadow(color: .black, radius: 15, x: 0, y: 0)
                                                .font(.system(size: 16, weight: .medium))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .lineLimit(4)
                                                .card()
                                                .padding([.leading, .trailing], 20)
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 20)
                                        
                                        NavigationLink(destination: contentSegueView(contentInfo: contentInfoArray[i])) {
                                            Text("Look")
                                                .foregroundColor(.white)
                                                .font(.system(size: 28, weight: .medium))
                                                .padding([.leading, .trailing], 20)
                                                .padding([.top, .bottom], 5)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.white, lineWidth: 3)
                                                )
                                                .card()
                                                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 56)
                                        }
                                        .simultaneousGesture(TapGesture().onEnded({ _ in
                                            let group = DispatchGroup()
                                            if contentInfoArray[i].gotContent == false {
                                                if contentInfoArray[i].contentStyle == "scroll" {
                                                    group.enter()
                                                    getScrollContents(contentInfo: contentInfoArray[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                                        contentInfoArray[i].scrollContents = scrollContents
                                                        contentInfoArray[i].backgroundImage = backgroundImage
                                                        contentInfoArray[i].music = musicURL
                                                        contentInfoArray[i].musicData = musicData
                                                        contentInfoArray[i].gotContent = true
                                                        group.leave()
                                                    }
                                                } else if contentInfoArray[i].contentStyle == "show" {
                                                    group.enter()
                                                    getShowContents(contentInfo: contentInfoArray[i]) { showContents in
                                                        contentInfoArray[i].showContents = showContents
                                                        contentInfoArray[i].gotContent = true
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
                            }
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .rotationEffect(.degrees(-90)) // Rotate content
                    }
                    .frame(
                        width: proxy.size.height, // Height & width swap
                        height: proxy.size.width
                    )
                    .rotationEffect(.degrees(90), anchor: .topLeading) // Rotate TabView
                    .offset(x: proxy.size.width) // Offset back into screens bounds
                    .tabViewStyle(
                        PageTabViewStyle(indexDisplayMode: .never)
                    )
                }
            }
            
            if isSearch {
                ContentSearchView(resultArray: $searchResults, searchText: $searchText, gotSearchResult: $gotSearchResult)
                    .opacity(resultViewOpacity)
            }
            
            if loadObserver.isLoading {
                LoadingView()
                    .opacity(loadObserver.opacity)
            }
            
            GradientNavigationBar()
        }
        .background(Color.chaosBlack)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isSearch == false {
                    Button(action: {
                        isSearch.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                searchBarOpacity = 1
                                searchBarOffset = 0
                                resultViewOpacity = 1
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .card()
                    }
                } else {
                    SearchBar(placeholder: NSLocalizedString("Search Creations", comment: ""), text: $searchText, isCancel: $isCancelSearching)
                        .frame(width: UIScreen.main.bounds.size.width - 40)
                        .offset(x: searchBarOffset)
                        .opacity(searchBarOpacity)
                        .card()
                }
            }
        }
        .onChange(of: isCancelSearching, perform: { value in
            if value {
                withAnimation(.easeOut(duration: 0.3)) {
                    searchBarOpacity = 0
                    searchBarOffset = 40
                    resultViewOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isSearch = false
                    isCancelSearching = false
                    gotSearchResult = false
                    searchResults.removeAll()
                }
            }
        })
        .onChange(of: searchText, perform: { value in
            searchResults.removeAll()
            gotSearchResult = false
            if value != "" {
                let queryWords = searchMapArray(text: value)
                                                
                var searchRef = Firestore.firestore().collection("contents").limit(to: 30)
                for i in queryWords {
                    searchRef = searchRef.whereField("searchMap.\(i)", isEqualTo: true)
                }
                let group = DispatchGroup()
                
                group.enter()
                searchRef.getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    for d in snapshot.documents {
                        group.enter()
                        requestContentInfo(d: d) { info in
                            if searchResults.contains(where: { $0.id == d.documentID }) == false && info.id != "" {
                                searchResults.append(info)
                            }
                            group.leave()
                        }
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        if searchResults.count == snapshot.documents.count {
                            gotSearchResult = true
                        }
                    }
                }
            }
        })
        .onChange(of: selection) { value in
            if value == contentInfoArray.count - 1 && contentInfoArray.count < 50 {
                nowRef.getDocuments { snapshot, err in
                    if let snapshot = snapshot {
                        guard let lastDocument = snapshot.documents.last else { return }
                        nowRef = Firestore.firestore().collection("contents")
                            .start(afterDocument: lastDocument)
                            .limit(to: collectionLimitCount)
                        requestDocument(ref: nowRef)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: authObserver.isSignIn, perform: { newValue in
            if newValue {
                if contentInfoArray.count == 0 {
                    requestDocument(ref: nowRef)
                } else {
                    for i in contentInfoArray {
                        if accountInfo.blockedUsers.contains(where: { $0 == i.createdUserID }) {
                            contentInfoArray.removeAll(where: { $0.createdUserID == i.createdUserID })
                        }
                    }
                }
            }
        })
        .onAppear {
            for (jIndex, j) in contentInfoArray.enumerated() {
                if j.deleted && jIndex >= 0 && jIndex < contentInfoArray.count {
                    if jIndex == contentInfoArray.count - 1 && selection == jIndex {
                        selection -= 1
                    }
                    contentInfoArray.remove(at: jIndex)
                }
            }
            
            var count = UserDefaults.standard.integer(forKey: "homeViewShowCount")
            if count == 4 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    let windows = windowScene?.windows.first
                    if let windowScene = windows?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                }
            }
            
            if count <= 4 {
                count += 1
                UserDefaults.standard.set(count, forKey: "homeViewShowCount")
            }
        }
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent)
        }
    }
    
    func requestDocument(ref: Query) {
        DispatchQueue.main.async {
            loadObserver.isLoading = true
            withAnimation(.linear(duration: 0.3)) {
                loadObserver.opacity = 1.0
            }
        }
        
        let group = DispatchGroup()
        group.enter()
        ref.getDocuments { snapshot, _ in
            if let snapshot = snapshot {
                group.enter()
                DispatchQueue(label: "getContentInfo").async {
                    for (index, i) in snapshot.documents.enumerated() {
                        if contentInfoArray.contains(where: { $0.id == i.documentID }) == false && (i.data()["style"] as? String) != "article" {
                            group.enter()
                            requestContentInfo(d: i) { info in
                                if info.id != "" {
                                    contentInfoArray.append(info)
                                }
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            if index == snapshot.documents.count - 1 {
                                contentInfoArray.append(ContentInfo())
                            }
                        }
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        withAnimation(.linear(duration: 0.3)) {
                            loadObserver.opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            loadObserver.isLoading = false
                        }
                    }
                }
            }
            group.leave()
        }
    }
    
    func requestContentInfo(d: QueryDocumentSnapshot, _ completion: @escaping(_ contentInfo: ContentInfo) -> Void) {
        let contentInfo = ContentInfo()
        contentInfo.id = d.documentID
        contentInfo.name = d.data()["name"] as? String ?? ""
        contentInfo.explanation = d.data()["description"] as? String ?? ""
        let backgroundImage = d.data()["backgroundImage"] as? String ?? ""
        contentInfo.backgroundAspectFit = d.data()["backgroundAspectFit"] as? Bool ?? false
        contentInfo.createdUserID = d.data()["createdUser"] as? String ?? ""
        let createdDate = d.data()["createdDate"] as? Timestamp ?? Timestamp()
        let updatedDate = d.data()["updatedDate"] as? Timestamp ?? Timestamp()
        contentInfo.createdDate = createdDate.dateValue()
        contentInfo.updatedDate = updatedDate.dateValue()
        contentInfo.contentStyle = d.data()["style"] as? String ?? ""
        if contentInfo.contentStyle == "scroll" {
            contentInfo.loopPlay = d.data()["bgmLoop"] as? Bool ?? true
        }
        contentInfo.parentWorld = d.data()["parentWorld"] as? String ?? ""
        contentInfo.parentCategory = d.data()["parentCategory"] as? String ?? ""
        let storage = Storage.storage()
        let group = DispatchGroup()
        
        if accountInfo.blockedUsers.contains(where: { $0 == contentInfo.createdUserID }) == false {
            group.enter()
            getUserNameAndIcon(id: contentInfo.createdUserID) { userName, iconImage in
                contentInfo.createdUserName = userName
                contentInfo.createdUserIcon = iconImage
                
                if backgroundImage != "" {
                    group.enter()
                    storage.reference(forURL: backgroundImage).getData(maxSize: 1024 * 1024 * 10) { data, err in
                        if let err = err {
                            print("Error: \(err)")
                        } else if let data = data {
                            contentInfo.backgroundImage = UIImage(data: data) ?? UIImage()
                        }
                        group.leave()
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(contentInfo)
            }
        } else {
            completion(ContentInfo())
        }
    }
}

//struct ContentHomeView_Previews: PreviewProvider {
    //static var previews: some View {
        //ContentHomeView()
    //}
//}
