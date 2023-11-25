//
//  MakingScrollContentView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/13.
//

import SwiftUI
import CoreMedia
import AVFoundation
import AVKit

struct MakingScrollContentView: View {
    
    @StateObject var contentInfo: ContentInfo
    @ObservedObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @Binding var isPresent: Bool
    
    var body: some View {
        EditScrollContentSubView(contentInfo: contentInfo, worldInfo: worldInfo, categoryIndex: categoryIndex, isPresent: $isPresent)
    }
}

//struct MakingScrollContentView_Previews: PreviewProvider {
    //static var previews: some View {
        //MakingScrollContentView()
    //}
//}

struct EditScrollContentSubView: View {
    
    @State var thisName = "MakingScrollContentView"
    @State var addBool = false
    @State var photoLibraryShow = false
    @State var imagePickerShow = false
    @State var fileShow = false
    @State var fileMultiple = false
    @State var fileType = ""
    @State var appendBool = false
    @State var listIndex = 0
    @State var goWeb = false
    @State var checkWeb = false
    @State var bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
    @State var imageArray = [UIImage]()
    @State var removeBool = false
    @State var addButtonHidden = false
    @State var showMenu = false
    @State var menuCancelTapped = false
    @State var choosePhotoSource = false
    @State var chooseVideoSource = false
    @State var contentIndexChanged = false
    @State var menuType = ""
    @State var menuOpacity = 0.0
    @State var menuPadding = -20.0
    @State var settingMenuOpacity = 0.0
    @State var settingMenuPadding = -20.0
    @State var nullSelection = 0
    @State var fileurls = [URL]()
    @State var pickerImages = [UIImage]()
    @State var pickerurls = [URL]()
    @ObservedObject var contentInfo: ContentInfo
    @ObservedObject var worldInfo: WorldInfo = WorldInfo()
    var categoryIndex: Int?
    @Binding var isPresent: Bool
    @EnvironmentObject var name: Name
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var music: Music
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { _ in
                ContentBackgroundImage(image: contentInfo.backgroundImage, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, opacity: 0.25, aspectFit: contentInfo.backgroundAspectFit)
            
                ScrollViewReader { reader in
                    ScrollView {
                        VStack(spacing: 0) {
                            if contentInfo.scrollContents.count > 0 {
                                ForEach(0..<contentInfo.scrollContents.count, id: \.self) { i in
                                    VStack(spacing: 0) {
                                        HStack {
                                            Button(action: {
                                                if contentInfo.scrollContents[i].type == "music" {
                                                    music.musicMuteBool = true
                                                    music.pauseBool = true
                                                    music.finished = true
                                                    music.musicURL = URL(fileURLWithPath: "")
                                                }
                                                
                                                removeContent(index: i)
                                            }) {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 17, height: 17)
                                                    .foregroundColor(.white)
                                                    .opacity(contentInfo.scrollContents[i].opacity)
                                                    .card()
                                                    .padding(.leading, 20)
                                            }
                                            
                                            Spacer()
                                            
                                            if contentInfo.scrollContents.count > 1 {
                                                switch i {
                                                case 0:
                                                    Button(action: {
                                                        contentIndexChangedFunc()
                                                        sortDown(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.down")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.scrollContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                
                                                case contentInfo.scrollContents.count - 1:
                                                    Button(action: {
                                                        contentIndexChangedFunc()
                                                        sortUp(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.up")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.scrollContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                    
                                                default:
                                                    Button(action: {
                                                        contentIndexChangedFunc()
                                                        sortUp(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.up")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.scrollContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                    
                                                    Button(action: {
                                                        contentIndexChangedFunc()
                                                        sortDown(i: i)
                                                    }) {
                                                        Image(systemName: "arrow.down")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundColor(.white)
                                                            .opacity(contentInfo.scrollContents[i].opacity)
                                                            .card()
                                                            .padding(.trailing, 20)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                        .padding(.bottom, contentInfo.scrollContents[i].bottomHeight/2)
                                        
                                        MakingScrollSubView(content: $contentInfo.scrollContents[i], bottomHeight: $bottomHeight, checkWeb: $checkWeb, showFile: $fileShow, listIndex: $listIndex, appendBool: $appendBool, indexChangedBool: $contentIndexChanged, contents: contentInfo)
                                    }
                                }
                            }
                            
                            if addButtonHidden == false {
                                Button(action: {
                                    if addBool == false {
                                        addBool = true
                                    } else {
                                        removeMenu()
                                    }
                                }) {
                                    Text("+Add Element")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                        .padding([.top, .bottom], 3)
                                        .padding([.leading, .trailing], 10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                        .card()
                                        .padding(.top, 10)
                                }
                            }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.size.width, height: bottomHeight)
                                .foregroundColor(.clear)
                                .id(contentInfo.scrollContents.count)
                        }
                        .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + 40)
                    }
                    .onChange(of: contentInfo.scrollContents.count) { count in
                        if removeBool != true {
                            withAnimation(.easeOut(duration: 0.15)) {
                                reader.scrollTo(count)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            }
            
            if addBool == true {
                MakingScrollAddMenu(contents: contentInfo, menuOpacity: $menuOpacity, menuPadding: $menuPadding, fileShow: $fileShow, photoLibraryShow: $photoLibraryShow, fileType: $fileType, goWeb: $goWeb, fileMultiple: $fileMultiple, addBool: $addBool)
            }
            
            if showMenu {
                MakingMenuView(width: UIScreen.main.bounds.size.width, menuType: $menuType, showFile: $fileShow, showPhotoLibrary: $imagePickerShow, cancelTapped: $menuCancelTapped, image: $contentInfo.backgroundImage, aspectFit: $contentInfo.backgroundAspectFit, musicURL: $contentInfo.music, loopPlay: $contentInfo.loopPlay, viewName: $thisName)
                    .opacity(settingMenuOpacity)
                    .padding(.bottom, settingMenuPadding)
                    .padding([.leading, .trailing], 20)
                    .gesture(DragGesture(coordinateSpace: .global).onEnded({ value in
                        if value.translation.height > 30 {
                            removeSettingMenu()
                        }
                     }))
                    .onChange(of: menuCancelTapped) { newValue in
                        if newValue {
                            removeSettingMenu()
                            menuCancelTapped = false
                        }
                    }
            }
            
            GradientNavigationBar()
        }
        .background(.black)
        .customBackButton()
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    switch showMenu {
                    case false:
                        showMenu = true
                        menuType = "photo"
                        withAnimation(.easeOut(duration: 0.2)) {
                            settingMenuOpacity = 1.0
                            settingMenuPadding = 20.0
                        }
                    case true:
                        if menuType == "photo" {
                            removeSettingMenu()
                        } else {
                            removeSettingMenu()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showMenu = true
                                menuType = "photo"
                                withAnimation(.easeOut(duration: 0.2)) {
                                    settingMenuOpacity = 1.0
                                    settingMenuPadding = 20.0
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
                            settingMenuOpacity = 1.0
                            settingMenuPadding = 20.0
                        }
                    case true:
                        if menuType == "music" {
                            removeSettingMenu()
                        } else {
                            removeSettingMenu()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showMenu = true
                                menuType = "music"
                                withAnimation(.easeOut(duration: 0.2)) {
                                    settingMenuOpacity = 1.0
                                    settingMenuPadding = 20.0
                                }
                            }
                        }
                    }
                }) {
                    Image(systemName: "music.note")
                        .foregroundColor(.white)
                        .card()
                }
                
                NavigationLink(destination: ContentScrollPreView(worldInfo: worldInfo, categoryIndex: categoryIndex, contentInfo: contentInfo, isPresent: $isPresent)) {
                    Text("Preview")
                        .foregroundColor(.white)
                        .bold()
                        .card()
                }
            }
        }
        .onChange(of: goWeb, perform: { value in
            if value == false && webViewVar.nowURL != "" {
                contentInfo.scrollContents.append(ScrollContent(type: "link", content: webViewVar.title, height: CGFloat(0), image: webViewVar.image, opacity: 1.0, bottomHeight: 10, url: webViewVar.nowURL))
                
                webViewVar.nowURL = ""
                webViewVar.title = ""
                webViewVar.image = UIImage()
                webViewVar.goB = false
                webViewVar.goF = false
            }
        })
        .onWillAppear {
            DispatchQueue.main.async {
                name.name = "MakingScrollContentView"
            }
            
            for i in 0..<contentInfo.scrollContents.count {
                if contentInfo.scrollContents[i].type == "title" || contentInfo.scrollContents[i].type == "text" {
                    let text = contentInfo.scrollContents[i].content
                    contentInfo.scrollContents[i].content = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        contentInfo.scrollContents[i].content = text
                    }
                }
            }
        }
        .sheet(isPresented: $photoLibraryShow) {
            if fileType == "video" {
                SingleImagePicker(mediaTypes: ["public.movie"], urls: $pickerurls, images: $pickerImages)
            } else {
                PHPicker(urls: $pickerurls, images: $pickerImages)
            }
        }
        .sheet(isPresented: $imagePickerShow) {
            SingleImagePicker(mediaTypes: ["public.image"], urls: $pickerurls, images: $pickerImages)
        }
        .onChange(of: imagePickerShow, perform: { value in
            if value == false && pickerImages.count > 0 {
                contentInfo.backgroundImage = pickerImages[0]
                thisName = "MakingScrollContentView"
                pickerImages.removeAll()
                pickerurls.removeAll()
            }
        })
        .onChange(of: photoLibraryShow, perform: { value in
            if value == false && pickerurls.count > 0 {
                if UTType(filenameExtension: pickerurls[0].pathExtension)?.conforms(to: .movie) == true {
                    contentInfo.scrollContents.append(ScrollContent(type: "video", opacity: 1.0, bottomHeight: 10, url: pickerurls[0].absoluteString, videoURL: pickerurls[0], index: contentInfo.scrollContents.count))
                }
            }
            
            if value == false && pickerImages.count > 0 {
                for (index, i) in pickerImages.enumerated() {
                    if index < pickerurls.count {
                        contentInfo.scrollContents.append(ScrollContent(type: "image", height: i.size.height*(UIScreen.main.bounds.size.width - 40)/i.size.width, image: pickerImages[index], opacity: 1.0, bottomHeight: 10, imageURL: pickerurls[index], index: contentInfo.scrollContents.count))
                    }
                }
            }
            
            pickerImages.removeAll()
            pickerurls.removeAll()
        })
        .sheet(isPresented: $fileShow) {
            if thisName == "MakingScrollContentViewSetting" {
                FileView(multipleSelection: false, fileType: menuType, urls: $fileurls)
            } else {
                FileView(multipleSelection: fileMultiple, fileType: fileType, urls: $fileurls)
            }
        }
        .onChange(of: fileurls.count, perform: { count in
            if count > 0 {
                if thisName == "MakingScrollContentViewSetting" {
                    if menuType == "photo" {
                        do {
                            let data = try Data(contentsOf: fileurls[0])
                            if let image = UIImage(data: data) {
                                contentInfo.backgroundImage = image
                            }
                        } catch {
                            print("Failed to get image.")
                        }
                    } else {
                        contentInfo.music = fileurls[0]
                    }
                    thisName = "MakingScrollContentView"
                } else {
                    if fileType == "music" {
                        if appendBool {
                            for i in 0..<fileurls.count {
                                contentInfo.scrollContents[listIndex].music.append(fileurls[i])
                                contentInfo.scrollContents[listIndex].musicName.append(fixFileName(string: fileurls[i].lastPathComponent, format: ".mp3"))
                            }
                        } else {
                            var contentNames = [String]()
                            for i in fileurls {
                                contentNames.append(fixFileName(string: i.lastPathComponent, format: ".mp3"))
                            }
                            
                            contentInfo.scrollContents.append(ScrollContent(type: "music", content: "", height: CGFloat(0), image: UIImage(), opacity: 1.0, bottomHeight: 10, music: fileurls, musicName: contentNames, index: contentInfo.scrollContents.count))
                        }
                    } else {
                        for i in 0..<fileurls.count {
                            if fileType == "video" {
                                contentInfo.scrollContents.append(ScrollContent(type: "video", content: fileurls[i].lastPathComponent, height: CGFloat(0), image: UIImage(), opacity: 1.0, bottomHeight: 10, url: fileurls[i].absoluteString, videoURL: fileurls[i], index: contentInfo.scrollContents.count))
                            } else if fileType == "photo" {
                                do {
                                    let data = try Data(contentsOf: fileurls[i])
                                    let image = UIImage(data: data) ?? UIImage()
                                    contentInfo.scrollContents.append(ScrollContent(type: "image", height: image.size.height*(UIScreen.main.bounds.size.width - 40)/image.size.width, image: image, opacity: 1.0, bottomHeight: 10, imageURL: fileurls[i], index: contentInfo.scrollContents.count))
                                } catch {
                                    print("Failed to get image.")
                                }
                            }
                        }
                    }
                }
                fileurls.removeAll()
            }
        })
        .onChange(of: fileShow, perform: { value in
            if value == false && fileurls.count == 0 {
                thisName = "MakingScrollContentView"
            }
        })
        .onChange(of: fileShow, perform: { value in
            if value == false {
                appendBool = false
            }
        })
        .fullScreenCover(isPresented: $goWeb) {
            WebView(viewName: "MakingScrollContentView", addBool: true, showWebView: ShowWebView(url: "https://google.com"))
        }
        .fullScreenCover(isPresented: $checkWeb) {
            WebView(viewName: "MakingScrollContentView", addBool: false, showWebView: ShowWebView(url: webViewVar.nowURL))
        }
    }
    
    func fixFileName(string: String, format: String) -> String {
        var title = string
        
        if let component = title.range(of: format) {
            title.replaceSubrange(component, with: "")
        }
        
        return title
    }
    
    func contentIndexChangedFunc() {
        contentIndexChanged = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            contentIndexChanged = false
        }
    }
    
    func removeSettingMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            settingMenuOpacity = 0.0
            settingMenuPadding = -20.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showMenu = false
            menuType = ""
        }
    }
    
    func sortUp(i: Int) {
        removeBool = true
        
        let content = contentInfo.scrollContents.remove(at: i-1)
        contentInfo.scrollContents.insert(content, at: i)
        
        contentInfo.scrollContents[i].opacity = 0
        contentInfo.scrollContents[i].index = i
        contentInfo.scrollContents[i-1].opacity = 0
        contentInfo.scrollContents[i-1].index = i - 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                contentInfo.scrollContents[i].opacity = 1
                contentInfo.scrollContents[i-1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func sortDown(i: Int) {
        removeBool = true
        
        let content = contentInfo.scrollContents.remove(at: i)
        contentInfo.scrollContents.insert(content, at: i+1)
        
        contentInfo.scrollContents[i].opacity = 0
        contentInfo.scrollContents[i].index = i
        contentInfo.scrollContents[i+1].opacity = 0
        contentInfo.scrollContents[i+1].index = i + 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.linear(duration: 0.3)) {
                contentInfo.scrollContents[i].opacity = 1
                contentInfo.scrollContents[i+1].opacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeBool = false
        }
    }
    
    func removeContent(index: Int) {
        removeBool = true
        withAnimation(.easeOut(duration: 0.3)) {
            contentInfo.scrollContents[index].opacity = 0
            contentInfo.scrollContents[index].bottomHeight = -(contentInfo.scrollContents[index].height + 1000.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            contentInfo.scrollContents.remove(at: index)
            contentIndexChangedFunc()
            for i in 0..<contentInfo.scrollContents.count {
                contentInfo.scrollContents[i].index = i
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            removeBool = false
        }
    }
   
    func removeMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            menuOpacity = 0.0
            menuPadding = -20.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            addBool = false
        }
    }
}

struct MakingScrollAddMenu: View {
    
    var menuArray: [(image: String, title: String)] = [("character", NSLocalizedString("Title", comment: "")), ("doc.plaintext", NSLocalizedString("Text", comment: "")), ("photo", NSLocalizedString("Image", comment: "")), ("music.note", NSLocalizedString("Audio", comment: "")), ("play.square", NSLocalizedString("Video", comment: "")), ("link", NSLocalizedString("Link", comment: ""))]
    @StateObject var contents: ContentInfo
    @State var choosePhotoSource = false
    @State var chooseVideoSource = false
    @State var menuHeight = CGFloat(348)
    @State var photoMenuHeight = CGFloat(0)
    @State var videoMenuHeight = CGFloat(0)
    @Binding var menuOpacity: Double
    @Binding var menuPadding: Double
    @Binding var fileShow: Bool
    @Binding var photoLibraryShow: Bool
    @Binding var fileType: String
    @Binding var goWeb: Bool
    @Binding var fileMultiple: Bool
    @Binding var addBool: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .frame(width: UIScreen.main.bounds.size.width - 40, height: menuHeight)
                .foregroundColor(.white.opacity(0.7))
                .cornerRadius(20)
            
            VStack(alignment: .trailing, spacing: 0) {
                Button(action: {
                    removeMenu()
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .medium))
                }
                .padding(.trailing, 0)
                .padding(.bottom, 10)
                
                VStack(spacing: 1) {
                    ForEach(0..<menuArray.count, id: \.self) { i in
                        Button(action: {
                            switch i {
                            case 0:
                                contents.scrollContents.append(ScrollContent(type: "title", content: "", height: CGFloat(45), image: UIImage(), opacity: 1.0, bottomHeight: 10.0, url: "", music: [], index: contents.scrollContents.count))
                                removeMenu()
                            case 1:
                                contents.scrollContents.append(ScrollContent(type: "text", content: "", height: CGFloat(80), image: UIImage(), opacity: 1.0, bottomHeight: 10.0, url: "", music: [], index: contents.scrollContents.count))
                                removeMenu()
                            case 2:
                                if choosePhotoSource == false {
                                    choosePhotoSource.toggle()
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        photoMenuHeight = 80
                                        menuHeight += photoMenuHeight
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        photoMenuHeight = 0
                                        menuHeight -= 80
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        choosePhotoSource.toggle()
                                    }
                                }
                            case 3:
                                fileMultiple = true
                                fileType = "music"
                                fileShow.toggle()
                                removeMenu()
                            case 4:
                                if chooseVideoSource == false {
                                    chooseVideoSource.toggle()
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        videoMenuHeight = 80
                                        menuHeight += videoMenuHeight
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        videoMenuHeight = 0
                                        menuHeight -= 80
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        chooseVideoSource.toggle()
                                    }
                                }
                            default:
                                goWeb.toggle()
                                removeMenu()
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 48)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                HStack {
                                    Text(menuArray[i].title)
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .medium))
                                        .padding(.leading, 20)
                                    
                                    Spacer()
                                    
                                    Image(systemName: menuArray[i].image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 20)
                                }
                            }
                        }
                        
                        if choosePhotoSource && i == 2 {
                            HStack {
                                VStack(alignment: .leading, spacing: 20) {
                                    Button(action: {
                                        fileType = "photo"
                                        photoLibraryShow.toggle()
                                        removeMenu()
                                    }) {
                                        Text("Select from Photo Library")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    Button(action: {
                                        fileType = "photo"
                                        fileShow.toggle()
                                        removeMenu()
                                    }) {
                                        Text("Select from File")
                                            .foregroundColor(.white)
                                            .font(.system(size: 17, weight: .medium))
                                    }
                                }
                                .padding(.leading, 40)
                                
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: photoMenuHeight)
                            .background(.black.opacity(0.7))
                            .padding(.top, -1)
                        }
                        
                        if chooseVideoSource && i == 4 {
                            HStack {
                                VStack(alignment: .leading, spacing: 20) {
                                    Button(action: {
                                        fileType = "video"
                                        photoLibraryShow.toggle()
                                        removeMenu()
                                    }) {
                                        Text("Select from Photo Library")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    Button(action: {
                                        fileMultiple = false
                                        fileType = "video"
                                        fileShow.toggle()
                                        removeMenu()
                                    }) {
                                        Text("Select from File")
                                            .foregroundColor(.white)
                                            .font(.system(size: 17, weight: .medium))
                                    }
                                }
                                .padding(.leading, 40)
                                
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40, height: videoMenuHeight)
                            .background(.black.opacity(0.7))
                            .padding(.top, -1)
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 60)
                .cornerRadius(10)
            }
            .padding(.bottom, 10)
        }
        .opacity(menuOpacity)
        .padding(.bottom, menuPadding)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                menuOpacity = 1.0
                menuPadding = 20.0
            }
        }
        .gesture(DragGesture(coordinateSpace: .global).onEnded({ value in
            if value.translation.height > 30 {
                removeMenu()
            }
         }))
    }
    
    func removeMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            menuOpacity = 0.0
            menuPadding = -20.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            addBool = false
        }
    }
}

