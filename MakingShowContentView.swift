//
//  MakingShowContentView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/13.
//

import SwiftUI
import CoreMedia
import UniformTypeIdentifiers

struct MakingShowContentView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var textHeight = CGFloat(80)
    @State var selection = 0
    @State var showPages = false
    @State var hideContent = false
    @State var showMenu = false
    @State var showFile = false
    @State var showPhotoLibrary = false
    @State var menuCancelTapped = false
    @State var menuType = ""
    @State var menuOpacity = 0.0
    @State var menuPadding = -20.0
    @State var pageOpacity = 0.0
    @State var contentMenuPadding = CGFloat(-20)
    @State var contentMenuOpacity = 0.0
    @State var showContentMenu = false
    @State var showImage = false
    @State var showVideo = false
    @State var barHidden = false
    @State var urls = [URL]()
    @State var pickerurls = [URL]()
    @State var pickerImages = [UIImage]()
    @State var viewName = "MakingShowContentView"
    @State var showImageOpacity = 0.0
    @StateObject var contentInfo: ContentInfo
    @EnvironmentObject var music: Music
    @EnvironmentObject var name: Name
    @ObservedObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @Binding var isPresent: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                TabView(selection: $selection) {
                    ForEach(0..<contentInfo.showContents.count, id: \.self) { i in
                        ZStack(alignment: .bottom) {
                            ContentBackgroundImage(image: contentInfo.showContents[i].backgroundImage, width: proxy.size.width, height: proxy.size.height, opacity: 0.25, aspectFit: contentInfo.showContents[i].backgroundAspectFit)
                            
                            if hideContent == false {
                                VStack(spacing: 0) {
                                    switch i {
                                    case 0:
                                        TextField("Title", text: $contentInfo.showContents[i].title)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 28, weight: .bold))
                                            .multilineTextAlignment(.center)
                                            .frame(width: proxy.size.width - 40, height: 48)
                                            .foregroundColor(.black)
                                            .background(.white.opacity(0.7))
                                            .cornerRadius(15)
                                        
                                        Spacer()
                                                                   
                                        Button(action: {
                                            
                                            contentInfo.showContents.append(ShowContent(backgroundImage: contentInfo.showContents[i].backgroundImage, backgroundAspectFit: contentInfo.showContents[i].backgroundAspectFit, music: contentInfo.showContents[i].music, loopPlay: contentInfo.showContents[i].loopPlay, stopBool: contentInfo.showContents[i].stopBool))
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.225) {
                                                selection = contentInfo.showContents.count - 1
                                            }
                                        }) {
                                            Text("+Add Page")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .medium))
                                                .padding([.top, .bottom], 3)
                                                .padding([.leading, .trailing], 10)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(lineWidth: 2)
                                                }
                                                .card()
                                        }
                                        .padding(.top, 20)
                                    default:
                                        TextField("Title(Optional)", text: $contentInfo.showContents[i].title)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 28, weight: .bold))
                                            .multilineTextAlignment(.center)
                                            .frame(width: proxy.size.width - 40, height: 48)
                                            .foregroundColor(.black)
                                            .background(.white.opacity(0.7))
                                            .cornerRadius(15)
                                            .padding(.bottom, 40)
                                                               
                                        ZStack {
                                            VStack(spacing: 10) {
                                                MakingShowAddContent(contentInfo: contentInfo, i: $selection, showContentMenu: $showContentMenu, showImage: $showImage, showVideo: $showVideo, width: proxy.size.width)
                                                
                                                Spacer()
                                            }
                                               
                                            VStack {
                                                Spacer()
                                                
                                                ContentTextingView(text: $contentInfo.showContents[i].text, height: $textHeight, viewBottomHeight: $bottomHeight, originalHeight: 80.0, fontSize: 16, fontWeight: .medium, textAlignment: .left, placeholder: NSLocalizedString("Text here...(Optional)", comment: ""))
                                                    .frame(width: proxy.size.width - 40, height: proxy.size.height/3.25)
                                                                                
                                                Button(action: {
                                                    contentInfo.showContents.append(ShowContent(backgroundImage: contentInfo.showContents[i].backgroundImage, backgroundAspectFit: contentInfo.showContents[i].backgroundAspectFit, music: contentInfo.showContents[i].music, loopPlay: contentInfo.showContents[i].loopPlay, stopBool: contentInfo.showContents[i].stopBool))
                                                    selection = contentInfo.showContents.count - 1
                                                }) {
                                                    Text("+Add Page")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 20, weight: .medium))
                                                        .padding([.top, .bottom], 3)
                                                        .padding([.leading, .trailing], 10)
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(lineWidth: 2)
                                                        }
                                                        .card()
                                                }
                                                .padding(.top, 20)
                                            }
                                        }
                                    }
                                }
                                .frame(width: proxy.size.width - 40, height: proxy.size.height - (bottomHeight + statusBarSize() + UINavigationController().navigationBar.frame.size.height + 40))
                                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                                .padding([.leading, .trailing], 20)
                                .padding(.bottom, bottomHeight + 30)
                            }
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .rotationEffect(.degrees(-90))
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
                .transition(.slide)
                .animation(.easeOut(duration: 0.5), value: selection)
                .onChange(of: selection) { value in
                    music.musicMuteBool = true
                    music.pauseBool = true
                    music.musicURL = URL(fileURLWithPath: "")
                    
                    if showContentMenu && value == 0 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            contentMenuPadding = -20.0
                            contentMenuOpacity = 0.0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showContentMenu = false
                        }
                    }
                }
                
                if showMenu {
                    MakingMenuView(width: proxy.size.width, menuType: $menuType, showFile: $showFile, showPhotoLibrary: $showPhotoLibrary, cancelTapped: $menuCancelTapped, image: $contentInfo.showContents[selection].backgroundImage, aspectFit: $contentInfo.showContents[selection].backgroundAspectFit, musicURL: $contentInfo.showContents[selection].music, loopPlay: $contentInfo.showContents[selection].loopPlay, viewName: $viewName)
                        .opacity(menuOpacity)
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + menuPadding + 10)
                        .padding([.leading, .trailing], 20)
                        .gesture(DragGesture(coordinateSpace: .global).onEnded({ value in
                            if value.translation.height > 30 {
                                removeMenu()
                            }
                         }))
                        .onChange(of: menuCancelTapped) { newValue in
                            if newValue {
                                removeMenu()
                                menuCancelTapped = false
                            }
                        }
                }
                
                if showContentMenu {
                    VStack {
                        Spacer()
                        
                        ChooseFileOrLibrary(photoLibraryShow: $showPhotoLibrary, fileShow: $showFile, menuShow: $showContentMenu, padding: $contentMenuPadding, opacity: $contentMenuOpacity, viewName: $viewName)
                            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10)
                            .padding([.leading, .trailing], 20)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    contentMenuPadding = 20.0
                                    contentMenuOpacity = 1.0
                                }
                            }
                    }
                }
                
                if showImage {
                    ShowImageView(image: contentInfo.showContents[selection].image, showImageBool: $showImage, barHidden: $barHidden, preName: $viewName, opacity: $showImageOpacity)
                        .opacity(showImageOpacity)
                }
                
                if showVideo {
                    ShowVideoView(url: $contentInfo.showContents[selection].video, showVideoBool: $showVideo, preName: $viewName)
                }
                
                if showPages {
                    MakingShowPagesView(content: contentInfo, selection: $selection, showPages: $showPages, pageOpacity: $pageOpacity, hideContent: $hideContent)
                        .opacity(pageOpacity)
                }
                
                GradientNavigationBar()
            }
        }
        .background(.black)
        .sheet(isPresented: $showFile, content: {
            if viewName == "MakingShowContentView" {
                FileView(multipleSelection: false, fileType: menuType, urls: $urls)
            } else {
                FileView(multipleSelection: false, fileType: "photoVideo", urls: $urls)
            }
        })
        .onChange(of: urls.count, perform: { count in
            if count > 0 {
                if viewName == "MakingShowContentView" {
                    switch menuType {
                    case "music":
                        contentInfo.showContents[selection].music = urls[0]
                    case "photo":
                        do {
                            let data = try Data(contentsOf: urls[0])
                            contentInfo.showContents[selection].backgroundImage = UIImage(data: data) ?? UIImage()
                        } catch {
                            print("error when getting photo.")
                        }
                    default:
                        break
                    }
                } else {
                    do {
                        let data = try Data(contentsOf: urls[0])
                        if let image = UIImage(data: data) {
                            contentInfo.showContents[selection].video = URL(fileURLWithPath: "")
                            contentInfo.showContents[selection].image = image
                            contentInfo.showContents[selection].imageURL = urls[0]
                        } else {
                            contentInfo.showContents[selection].image = UIImage()
                            contentInfo.showContents[selection].imageURL = URL(fileURLWithPath: "")
                            contentInfo.showContents[selection].video = urls[0]
                        }
                    } catch {
                        print("Error when getting data from url.")
                    }
                    viewName = "MakingShowContentView"
                }
                
                urls.removeAll()
            }
        })
        .onChange(of: showFile, perform: { value in
            if value == false && urls.count == 0 {
                viewName = "MakingShowContentView"
            }
        })
        .sheet(isPresented: $showPhotoLibrary, content: {
            if viewName == "MakingShowContentView" {
                SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerImages)
            } else {
                PHPicker(filter: [.images, .videos], selectionLimit: 1, urls: $pickerurls, images: $pickerImages)
            }
        })
        .onChange(of: showPhotoLibrary, perform: { value in
            if value == false && pickerurls.count > 0 && UTType(filenameExtension: pickerurls[0].pathExtension)?.conforms(to: .movie) == true {
                contentInfo.showContents[selection].image = UIImage()
                contentInfo.showContents[selection].imageURL = URL(fileURLWithPath: "")
                contentInfo.showContents[selection].video = pickerurls[0]
                viewName = "MakingShowContentView"
            }
            
            if value == false && pickerImages.count > 0 {
                if viewName == "MakingShowContentView" {
                    contentInfo.showContents[selection].backgroundImage = pickerImages[0]
                } else {
                    if pickerurls.count > 0 {
                        contentInfo.showContents[selection].image = pickerImages[0]
                        contentInfo.showContents[selection].imageURL = pickerurls[0]
                        contentInfo.showContents[selection].video = URL(fileURLWithPath: "")
                        viewName = "MakingShowContentView"
                    }
                }
            }
            
            if value == false && pickerurls.count == 0 && pickerImages.count == 0 {
                viewName = "MakingShowContentView"
            }
            pickerurls.removeAll()
            pickerImages.removeAll()
        })
        .onChange(of: showImage, perform: { newValue in
            barHidden = newValue
        })
        .onChange(of: showVideo, perform: { newValue in
            barHidden = newValue
        })
        .ignoresSafeArea()
        .onWillAppear {
            name.name = "MakingShowContentView"
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if barHidden == false {
                    CustomBackButtonView()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if barHidden == false {
                    if showImage == false && showVideo == false {
                        Button(action: {
                            switch showPages {
                            case false:
                                showPages.toggle()
                                withAnimation(.linear(duration: 0.3)) {
                                    pageOpacity = 1.0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    hideContent = true
                                    showMenu = false
                                    showContentMenu = false
                                }
                            case true:
                                hideContent = false
                                
                                withAnimation(.linear(duration: 0.3)) {
                                    pageOpacity = 0.0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showPages.toggle()
                                }
                            }
                        }) {
                            Image(systemName: "rectangle.grid.1x2")
                                .foregroundColor(.white)
                                .card()
                        }
                        
                        if showPages == false {
                            Button(action: {
                                switch showMenu {
                                case false:
                                    showMenu = true
                                    menuType = "photo"
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        menuOpacity = 1.0
                                        menuPadding = 20.0
                                    }
                                case true:
                                    if menuType == "photo" {
                                        removeMenu()
                                    } else {
                                        removeMenu()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            showMenu = true
                                            menuType = "photo"
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                menuOpacity = 1.0
                                                menuPadding = 20.0
                                            }
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                                    .card()
                            }
                            
                            Button(action: {
                                switch showMenu {
                                case false:
                                    showMenu = true
                                    menuType = "music"
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        menuOpacity = 1.0
                                        menuPadding = 20.0
                                    }
                                case true:
                                    if menuType == "music" {
                                        removeMenu()
                                    } else {
                                        removeMenu()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            showMenu = true
                                            menuType = "music"
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                menuOpacity = 1.0
                                                menuPadding = 20.0
                                            }
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: "music.note")
                                    .foregroundColor(.white)
                                    .card()
                            }
                        }
                        
                        switch contentInfo.name {
                        case "":
                            Text("Preview")
                                .foregroundColor(.white.opacity(0.5))
                                .bold()
                                .card()
                        default:
                            NavigationLink(destination: ContentShowPreView(contentInfo: contentInfo, worldInfo: worldInfo, categoryIndex: categoryIndex, isPresent: $isPresent)) {
                                Text("Preview")
                                    .foregroundColor(.white)
                                    .bold()
                                    .card()
                            }
                            .simultaneousGesture(TapGesture().onEnded({ _ in
                                for i in 0..<contentInfo.showContents.count {
                                    if contentInfo.showContents[i].music != URL(fileURLWithPath: "") {
                                        if i > 0 && contentInfo.showContents[i].music == contentInfo.showContents[i - 1].music {
                                            contentInfo.showContents[i].musicData = Data()
                                        } else {
                                            do {
                                                contentInfo.showContents[i].musicData = try Data(contentsOf: contentInfo.showContents[i].music)
                                            } catch {
                                                print("Failed to get music data.")
                                            }
                                        }
                                    } else {
                                        contentInfo.showContents[i].musicData = String("nothing").data(using: .utf8) ?? Data()
                                    }
                                }
                            }))
                        }
                    }
                }
            }
        }
        .shadow(color: .clear, radius: 10, x: 0, y: 0)
    }
    
    func removeMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            menuOpacity = 0.0
            menuPadding = -20.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showMenu = false
            menuType = ""
        }
    }
}

