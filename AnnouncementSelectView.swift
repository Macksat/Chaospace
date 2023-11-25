//
//  AnnouncementSelectView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/10.
//

import SwiftUI
import FirebaseFirestore

struct AnnouncementSelectView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var contentArray: [(name: String, image: UIImage)] = []
    @Binding var showBoolArray: [Bool]
    @StateObject var worldInfo: WorldInfo
    @State var selectedItem: [(arrayIndex: Int, contentIndex: Int)] = []
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
            
            ScrollView {
                VStack(spacing: 0) {
                    Text("You can select up to 5 contents.")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .card()
                        .padding(.bottom, 20)
                        .padding(.top, 10)
                    
                    ForEach(0..<worldInfo.contentCategory.count, id: \.self) { j in
                        Text(worldInfo.contentCategory[j].name)
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .card()
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width - 40)/2 - 20), alignment: .top)], alignment: .center) {
                            ForEach(0..<checkContentCount(index: j), id: \.self) { i in
                                Button(action: {
                                    if selectedItem.count < 5 {
                                        if selectedItem.filter({ $0 == (j, i) }).first == nil {
                                            selectedItem.append((j, i))
                                        } else {
                                            if let index = selectedItem.firstIndex(where: { $0 == (j, i) }) {
                                                selectedItem.remove(at: index)
                                            }
                                        }
                                    } else {
                                        if let index = selectedItem.firstIndex(where: { $0 == (j, i) }) {
                                            selectedItem.remove(at: index)
                                        }
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        ZStack(alignment: .bottomTrailing) {
                                            Image(uiImage: worldInfo.contentCategory[j].contents[i].backgroundImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                                .cornerRadius(15)
                                                .shadow(color: .black, radius: 15, x: 0, y: 0)
                                            if selectedItem.filter({ $0 == (j, i) }).first != nil {
                                                Rectangle()
                                                    .foregroundColor(.white.opacity(0.5))
                                                    .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                                    .cornerRadius(15)
                                                
                                                Image(systemName: "checkmark.circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 22, height: 22)
                                                    .foregroundColor(.black)
                                                    .padding([.bottom, .trailing], 5)
                                            }
                                        }
                                        
                                        Text(worldInfo.contentCategory[j].contents[i].name)
                                            .font(.system(size: 16))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, alignment: .leading)
                                            .lineLimit(2)
                                            .card()
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        
                        if worldInfo.contentCategory[j].contents.count > 4 {
                            Button(action: {
                                showBoolArray[j].toggle()
                            }) {
                                switch showBoolArray[j] {
                                case false:
                                    Text("Show more")
                                        .underline()
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                case true:
                                    Text("Show less")
                                        .underline()
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .card()
                            .padding(.bottom, 40)
                        }
                    }
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight())
                .padding([.leading, .trailing], 20)
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .ignoresSafeArea()
        .navigationBarTitle(Text(NSLocalizedString("Select Contents", comment: "") + "(\(selectedItem.count))"), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("announcements")
                    
                    for i in worldInfo.announcements {
                        let announceRef = ref.document(i.id)
                        announceRef.delete()
                    }
                    
                    worldInfo.announcements.removeAll()
                    
                    for (index, i) in selectedItem.enumerated() {
                        let document = ref.addDocument(data: [
                            "contentID": worldInfo.contentCategory[i.arrayIndex].contents[i.contentIndex].id,
                            "index": index,
                            "name": worldInfo.contentCategory[i.arrayIndex].contents[i.contentIndex].name
                        ])
                        
                        let announce = Announcement()
                        announce.name = worldInfo.contentCategory[i.arrayIndex].contents[i.contentIndex].name
                        announce.content = worldInfo.contentCategory[i.arrayIndex].contents[i.contentIndex].id
                        announce.index = index
                        announce.image = worldInfo.contentCategory[i.arrayIndex].contents[i.contentIndex].backgroundImage
                        announce.id = document.documentID
                        worldInfo.announcements.append(announce)
                    }
                    
                    dismiss()
                }) {
                    Text("Add")
                        .bold()
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
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
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "AnnouncementSelectView"
            }
            for i in worldInfo.announcements {
                for (cateIndex, category) in worldInfo.contentCategory.enumerated() {
                    for (contIndex, content) in category.contents.enumerated() {
                        if i.content == content.id {
                            selectedItem.append((cateIndex, contIndex))
                        }
                    }
                }
            }
        }
        .onDisappear {
            showBoolArray.removeAll()
        }
    }
    
    func checkContentCount(index: Int) -> Int {
        var count = 4
        if worldInfo.contentCategory[index].contents.count < count {
            count = worldInfo.contentCategory[index].contents.count
        }
        
        if showBoolArray[index] == true {
            count = worldInfo.contentCategory[index].contents.count
        }
        
        return count
    }
}

//struct AnnouncementSelectView_Previews: PreviewProvider {
    //static var previews: some View {
        //AnnouncementSelectView()
    //}
//}