struct MakingScrollSubView: View {
    
    @Binding var content: ScrollContent
    @Binding var bottomHeight: CGFloat
    @Binding var checkWeb: Bool
    @Binding var showFile: Bool
    @Binding var listIndex: Int
    @Binding var appendBool: Bool
    @Binding var indexChangedBool: Bool
    @StateObject var contents: ContentInfo
    @EnvironmentObject var webViewVar: WebViewVaridates
    @EnvironmentObject var music: Music
    @EnvironmentObject var playAudio: PlayMusic
    @State var nowPlaying = 0
    
    var body: some View {
        switch content.type {
        case "title":
            ContentTextingView(text: $content.content, height: $content.height, viewBottomHeight: $bottomHeight, originalHeight: 45, fontSize: 24, fontWeight: .semibold, textAlignment: .center, placeholder: NSLocalizedString("Title", comment: ""))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .padding([.leading, .trailing], 20)
                .padding(.top, 10)
                .padding(.bottom, content.bottomHeight)
        case "text":
            ContentTextingView(text: $content.content, height: $content.height, viewBottomHeight: $bottomHeight)
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .padding(.top, 10)
                .padding(.bottom, content.bottomHeight)
        case "image":
            Image(uiImage: content.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.size.width - 40, height: content.height)
                .opacity(content.opacity)
                .cornerRadius(20)
                .card()
                .padding(.top, 10)
                .padding(.bottom, content.bottomHeight)
                .onWillAppear {
                    content.height = (UIScreen.main.bounds.size.width - 40) * content.image.size.height / content.image.size.width
                }
        case "music":
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: 45 * CGFloat(content.music.count))
                        .foregroundColor(.white.opacity(0.7))
                        .cornerRadius(15)
                    
                    HStack(alignment: .top, spacing: 0) {
                        Button(action: {
                            if music.listIndex != contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                                playAudio.playAudio(url: content.music[nowPlaying], muteBool: false, loop: false)
                                music.musicMuteBool = true
                                nowPlaying = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    music.musicMuteBool = false
                                    music.pauseBool = false
                                }
                            } else {
                                if music.musicURL != content.music[nowPlaying] {
                                    playAudio.playAudio(url: content.music[nowPlaying], muteBool: false, loop: false)
                                }
                                music.musicMuteBool = false
                                music.pauseBool.toggle()
                            }
                            
                            music.musicURL = content.music[nowPlaying]
                            music.musicLoop = false
                            music.finished = false
                            music.listIndex = contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0
                        }) {
                            if music.pauseBool || music.listIndex != contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                                Image(systemName:"play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.black)
                                    .padding([.leading, .trailing], 8)
                                    .padding(.top, 8)
                            } else {
                                Image(systemName:"pause.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.black)
                                    .padding([.leading, .trailing], 8)
                                    .padding(.top, 8)
                            }
                        }
                        
                        List {
                            ForEach(0..<content.music.count, id: \.self) { i in
                                HStack {
                                    Text(content.musicName[i])
                                        .foregroundColor(.black)
                                        .font(.system(size: 16, weight: .medium))
                                        .lineLimit(1)
                                        .gesture(TapGesture().onEnded({ _ in
                                            playAudio.playAudio(url: content.music[i], muteBool: false, loop: false)
                                            music.musicURL = content.music[i]
                                            music.musicLoop = false
                                            music.musicMuteBool = false
                                            music.pauseBool = false
                                            music.finished = false
                                            self.nowPlaying = i
                                            music.listPressed = true
                                            music.listIndex = contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                music.listPressed = false
                                            }
                                        }))
                                }
                                .listRowBackground(Color.clear)
                                .padding([.leading, .trailing], 0)
                            }
                            .onMove(perform: moveRow(from:to:))
                            .onDelete(perform: deleteRow(offsets:))
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 88, height: 45 * CGFloat(content.music.count))
                        .listStyle(.plain)
                        .environment(\.editMode, .constant(.active))
                        .background(.clear)
                    }
                    .padding([.leading, .trailing], 0)
                }
                .cornerRadius(15)
                .padding([.leading, .trailing], 20)
                
                Button(action: {
                    appendBool = true
                    listIndex = contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0
                    showFile.toggle()
                }) {
                    Text("Add Audio")
                        .underline()
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .card()
                }
                .padding(.top, 10)
            }
            .opacity(content.opacity)
            .padding(.top, 10)
            .padding(.bottom, content.bottomHeight)
            .onChange(of: content.music.count) { value in
                if self.nowPlaying == content.music.count {
                    self.nowPlaying -= 1
                }
                
                if value == 0 {
                    if let index = contents.scrollContents.firstIndex(where: { $0 == content } ) {
                        contents.scrollContents.remove(at: index)
                    }
                }
            }
            .onChange(of: music.finished) { newValue in
                if newValue == true && music.listIndex == contents.scrollContents.firstIndex(where: { $0 == content } ) ?? 0 {
                    if self.nowPlaying < content.music.count - 1 {
                        playAudio.playAudio(url: content.music[self.nowPlaying + 1], muteBool: false, loop: false)
                        music.listPressed = true
                        music.musicURL = content.music[self.nowPlaying + 1]
                        music.musicMuteBool = false
                        music.pauseBool = false
                        music.finished = false
                        music.musicLoop = false
                        self.nowPlaying += 1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            music.listPressed = false
                        }
                    } else {
                        self.nowPlaying = 0
                        music.pauseBool = true
                        music.musicMuteBool = true
                        music.musicURL = URL(fileURLWithPath: "")
                    }
                }
            }
        case "video":
            PlayVideoView(url: content.videoURL, didChange: $indexChangedBool)
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)*9/16)
                .opacity(content.opacity)
                .cornerRadius(20)
                .shadow(color: .black, radius: 15, x: 0, y: 0)
                .padding(.top, 10)
                .padding(.bottom, content.bottomHeight)
        default:
            Button(action: {
                webViewVar.nowURL = content.url
                checkWeb = true
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
                        .cornerRadius(15)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(content.content)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(content.url)
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .regular))
                                .lineLimit(1)
                        }
                        .padding([.top, .bottom], 8)
                        
                        Spacer()
                        
                        Image(uiImage: content.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.size.width - 40)/5 - 16, height: (UIScreen.main.bounds.size.width - 40)/5 - 16)
                            .cornerRadius(10)
                    }
                    .padding([.leading, .trailing], 8)
                }
            }
            .opacity(content.opacity)
            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
            .padding(.top, 10)
            .padding(.bottom, content.bottomHeight)
        }
    }
    
    private func moveRow(from source: IndexSet, to destination: Int) {
        content.music.move(fromOffsets: source, toOffset: destination)
        content.musicName.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteRow(offsets: IndexSet) {
        content.music.remove(atOffsets: offsets)
        content.musicName.remove(atOffsets: offsets)
        
        if offsets.first == nowPlaying {
            music.musicMuteBool = true
            music.pauseBool = true
            music.finished = true
            music.musicURL = URL(fileURLWithPath: "")
        }
    }
}
