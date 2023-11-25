//
//  EditAnnouncementView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/06.
//

import SwiftUI
import FirebaseFirestore

struct EditAnnouncementView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var showContent = false
    @State var showBoolArray = [Bool]()
    @State var noContent = false
    @State var cautionOpacity = 0.0
    @State var announceArray: [(announce: Announcement, opacity: Double)] = []
    @StateObject var worldInfo: WorldInfo
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack {
            BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<announceArray.count, id: \.self) { i in
                        VStack(spacing: 0) {
                            HStack {
                                Button(action: {
                                    removeContent(index: i)
                                }) {
                                    Image(systemName: "multiply")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundColor(.white)
                                        .opacity(announceArray[i].opacity)
                                        .card()
                                }
                                
                                Spacer()
                                
                                if announceArray.count > 1 {
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
                                                .opacity(announceArray[i].opacity)
                                                .card()
                                        }
                                    
                                    case announceArray.count - 1:
                                        Button(action: {
                                            sortUp(i: i)
                                        }) {
                                            Image(systemName: "arrow.up")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.white)
                                                .opacity(announceArray[i].opacity)
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
                                                .opacity(announceArray[i].opacity)
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
                                                .opacity(announceArray[i].opacity)
                                                .card()
                                        }
                                    }
                                }
                            }
                                                        
                            ZStack(alignment: .bottomLeading) {
                                Image(uiImage: announceArray[i].announce.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/3)
                                    .contentShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                
                                Rectangle()
                                    .foregroundColor(.black.opacity(0.2))
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/3)
                                
                                Text(announceArray[i].announce.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                    .frame(width: UIScreen.main.bounds.size.width - 60, alignment: .leading)
                                    .lineLimit(2)
                                    .card()
                                    .padding(10)
                            }
                            .cornerRadius(20)
                            .opacity(announceArray[i].opacity)
                            .card()
                            .padding(.top, 10)
                        }
                        .padding(.bottom, announceArray[i].announce.space)
                        .padding([.leading, .trailing], 20)
                    }
                    
                    Button(action: {
                        var contentExist = false
                        for categoryIndex in 0..<worldInfo.contentCategory.count {
                            if worldInfo.contentCategory[categoryIndex].contents.count > 0 {
                                contentExist = true
                            }
                            showBoolArray.append(false)
                        }
                        
                        if contentExist {
                            showContent.toggle()
                        } else {
                            showBoolArray.removeAll()
                            noContent = true
                            cautionOpacity = 1.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.linear(duration: 0.5)) {
                                    cautionOpacity = 0.0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    noContent = false
                                }
                            }
                        }
                    }) {
                        Text("+Add Announcement")
                            .font(.system(size: 20, weight: .medium))
                            .padding([.top, .bottom], 3)
                            .padding([.leading, .trailing], 10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                            }
                            .foregroundColor(.white)
                            .card()
                            
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                    .padding(.top, 20)
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30)
            }
            .ignoresSafeArea()
            
            if noContent {
                VStack {
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: UIScreen.main.bounds.size.width - 20, height: (UIScreen.main.bounds.size.width - 20) / 2)
                            .cornerRadius(20)
                        
                        Text("Content does not exsist.\n\nPlease create contents to add announcements.")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .center)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                }
                .opacity(cautionOpacity)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    worldInfo.announcements = announceArray.map({ $0.announce })
                    for (index, i) in worldInfo.announcements.enumerated() {
                        if i.index != index {
                            let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements").document(i.id)
                            ref.updateData(["index": index])
                            i.index = index
                        }
                    }
                    dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "EditAnnouncementView"
            }
            announceArray.removeAll()
            
            for i in worldInfo.announcements {
                announceArray.append((i, 1.0))
            }
        }
        .onChange(of: worldInfo.announcements.count) { _ in
            announceArray.removeAll()
            for i in worldInfo.announcements {
                announceArray.append((i, 1.0))
            }
        }
        .fullScreenCover(isPresented: $showContent, content: {
            NavigationView {
                AnnouncementSelectView(showBoolArray: $showBoolArray, worldInfo: worldInfo)
            }
            .accentColor(.white)
        })
    }
    
    func sortUp(i: Int) {
        let content = announceArray.remove(at: i-1)
        announceArray.insert(content, at: i)
        
        announceArray[i].opacity = 0
        announceArray[i-1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                announceArray[i].opacity = 1
                announceArray[i-1].opacity = 1
            }
        }
    }
    
    func sortDown(i: Int) {
        let content = announceArray.remove(at: i)
        announceArray.insert(content, at: i+1)
        
        announceArray[i].opacity = 0
        announceArray[i+1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                announceArray[i].opacity = 1
                announceArray[i+1].opacity = 1
            }
        }
    }
    
    func removeContent(index: Int) {
        withAnimation(.easeOut(duration: 0.3)) {
            announceArray[index].opacity = 0.0
            announceArray[index].announce.space -= ((UIScreen.main.bounds.size.width - 40)/3 + 67)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements").document(announceArray[index].announce.id)
            ref.delete()
            announceArray.remove(at: index)
        }
    }
}

//struct EditAnnouncementView_Previews: PreviewProvider {
    //static var previews: some View {
        //EditAnnouncementView()
    //}
//}
