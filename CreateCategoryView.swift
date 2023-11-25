//
//  CreateCategoryView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/07.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct CreateCategoryView: View {
    
    @State var info: (backgroundImage: UIImage, name: String, explanation: String) = (UIImage(named: "black") ?? UIImage(), "", "")
    @State var explanationHeight = CGFloat(80)
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30
    @State var viewName = "CreateCategoryView"
    @State var showImagePicker = false
    @State var showFile = false
    @State var descriptionTapped = false
    @State var nameTapped = false
    @State var choosePhotoSource = false
    @State var showImage = false
    @State var barHidden = false
    @State var chooseMenuPadding = CGFloat(-20)
    @State var chooseMenuOpacity = Double(0)
    @State var fileurls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerimages = [UIImage]()
    @State var showImageOpacity = 0.0
    var backgroundImage: UIImage
    @StateObject var worldInfo: WorldInfo
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var name: Name
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                BackgroundUIImage(image: backgroundImage, opacity: 0.2)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Category Name")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                            .padding([.leading, .trailing], 20)
                        
                        TextField("Enter Category Name", text: $info.name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                            .background(.white.opacity(0.7))
                            .cornerRadius(15)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 20)
                            .gesture(TapGesture().onEnded({ _ in
                                nameTapped = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    nameTapped = false
                                }
                            }))
                        
                        Text("Description")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.leading)
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                            .card()
                            .padding(.top, 40)
                            .padding([.leading, .trailing], 20)
                        
                        ContentTextingView(text: $info.explanation, height: $explanationHeight, viewBottomHeight: $bottomHeight, originalHeight: 80, fontSize: 16, fontWeight: .regular, textAlignment: .left, placeholder: NSLocalizedString("Description of This Category", comment: ""), textLimit: 300)
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: explanationHeight)
                            .padding(.top, 10)
                            .padding([.leading, .trailing], 20)
                            .gesture(TapGesture().onEnded({ _ in
                                descriptionTapped = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    descriptionTapped = false
                                }
                            }))
                        
                        HStack {
                            Spacer()
                            
                            Text("\(info.explanation.count)/300")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                                .card()
                        }
                        .padding(.top, 5)
                        .padding([.leading, .trailing], 20)
                        
                        Group {
                            Text("Background Image")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                .card()
                                .padding(.top, 40)
                            
                            ChooseBackgroundView(showContentMenu: $choosePhotoSource, image: $info.backgroundImage, showImage: $showImage, text: NSLocalizedString("Tap to Choose Image", comment: ""))
                                .padding(.top, 10)
                            
                            Button(action: {
                                info.backgroundImage = worldInfo.backgroundImage
                            }) {
                                HStack {
                                    Text("Select the Same Background as Home")
                                        .underline()
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .regular))
                                        .card()
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding([.leading, .trailing], 20)
                    }
                    .padding(.bottom, bottomHeight)
                }
                
                if choosePhotoSource {
                    VStack {
                        Spacer()
                        
                        ChooseFileOrLibrary(photoLibraryShow: $showImagePicker, fileShow: $showFile, menuShow: $choosePhotoSource, padding: $chooseMenuPadding, opacity: $chooseMenuOpacity, viewName: $viewName)
                            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() - 10)
                            .padding([.leading, .trailing], 20)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    chooseMenuPadding = 20.0
                                    chooseMenuOpacity = 1.0
                                }
                            }
                    }
                }
                
                if showImage {
                    ShowImageView(image: info.backgroundImage, showImageBool: $showImage, barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
                        .opacity(showImageOpacity)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .gesture(TapGesture().onEnded({ _ in
            if descriptionTapped == false && nameTapped == false {
                UIApplication.shared.closeKeyboard()
            }
        }))
        .sheet(isPresented: $showImagePicker, content: {
            SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerimages)
        })
        .onChange(of: showImagePicker, perform: { value in
            if value == false && pickerimages.count > 0 {
                info.backgroundImage = pickerimages[0]
                pickerimages.removeAll()
            }
        })
        .sheet(isPresented: $showFile, content: {
            FileView(multipleSelection: false, fileType: "photo", urls: $fileurls)
        })
        .onChange(of: fileurls.count, perform: { count in
            if count > 0 {
                do {
                    let data = try Data(contentsOf: fileurls[0])
                    if let image = UIImage(data: data) {
                        info.backgroundImage = image
                    }
                    fileurls.removeAll()
                } catch {
                    print("Catch: error when getting.")
                    fileurls.removeAll()
                }
            }
        })
        .ignoresSafeArea()
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "CreateCategoryView"
            }
            info.backgroundImage = worldInfo.backgroundImage
        }
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                switch info.name {
                case "":
                    Text("Create")
                        .bold()
                        .foregroundColor(.white.opacity(0.5))
                        .card()
                default:
                    Button(action: {
                        let ref = Firestore.firestore().collection("world").document(worldInfo.id).collection("contentCategory")
                        let document = ref.addDocument(data: [
                            "name": info.name,
                            "description": info.explanation,
                            "backgroundImage": "",
                            "index": worldInfo.contentCategory.count
                        ])
                        
                        if info.backgroundImage == worldInfo.backgroundImage {
                            let categoryDocument = ref.document(document.documentID)
                            categoryDocument.updateData(["backgroundImage": worldInfo.backgroundURL])
                            
                            let category = ContentCategory()
                            category.id = document.documentID
                            category.index = worldInfo.contentCategory.count
                            category.name = info.name
                            category.description = info.explanation
                            category.backgroundImage = info.backgroundImage
                            category.backgroundURL = ""
                            worldInfo.contentCategory.append(category)
                        } else {
                            let storageRef = Storage.storage().reference()
                            let data = customCompressImage(image: info.backgroundImage, rate: 0.3)
                            let path = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(accountInfo.id)/worlds/\(worldInfo.id)/categories/\(document.documentID)/image_\(UUID()).png"
                            let imageRef = storageRef.child(path)
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/png"
                            let uploadTask = imageRef.putData(data, metadata: metadata)
                            var downloadURL = URL(fileURLWithPath: "")
                            
                            uploadTask.observe(.success) { _ in
                                imageRef.downloadURL { url, err in
                                    if let url = url {
                                        downloadURL = url
                                        let imageURL = downloadURL.absoluteString
                                        document.updateData(["backgroundImage": imageURL])
                                        
                                        let category = ContentCategory()
                                        category.id = document.documentID
                                        category.index = worldInfo.contentCategory.count
                                        category.name = info.name
                                        category.description = info.explanation
                                        category.backgroundImage = info.backgroundImage
                                        category.backgroundURL = imageURL
                                        worldInfo.contentCategory.append(category)
                                    }
                                }
                            }
                        }
                        
                        let worldRef = Firestore.firestore().collection("world").document(worldInfo.id)
                        worldRef.updateData(["updatedDate" : Date()])
                        
                        dismiss()
                    }) {
                        Text("Create")
                            .bold()
                            .foregroundColor(.white)
                            .card()
                    }
                }
            }
        }
    }
}

//struct CreateCategoryView_Previews: PreviewProvider {
    //static var previews: some View {
        //CreateCategoryView()
    //}
//}