//struct MakingShowContentView_Previews: PreviewProvider {
    //static var previews: some View {
        //MakingShowContentView()
    //}
//}

struct MakingShowAddContent: View {
    
    @ObservedObject var contentInfo: ContentInfo
    @Binding var i: Int
    @Binding var showContentMenu: Bool
    @Binding var showImage: Bool
    @Binding var showVideo: Bool
    var width: CGFloat = UIScreen.main.bounds.size.width
    
    var body: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: width - 40)
                    .frame(maxHeight: (width - 40)/5)
                
                HStack {
                    Button(action: {
                        showContentMenu = true
                    }) {
                        Text("Tap to Add Element")
                            .foregroundColor(.black)
                            .font(.system(size: 17, weight: .medium))
                            .frame(width: ((width - 40)*4/5) - 24, alignment: .leading)
                            .lineLimit(2)
                    }
                    
                    
                    Spacer()
                }
                .padding(.leading, 8)
                
                HStack {
                    Spacer()
                    
                    if contentInfo.showContents[i].image != UIImage() {
                        Button(action: {
                            showImage = true
                        }) {
                            Image(uiImage: contentInfo.showContents[i].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: ((width - 40)/5) - 16, height: ((width - 40)/5) - 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    if contentInfo.showContents[i].video != URL(fileURLWithPath: "") {
                        Button(action: {
                            showVideo = true
                        }) {
                            Image(uiImage: UIImage(cgImage: (captureImage(movieURL: contentInfo.showContents[i].video, capturingTime: CMTime.zero) ?? UIImage(named: "black2")!.cgImage!)))
                                .resizable()
                                .scaledToFill()
                                .frame(width: ((width - 40)/5) - 16, height: ((width - 40)/5) - 16)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.trailing, 8)
            }
            .cornerRadius(15)
            
            HStack {
                Button(action: {
                    contentInfo.showContents[i].image = UIImage()
                    contentInfo.showContents[i].video = URL(fileURLWithPath: "")
                }) {
                    Text("Remove Content")
                        .underline()
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .card()
                }
                
                Spacer()
            }
        }
    }
}

struct MakingShowPagesView: View {
    
    @ObservedObject var content: ContentInfo
    @State var removeBool = false
    @Binding var selection: Int
    @Binding var showPages: Bool
    @Binding var pageOpacity: Double
    @Binding var hideContent: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<content.showContents.count, id: \.self) { i in
                    VStack(spacing: 0) {
                        HStack {
                            if i > 0 {
                                Button(action: {
                                    removeContent(index: i)
                                }) {
                                    Image(systemName: "multiply")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .foregroundColor(.white)
                                        .card()
                                        .padding(.leading, 20)
                                }
                                
                                Spacer()
                                
                                switch i {
                                case 1:
                                    Button(action: {
                                        sortDown(i: i)
                                    }) {
                                        Image(systemName: "arrow.down")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(.white)
                                            .card()
                                            .padding(.trailing, 20)
                                    }
                                
                                case content.showContents.count - 1:
                                    Button(action: {
                                        sortUp(i: i)
                                    }) {
                                        Image(systemName: "arrow.up")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(.white)
                                            .card()
                                            .padding(.trailing, 20)
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
                                            .card()
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            selection = i
                            hideContent = false
                            
                            withAnimation(.linear(duration: 0.3)) {
                                pageOpacity = 0.0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showPages.toggle()
                            }
                        }) {
                            ZStack {
                                Image(uiImage: content.showContents[i].backgroundImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                    .contentShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                    .foregroundColor(.white.opacity(0.5))
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(content.showContents[i].title)
                                            .foregroundColor(.black)
                                            .font(.system(size: 20, weight: .semibold))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(1)
                                            .padding(.leading, 8)
                                        
                                        Spacer()
                                        
                                        Text(content.showContents[i].text)
                                            .foregroundColor(.black)
                                            .font(.system(size: 16, weight: .medium))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .padding(.leading, 8)
                                    }
                                    .padding([.top, .bottom], 8)
                                    
                                    Spacer()
                                    
                                    if content.showContents[i].image != UIImage() {
                                        Image(uiImage: content.showContents[i].image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/4 - 16, height: (UIScreen.main.bounds.size.width - 40)/4 - 16)
                                            .cornerRadius(10)
                                            .background(.clear)
                                            .padding([.top, .bottom, .trailing], 8)
                                    }
                                    
                                    if content.showContents[i].video != URL(fileURLWithPath: "") {
                                        Image(uiImage: UIImage(cgImage: (captureImage(movieURL: content.showContents[i].video, capturingTime: CMTime.zero)!)))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: (UIScreen.main.bounds.size.width - 40)/4 - 16, height: (UIScreen.main.bounds.size.width - 40)/4 - 16)
                                            .cornerRadius(10)
                                            .background(.clear)
                                            .padding([.top, .bottom, .trailing], 8)
                                    }
                                }
                            }
                            .cornerRadius(15)
                            .padding(.top, 10)
                        }
                    }
                    .opacity(content.showContents[i].opacity)
                    .padding(.bottom, content.showContents[i].bottomHeight)
                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
            .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 30)
        }
        .ignoresSafeArea()
        .background(.black)
    }
    
    func sortUp(i: Int) {
        removeBool = true
        
        if selection == i {
            selection -= 1
        } else if selection == i-1 {
            selection += 1
        }
        
        let content1 = content.showContents.remove(at: i-1)
        content.showContents.insert(content1, at: i)
        
        content.showContents[i].opacity = 0
        content.showContents[i-1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                content.showContents[i].opacity = 1
                content.showContents[i-1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func sortDown(i: Int) {
        removeBool = true
        
        if selection == i {
            selection += 1
        } else if selection == i+1 {
            selection -= 1
        }
        
        let content1 = content.showContents.remove(at: i)
        content.showContents.insert(content1, at: i+1)
        
        content.showContents[i].opacity = 0
        content.showContents[i+1].opacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                content.showContents[i].opacity = 1
                content.showContents[i+1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func removeContent(index: Int) {
        removeBool = true
        
        if selection == index {
            if selection == content.showContents.count - 1 {
                selection -= 1
            }
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            content.showContents[index].opacity = 0
            content.showContents[index].bottomHeight = -(content.showContents[index].height + 1000.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            content.showContents.remove(at: index)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            removeBool = false
        }
    }
}

struct MakingMenuView: View {
    
    var width: CGFloat = UIScreen.main.bounds.size.width - 40
    @Binding var menuType: String
    @Binding var showFile: Bool
    @Binding var showPhotoLibrary: Bool
    @Binding var cancelTapped: Bool
    @Binding var image: UIImage
    @Binding var aspectFit: Bool
    @Binding var musicURL: URL
    @Binding var loopPlay: Bool
    @Binding var viewName: String
    @State var backgroundSelection = 0
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                switch menuType {
                case "photo":
                    Rectangle()
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: width - 40, height: 275)
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                cancelTapped = true
                            }) {
                                Text("Done")
                                    .foregroundColor(.black)
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .padding(.bottom, 10)
                            .padding(.trailing, 0)
                            .padding(.top, 5)
                        }
                        
                        VStack(spacing: 1) {
                            ForEach(0..<2, id: \.self) { i in
                                Button(action: {
                                    if viewName == "MakingScrollContentView" {
                                        viewName = "MakingScrollContentViewSetting"
                                    }
                                    
                                    if i == 0 {
                                        showPhotoLibrary.toggle()
                                    } else {
                                        showFile.toggle()
                                    }
                                }) {
                                    ZStack() {
                                        Rectangle()
                                            .foregroundColor(.black.opacity(0.7))
                                            .frame(width: width - 60, height: 48)
                                        
                                        HStack {
                                            switch i {
                                            case 0:
                                                Text("Select from Photo Library")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .lineLimit(1)
                                                    .padding(.leading, 8)
                                                
                                            default:
                                                Text("Select from File")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .lineLimit(1)
                                                    .padding(.leading, 8)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .cornerRadius(15)
                        
                        Button(action: {
                            image = UIImage(named: "black") ?? UIImage()
                        }) {
                            Text("Clear Background Image")
                                .underline()
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        Text("Display Setting")
                            .foregroundColor(.black)
                            .font(.system(size: 17, weight: .semibold))
                        
                        Picker("Background Style", selection: $backgroundSelection) {
                            ForEach(0..<2, id: \.self) { i in
                                switch i {
                                case 0:
                                    Text("Aspect Fit")
                                        .lineLimit(1)
                                        .tag(i)
                                    
                                default:
                                    Text("Aspect Fill")
                                        .lineLimit(1)
                                        .tag(i)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(.black.opacity(0.7))
                        .frame(width: width - 60)
                        .cornerRadius(8)
                        .padding(.top, 10)
                        .onChange(of: backgroundSelection) { newValue in
                            if backgroundSelection == 0 {
                                aspectFit = true
                            } else {
                                aspectFit = false
                            }
                        }
                    }
                    .frame(height: 255)
                    .padding(10)
                    
                default:
                    Rectangle()
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: width - 40, height: 205)
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                cancelTapped = true
                            }) {
                                Text("Done")
                                    .foregroundColor(.black)
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .padding(.bottom, 10)
                            .padding(.trailing, 0)
                            .padding(.top, 5)
                        }
                        
                        Group {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: width - 60, height: 64)
                                    .cornerRadius(15)
                                
                                HStack {
                                    Button(action: {
                                        if music.listIndex != -1 {
                                            playAudio.playAudio(url: musicURL, muteBool: false, loop: false)
                                            music.musicMuteBool = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                music.musicMuteBool = false
                                                music.pauseBool = false
                                            }
                                        } else {
                                            if music.musicURL != musicURL {
                                                playAudio.playAudio(url: musicURL, muteBool: false, loop: false)
                                            }
                                            music.pauseBool.toggle()
                                            music.musicMuteBool = false
                                        }
                                        
                                        music.musicURL = musicURL
                                        music.musicLoop = false
                                        music.listPressed = false
                                        music.listIndex = -1
                                    }) {
                                        if music.pauseBool || music.listIndex != -1 {
                                            Image(systemName: "play.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.white)
                                                .padding(.leading, 8)
                                        } else {
                                            Image(systemName: "pause.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32, height: 32)
                                                .foregroundColor(.white)
                                                .padding(.leading, 8)
                                        }
                                    }
                                    
                                    Button(action: {
                                        if viewName == "MakingScrollContentView" {
                                            viewName = "MakingScrollContentViewSetting"
                                        }
                                        showFile.toggle()
                                    }) {
                                        HStack {
                                            switch musicURL {
                                            case URL(fileURLWithPath: ""):
                                                Text("Select BGM")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .lineLimit(2)
                                                    .padding(.leading, 16)
                                                    .padding(.trailing, 8)
                                            default:
                                                Text(musicURL.lastPathComponent)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .lineLimit(2)
                                                    .padding(.leading, 16)
                                                    .padding(.trailing, 8)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .frame(height: 64)
                                }
                            }
                            .onChange(of: music.finished) { newValue in
                                if newValue {
                                    music.pauseBool = true
                                    music.musicMuteBool = true
                                }
                            }
                            
                            Button(action: {
                                musicURL = URL(fileURLWithPath: "")
                                if music.listIndex == -1 {
                                    music.pauseBool = true
                                    music.musicMuteBool = true
                                }
                            }) {
                                Text("Clear BGM")
                                    .underline()
                                    .foregroundColor(.black)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Text("Loop Playback")
                                .foregroundColor(.black)
                                .font(.system(size: 17, weight: .semibold))
                            
                            Spacer()
                            
                            Toggle(isOn: $loopPlay) {
                                
                            }
                            .tint(.black)
                        }
                    }
                    .frame(height: 185)
                    .padding(10)
                }
            }
        }
        .onAppear {
            if aspectFit == false {
                backgroundSelection = 1
            }
        }
    }
}
