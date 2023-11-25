//
//  LibraryDetailView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/05/12.
//

import SwiftUI

struct LibraryDetailView: View {
    
    let navigationHeight = UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10
    @State var gotContent = false
    @Binding var contentArray: [ContentInfo]
    @Binding var worldArray: [WorldInfo]
    var contentBool: Bool = false
    var viewName: String = ""
    @EnvironmentObject var name: Name
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width )/2 - 1), spacing: 2, alignment: .top), GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width )/2 - 1), spacing: 2, alignment: .top)], alignment: .center, spacing: 3) {
                        switch viewName {
                        case NSLocalizedString("Favorite Contents", comment: ""):
                            ForEach(0..<contentArray.count, id: \.self) { i in
                                NavigationLink(destination: segueView(i: i)) {
                                    ZStack(alignment: .bottomLeading) {
                                        Image(uiImage: contentArray[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width-4)/2, height: (UIScreen.main.bounds.size.width-4)/2)
                                            .clipped()
                                        
                                        Rectangle()
                                            .foregroundColor(.black.opacity(0.2))
                                        
                                        Text(contentArray[i].name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .card()
                                            .padding(5)
                                    }
                                    .frame(width: (UIScreen.main.bounds.size.width-4)/2, height: (UIScreen.main.bounds.size.width-4)/2, alignment: .leading)
                                    .cornerRadius(5)
                                }
                                .simultaneousGesture(TapGesture().onEnded({ _ in
                                    addViewCount(id: contentArray[i].id, collection: "contents")
                                    
                                    let group = DispatchGroup()
                                    if contentArray[i].gotContent == false {
                                        if contentArray[i].contentStyle == "scroll" {
                                            group.enter()
                                            getScrollContents(contentInfo: contentArray[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                                contentArray[i].scrollContents = scrollContents
                                                contentArray[i].backgroundImage = backgroundImage
                                                contentArray[i].music = musicURL
                                                contentArray[i].musicData = musicData
                                                contentArray[i].gotContent = true
                                                group.leave()
                                            }
                                        } else if contentArray[i].contentStyle == "show" {
                                            group.enter()
                                            getShowContents(contentInfo: contentArray[i]) { showContents in
                                                contentArray[i].showContents = showContents
                                                contentArray[i].gotContent = true
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
                        case NSLocalizedString("Following Worlds", comment: ""):
                            ForEach(0..<worldArray.count, id: \.self) { i in
                                NavigationLink(destination: segueView(i: i)) {
                                    ZStack(alignment: .bottomLeading) {
                                        Image(uiImage: worldArray[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width-4)/2, height: (UIScreen.main.bounds.size.width-4)/2)
                                            .clipped()
                                        
                                        Rectangle()
                                            .foregroundColor(.black.opacity(0.2))
                                        
                                        Text(worldArray[i].name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .card()
                                            .padding(5)
                                    }
                                    .frame(width: (UIScreen.main.bounds.size.width-4)/2, height: (UIScreen.main.bounds.size.width-4)/2, alignment: .leading)
                                    .cornerRadius(5)
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                    
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                        .padding([.leading, .trailing], 20)
                        .padding(.top, 20)
                }
                .padding(.top, navigationHeight)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 20)
            }
            .background(Color.chaosBlack)
            .ignoresSafeArea()
            
            GradientNavigationBar()
            
            Text(viewName)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(height: UINavigationController().navigationBar.frame.size.height, alignment: .center)
                .card()
                .padding(.top, statusBarSize())
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                CustomBackButtonView()
            }
        }
        .onWillAppear {
            name.name = "LibraryDetailView"
            gotContent = false
        }
        .onAppear {
            for (index, i) in worldArray.enumerated() {
                if i.following == false {
                    worldArray.remove(at: index)
                    if worldArray.count == 1 {
                        dismiss()
                    }
                }
            }
            
            for (index, i) in contentArray.enumerated() {
                if i.isFavorite == false {
                    contentArray.remove(at: index)
                    if contentArray.count == 1 {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder func segueView(i: Int) -> some View {
        if contentBool {
            if contentArray[i].contentStyle == "scroll" {
                ContentScrollView(contentInfo: contentArray[i], gotContent: $gotContent)
            } else if contentArray[i].contentStyle == "show" {
                ContentShowView(contentInfo: contentArray[i], gotContent: $gotContent)
            }
            EmptyView()
        } else {
            CreatorHomeView(worldInfo: worldArray[i])
        }
    }
}

//struct LibraryDetailView_Previews: PreviewProvider {
    //static var previews: some View {
        //LibraryDetailView()
    //}
//}
