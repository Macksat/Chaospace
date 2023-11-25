//
//  HomeView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/05.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import StoreKit

let categoryArray = [NSLocalizedString("All", comment: ""), NSLocalizedString("Illustration", comment: ""), NSLocalizedString("Video", comment: ""), NSLocalizedString("Music", comment: ""), NSLocalizedString("Comic", comment: ""), NSLocalizedString("Novel", comment: ""), NSLocalizedString("Others", comment: "")]

func statusBarSize() -> CGFloat{
    var statusBarHeight: CGFloat
    if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.height
    }
    return statusBarHeight
}

struct HomeView: View {
    
    @State var selectedCategoryIndex = 0
    @State var selectedCategory = ""
    @State var collectionLimitCount = 10
    @State var worldInfoArray: [(selection: Int, worldInfo: [WorldInfo])] = [(0, []), (0, []), (0, []), (0, []), (0, []), (0, []), (0, [])]
    @State var nowRefs = [Firestore.firestore().collection("world").limit(to: 10)]
    @State var searchText = ""
    @State var isCancelSearching = false
    @Binding var isSearch: Bool
    @State var gotSearchResult = false
    @State var searchBarOpacity = Double(0)
    @State var searchBarOffset = CGFloat(40)
    @State var resultViewOpacity = Double(0)
    @State var searchResults = [WorldInfo]()
    @StateObject var loadObserver = LoadObserver()
    @ObservedObject var accountInfo: AccountInfo
        
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                if worldInfoArray[selectedCategoryIndex].worldInfo.count > 0 {
                    TabView(selection: $worldInfoArray[selectedCategoryIndex].selection) {
                        ForEach(0..<worldInfoArray[selectedCategoryIndex].worldInfo.count, id: \.self) { i in
                            switch worldInfoArray[selectedCategoryIndex].worldInfo[i].id {
                            case "":
                                HomeViewAd()
                            default:
                                ZStack(alignment: .top) {
                                    Image(uiImage: worldInfoArray[selectedCategoryIndex].worldInfo[i].backgroundImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: proxy.size.width, height: proxy.size.height)
                                        .clipped()
                                    
                                    Rectangle()
                                        .foregroundColor(.black.opacity(0.2))
                                        .frame(width: proxy.size.width, height: proxy.size.height)
                                    
                                    VStack {
                                        NavigationLink(destination: OtherAccountView(accountID: worldInfoArray[selectedCategoryIndex].worldInfo[i].createdUser)) {
                                            HStack {
                                                Account(image: worldInfoArray[selectedCategoryIndex].worldInfo[i].createdUserIcon, name: worldInfoArray[selectedCategoryIndex].worldInfo[i].createdUserName, imageSize: 45, textSize: 16)
                                                    .card()
                                                    .padding(.leading, 20)
                                                
                                                Spacer()
                                            }
                                            
                                        }
                                        .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize()+80)
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text(worldInfoArray[selectedCategoryIndex].worldInfo[i].name)
                                                .bold()
                                                .font(.system(size: 36))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .card()
                                                .padding([.leading, .trailing], 20)
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            
                                            Text(worldInfoArray[selectedCategoryIndex].worldInfo[i].explanation)
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
                                        
                                        NavigationLink(destination: CreatorHomeView(worldInfo: worldInfoArray[selectedCategoryIndex].worldInfo[i])) {
                                            Text("Go")
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
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Spacer()
                    
                    ForEach(0..<categoryArray.count, id: \.self) { i in
                        Button(action: {
                            selectedCategoryIndex = i
                            selectedCategory = categoryArray[i]
                        }) {
                            switch selectedCategoryIndex {
                            case i:
                                Text(categoryArray[i])
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 10)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .card()
                            default:
                                Text(categoryArray[i])
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.white, lineWidth: 2)
                                    )
                                    .card()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(height: 60)
                .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize())
            }
            
            if isSearch {
                WorldSearchView(resultArray: $searchResults, searchText: $searchText, gotSearchResult: $gotSearchResult)
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
                    SearchBar(placeholder: NSLocalizedString("Search Worlds", comment: ""), text: $searchText, isCancel: $isCancelSearching)
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
                                                
                var searchRef = Firestore.firestore().collection("world").limit(to: 30)
                for i in queryWords {
                    searchRef = searchRef.whereField("searchMap.\(i)", isEqualTo: true)
                }
                let group = DispatchGroup()
                
                group.enter()
                searchRef.getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    for d in snapshot.documents {
                        group.enter()
                        requestWorldInfo(d: d) { info in
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
        .onChange(of: worldInfoArray[selectedCategoryIndex].selection) { value in
            if value == worldInfoArray[selectedCategoryIndex].worldInfo.count - 1 && worldInfoArray[selectedCategoryIndex].worldInfo.count < 50 {
                nowRefs[selectedCategoryIndex].getDocuments { snapshot, err in
                    if let snapshot = snapshot {
                        guard let lastDocument = snapshot.documents.last else { return }
                        nowRefs[selectedCategoryIndex] = Firestore.firestore().collection("world")
                            .start(afterDocument: lastDocument)
                            .limit(to: collectionLimitCount)
                        requestDocument(ref: nowRefs[selectedCategoryIndex])
                    }
                }
            }
        }
        .onChange(of: selectedCategoryIndex, perform: { value in
            if worldInfoArray[selectedCategoryIndex].worldInfo.count == 0 {
                requestDocument(ref: nowRefs[selectedCategoryIndex])
            } else {
                for i in worldInfoArray[selectedCategoryIndex].worldInfo {
                    if accountInfo.blockedUsers.contains(where: { $0 == i.createdUser }) {
                        worldInfoArray[selectedCategoryIndex].worldInfo.removeAll(where: { $0.createdUser == i.createdUser })
                    }
                }
            }
        })
        .ignoresSafeArea()
        .onWillAppear {
            if nowRefs.count == 1 {
                for i in 1..<categoryArray.count {
                    nowRefs.append((Firestore.firestore().collection("world")
                        .whereField("categories", arrayContains: categoryArray[i])
                        .limit(to: collectionLimitCount)))
                }
            }
            
            if worldInfoArray[selectedCategoryIndex].worldInfo.count == 0 {
                requestDocument(ref: nowRefs[selectedCategoryIndex])
            } else {
                for i in worldInfoArray[selectedCategoryIndex].worldInfo {
                    if accountInfo.blockedUsers.contains(where: { $0 == i.createdUser }) {
                        worldInfoArray[selectedCategoryIndex].worldInfo.removeAll(where: { $0.createdUser == i.createdUser })
                    }
                }
            }
        }
        .onAppear {
            for (iIndex, i) in worldInfoArray.enumerated() {
                for (jIndex, j) in i.worldInfo.enumerated() {
                    if j.deleted && iIndex < worldInfoArray.count && iIndex >= 0 && jIndex >= 0 && jIndex < i.worldInfo.count {
                        if jIndex == i.worldInfo.count - 1 && i.selection == jIndex {
                            worldInfoArray[iIndex].selection -= 1
                        }
                        worldInfoArray[iIndex].worldInfo.remove(at: jIndex)
                    }
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
                DispatchQueue(label: "getWorldInfo").async {
                    for (index, i) in snapshot.documents.enumerated() {
                        if worldInfoArray[selectedCategoryIndex].worldInfo.contains(where: { $0.id == i.documentID }) == false {
                            group.enter()
                            requestWorldInfo(d: i) { info in
                                if info.id != "" {
                                    worldInfoArray[selectedCategoryIndex].worldInfo.append(info)
                                }
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            if index == snapshot.documents.count - 1 {
                                worldInfoArray[selectedCategoryIndex].worldInfo.append(WorldInfo())
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
    
    func requestWorldInfo(d: QueryDocumentSnapshot, _ completion: @escaping(_ worldInfo: WorldInfo) -> Void) {
        let worldInfo = WorldInfo()
        worldInfo.id = d.documentID
        worldInfo.name = d.data()["name"] as! String
        worldInfo.explanation = d.data()["description"] as! String
        let backgroundImage = d.data()["backgroundImage"] as! String
        worldInfo.backgroundURL = backgroundImage
        worldInfo.bgm = d.data()["bgm"] as! String
        worldInfo.bgmName = d.data()["bgmName"] as! String
        worldInfo.createdUser = d.data()["createdUser"] as! String
        worldInfo.tags = d.data()["tags"] as! [String]
        worldInfo.category = d.data()["categories"] as! [String]
        let createdDate = d.data()["createdDate"] as! Timestamp
        let updatedDate = d.data()["updatedDate"] as! Timestamp
        worldInfo.createdDate = createdDate.dateValue()
        worldInfo.updatedDate = updatedDate.dateValue()
        let storage = Storage.storage()
        let group = DispatchGroup()
        
        if accountInfo.blockedUsers.contains(where: { $0 == worldInfo.createdUser }) == false {
            group.enter()
            getUserNameAndIcon(id: worldInfo.createdUser) { userName, iconImage in
                worldInfo.createdUserName = userName
                worldInfo.createdUserIcon = iconImage
                
                if backgroundImage != "" {
                    group.enter()
                    storage.reference(forURL: backgroundImage).getData(maxSize: 1024 * 1024 * 10) { data, err in
                        if let err = err {
                            print("Error: \(err)")
                        } else if let data = data {
                            worldInfo.backgroundImage = UIImage(data: data) ?? UIImage()
                        }
                        group.leave()
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(worldInfo)
            }
        } else {
            completion(WorldInfo())
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
        
    //static var previews: some View {
        //HomeView()
            //.edgesIgnoringSafeArea(.all)
   // }
//}
