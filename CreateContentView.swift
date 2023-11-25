//
//  CreateContentView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/06.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct CreateContentView: View {
    
    @StateObject var info = ContentInfo()
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var explanationHeight = CGFloat(80)
    @State var contentStyle = 0
    @State var contentExplanation = NSLocalizedString("This format can create a scrollable content.", comment: "")
    @State var showDeleteAlert = false
    @StateObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @Binding var isPresent: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var name: Name
    @EnvironmentObject var accountInfo: AccountInfo
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                if worldInfo.backgroundImage != UIImage(named: "black") ?? UIImage() {
                    BackgroundUIImage(image: worldInfo.backgroundImage, opacity: 0.2)
                } else {
                    BackgroundUIImage(image: info.backgroundImage, opacity: 0.2)
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Content Name")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                        
                        TextField("Content Name", text: $info.name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                            .background(.white.opacity(0.7))
                            .cornerRadius(15)
                            .padding(.top, 10)
                        
                        Text("Description")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                        
                        ContentTextingView(text: $info.explanation, height: $explanationHeight, viewBottomHeight: $bottomHeight, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Description of This Content", comment: ""), textLimit: 300)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: explanationHeight)
                            .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            
                            Text("\(info.explanation.count)/300")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                                .card()
                        }
                        .padding(.top, 5)
                        
                        if worldInfo.id != "" {
                            Text("Content Format")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            Text(contentExplanation)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 10)
                                .onChange(of: contentStyle) { value in
                                    if value == 0 {
                                        contentExplanation = NSLocalizedString("This format can create a scrollable content.", comment: "")
                                    } else {
                                        contentExplanation = NSLocalizedString("This format can create a multi-page content.", comment: "")
                                    }
                                }
                            
                            Picker("Background Style", selection: $contentStyle) {
                                ForEach(0..<2, id: \.self) { i in
                                    switch i {
                                    case 0:
                                        Text("Scroll")
                                            .lineLimit(1)
                                            .tag(i)
                                        
                                    default:
                                        Text("Page")
                                            .lineLimit(1)
                                            .tag(i)
                                    }
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(.black.opacity(0.7))
                            .frame(width: UIScreen.main.bounds.size.width - 40)
                            .cornerRadius(8)
                            .padding(.top, 20)
                            .onChange(of: contentStyle) { newValue in
                                if newValue == 0 {
                                    info.contentStyle = "scroll"
                                } else {
                                    info.contentStyle = "show"
                                }
                            }
                        } else {
                            Button(action: {
                                showDeleteAlert.toggle()
                            }) {
                                Text("Delete Content")
                                    .font(.system(size: 20, weight: .medium))
                                    .padding([.top, .bottom], 3)
                                    .padding([.leading, .trailing], 10)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                    }
                                    .foregroundColor(.red)
                                    .card()
                            }
                            .alert(isPresented: $showDeleteAlert, content: {
                                Alert(title: Text("Caution"),
                                      message: Text("Do you want to delete this content?"),
                                      primaryButton: .default(Text("Cancel"), action: {
                                            showDeleteAlert = false
                                        }),
                                      secondaryButton: .destructive(Text("Delete"), action: {
                                            let ref = Firestore.firestore().collection("contents").document(info.id)
                                            let group = DispatchGroup()
                                            group.enter()
                                            ref.getDocument { snapshot, _ in
                                                guard let i = snapshot else { return }
                                                var batch = Firestore.firestore().batch()
                                                switch i.data()?["style"] as? String {
                                                case "scroll":
                                                    let scrollRef = ref.collection("scrollContent")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: scrollRef, whereField: "", equalTo: "") { scrollSnapshot in
                                                        for (jIndex, j) in scrollSnapshot.documents.enumerated() {
                                                            let musicRef = scrollRef.document(j.documentID).collection("musicList")
                                                            group.enter()
                                                            requestFirebaseSnapshot(ref: musicRef, whereField: "", equalTo: "") { musicSnapshot in
                                                                var musicBatch = Firestore.firestore().batch()
                                                                for (kIndex, k) in musicSnapshot.documents.enumerated() {
                                                                    musicBatch.deleteDocument(k.reference)
                                                                    if (kIndex + 1) % 500 == 0 || kIndex == musicSnapshot.documents.count - 1 {
                                                                        musicBatch.commit()
                                                                        musicBatch = Firestore.firestore().batch()
                                                                    }
                                                                }
                                                                musicSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                                                                group.leave()
                                                            }
                                                            
                                                            batch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == scrollSnapshot.documents.count - 1 {
                                                                batch.commit()
                                                                batch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        group.leave()
                                                    }
                                                case "show":
                                                    let showRef = ref.collection("showContent")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: showRef, whereField: "", equalTo: "") { showSnapshot in
                                                        for (jIndex, j) in showSnapshot.documents.enumerated() {
                                                            batch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == showSnapshot.documents.count - 1 {
                                                                batch.commit()
                                                                batch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        group.leave()
                                                    }
                                                case "article":
                                                    let articleRef = ref.collection("articleContent")
                                                    group.enter()
                                                    requestFirebaseSnapshot(ref: articleRef, whereField: "", equalTo: "") { articleSnapshot in
                                                        for (jIndex, j) in articleSnapshot.documents.enumerated() {
                                                            batch.deleteDocument(j.reference)
                                                            if (jIndex + 1) % 500 == 0 || jIndex == articleSnapshot.documents.count - 1 {
                                                                batch.commit()
                                                                batch = Firestore.firestore().batch()
                                                            }
                                                        }
                                                        group.leave()
                                                    }
                                                default: break
                                                }
                                                group.leave()
                                            }
                                    
                                            group.notify(queue: .main) {
                                                ref.delete()
                                                deleteDesignatedStorageFolder(path: "gs://chaospace-60bd6.appspot.com/gs:/chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(info.parentWorld)/contents/\(info.id)")
                                                
                                                let announceRef = Firestore.firestore().collection("world").document(info.parentWorld).collection("announcements")
                                                announceRef.getDocuments { snapshot, _ in
                                                    guard let snapshot = snapshot else { return }
                                                    let batch = Firestore.firestore().batch()
                                                    for d in snapshot.documents {
                                                        if info.id == (d.data()["contentID"] as? String) {
                                                            batch.deleteDocument(d.reference)
                                                        }
                                                    }
                                                    batch.commit()
                                                }
                                        
                                                info.deleted = true
                                                
                                                dismiss()
                                            }
                                        })
                                      )
                            })
                            .padding(.top, 40)
                        }
                    }
                    .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                    .padding(.bottom, bottomHeight + 30)
                    .padding([.leading, .trailing], 20)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .ignoresSafeArea()
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreateContentView"
            }
            
            if info.contentStyle == "scroll" {
                contentStyle = 0
            } else {
                contentStyle = 1
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    isPresent = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .card()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                switch info.name {
                case "":
                    Text("Next")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                default:
                    switch contentStyle {
                    case 0:
                        NavigationLink(destination: MakingScrollContentView(contentInfo: info, worldInfo: worldInfo, categoryIndex: categoryIndex, isPresent: $isPresent)) {
                            Text("Next")
                                .foregroundColor(.white)
                                .bold()
                                .card()
                        }
                    default:
                        NavigationLink(destination: MakingShowContentView(contentInfo: info, worldInfo: worldInfo, categoryIndex: categoryIndex, isPresent: $isPresent)) {
                            Text("Next")
                                .foregroundColor(.white)
                                .bold()
                                .card()
                        }
                        .simultaneousGesture(TapGesture().onEnded{
                            if info.showContents.count == 0 {
                                info.showContents.append(ShowContent(title: info.name))
                            }
                        })
                    }
                }
            }
        }
    }
}

//struct CreateContentView_Previews: PreviewProvider {
    //static var previews: some View {
        //CreateContentView()
    //}
//}
