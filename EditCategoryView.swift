//
//  EditCategoryView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/06.
//
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EditCategoryView: View {
    
    @StateObject var worldInfo: WorldInfo
    @State var categoryArray: [(category: ContentCategory, opacity: Double)] = []
    var backgroundImage: UIImage
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack {
            BackgroundUIImage(image: backgroundImage, opacity: 0.2)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<categoryArray.count, id: \.self) { i in
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                
                                if categoryArray.count > 1 {
                                    switch i {
                                    case 0:
                                        Button(action: {
                                            sortDown(i: i)
                                        }) {
                                            Image(systemName: "arrow.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.white)
                                                .opacity(categoryArray[i].opacity)
                                                .card()
                                        }
                                        
                                    case categoryArray.count - 1:
                                        Button(action: {
                                            sortUp(i: i)
                                        }) {
                                            Image(systemName: "arrow.up")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.white)
                                                .opacity(categoryArray[i].opacity)
                                                .card()
                                        }
                                        
                                    default:
                                        Button(action: {
                                            sortUp(i: i)
                                        }) {
                                            Image(systemName: "arrow.up")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.white)
                                                .opacity(categoryArray[i].opacity)
                                                .card()
                                                .padding(.trailing, 20)
                                        }
                                        
                                        Button(action: {
                                            sortDown(i: i)
                                        }) {
                                            Image(systemName: "arrow.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.white)
                                                .opacity(categoryArray[i].opacity)
                                                .card()
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                            
                            NavigationLink(destination: EditCategoryInfoView(worldInfo: worldInfo, categoryIndex: $categoryArray[i].category.index)) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                        .cornerRadius(15)
                                    
                                    HStack {
                                        Text(categoryArray[i].category.name)
                                            .foregroundColor(.black)
                                            .font(.system(size: 20, weight: .semibold))
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        Image(uiImage: categoryArray[i].category.backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/4 - 10, height: (UIScreen.main.bounds.size.width - 40)/4 - 10)
                                            .cornerRadius(10)
                                    }
                                    .padding([.leading, .trailing], 5)
                                }
                                .opacity(categoryArray[i].opacity)
                            }
                            .padding(.bottom, 20)
                        }
                        .onChange(of: categoryArray[i].opacity) { value in
                            if value == 0.0 {
                                withAnimation(.linear(duration: 0.3)) {
                                    categoryArray[i].opacity = 1.0
                                }
                            }
                        }
                    }
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                .padding([.leading, .trailing], 20)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(destination: CreateCategoryView(backgroundImage: backgroundImage, worldInfo: worldInfo)) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .onWillAppear {
            categoryArray.removeAll()
            name.name = "EditCategoryView"
            
            for i in worldInfo.contentCategory {
                categoryArray.append((i, 1.0))
            }
        }
        .onWillDisappear {
            worldInfo.contentCategory = categoryArray.map({ $0.category })
            for (index, i) in worldInfo.contentCategory.enumerated() {
                if i.index != index {
                    let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory").document(i.id)
                    ref.updateData(["index": index])
                    i.index = index
                }
            }
        }
        .onChange(of: worldInfo.contentCategory.count) { _ in
            categoryArray.removeAll()
            for i in worldInfo.contentCategory {
                categoryArray.append((i, 1.0))
            }
        }
    }
    
    func sortUp(i: Int) {
        let content = categoryArray.remove(at: i-1)
        categoryArray.insert(content, at: i)
        
        categoryArray[i].opacity = 0
        categoryArray[i-1].opacity = 0
    }
    
    func sortDown(i: Int) {
        let content = categoryArray.remove(at: i)
        categoryArray.insert(content, at: i+1)
        
        categoryArray[i].opacity = 0
        categoryArray[i+1].opacity = 0
    }
}

//struct EditCategoryView_Previews: PreviewProvider {
    //static var previews: some View {
        //EditCategoryView()
    //}
//}
