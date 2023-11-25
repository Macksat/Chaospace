//
//  UnuseFeatures.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/04/17.
//

import SwiftUI
import UIKit
import Combine
import Photos
import PhotosUI
import FirebaseAuth
import FirebaseAuthUI
import RealmSwift
import FirebaseOAuthUI
import FirebaseGoogleAuthUI

var photoAssets: [(asset: PHAsset, index: Int)] = []

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        PHPhotoLibrary.requestAuthorization() { result in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            context.coordinator.trackCompletion(in: controller)
            
            photoAssets.removeAll()
            DispatchQueue.global().async {
                let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: nil)
                assets.enumerateObjects({ (asset, index, stop) -> Void in
                    autoreleasepool {
                        let element = (asset, index)
                        photoAssets.append(element)
                    }
                })
            }
            UserDefaults.standard.set(true, forKey: "showPhotos")
        }
        
        return controller
    }
    
    func makeCoordinator() -> PhotoPicker.Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject {
        
        private var isPresented: Binding<Bool>
        
        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }
        
        func trackCompletion(in controller: UIViewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak controller] in
                if controller?.presentedViewController == nil {
                    self?.isPresented.wrappedValue = true
                } else if let controller = controller {
                    self?.trackCompletion(in: controller)
                }
            }
        }
    }
}

struct PhotoLibrary: View {
    
    let options = PHImageRequestOptions()
    let imageManager = PHImageManager()
    @Environment(\.dismiss) var dismiss
    //@EnvironmentObject var articleArray: ArticleContentArray
    @State var imageArray = [Int]()
    @State var selectedPhotos = [UIImage]()
    @Binding var viewName: String
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(minimum: 40), spacing: 2, alignment: .top), GridItem(.flexible(minimum: 40), spacing: 2, alignment: .top), GridItem(.flexible(minimum: 40), spacing: 2, alignment: .top)], alignment: .center, spacing: 2) {
                    if photoAssets.count > 0 {
                        ForEach(Array(photoAssets.enumerated()), id: \.offset) { i, content in
                            Button(action:  {
                                var exsistBool = false
                                for (j, imageContent) in imageArray.enumerated() {
                                    if photoAssets[photoAssets.count - 1 - i].index == imageContent {
                                        imageArray.remove(at: j)
                                        exsistBool = true
                                    }
                                }
                                
                                if exsistBool == false {
                                    imageArray.append(photoAssets[photoAssets.count - 1 - i].index)
                                }
                            }) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(uiImage: prepareImage(index: photoAssets.count - 1 - i))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.size.width/3 - 1.5, height: UIScreen.main.bounds.size.width/3 - 1.5)
                                        .clipped()
                                    
                                    ForEach(imageArray, id: \.self) { j in
                                        if photoAssets[photoAssets.count - 1 - i].index == j {
                                            Rectangle()
                                                .frame(width: UIScreen.main.bounds.size.width/3 - 1.5, height: UIScreen.main.bounds.size.width/3 - 1.5)
                                                .foregroundColor(.white.opacity(0.5))
                                            
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.black)
                                                .card()
                                                .padding([.bottom, .trailing], 5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                options.isNetworkAccessAllowed = true
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
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
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        if imageArray.count > 0 {
                            //let formatter = DateFormatter()
                            //formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            //let date = formatter.string(from: Date())
                            let options = PHImageRequestOptions()
                            options.isNetworkAccessAllowed = true
                            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                            
                            autoreleasepool {
                                for i in imageArray {
                                    let element = photoAssets.filter { $0.index == i }.first!
                                    imageManager.requestImage(for: element.asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { image, info in
                                        self.selectedPhotos.append(image ?? UIImage())
                                        
                                        if selectedPhotos.count == imageArray.count {
                                            //if viewName == "ChatView" {
                                                //chatArray.chats.append(Chat(id: "", name: "userName", content: "", images: selectedPhotos, date: date))
                                            if viewName == "CreateArticleView" {
                                                //articleArray.content.append(ArticleContent(type: "image", content: "", height: CGFloat(0), imageData: image ?? UIImage(), opacity: 1.0, buttonHeight: 17, webTitle: "", index: articleArray.content.count))
                                            }
                                        }
                                    }
                                }
                            }
                            
                            dismiss()
                        }
                    }) {
                        if imageArray.count > 0 {
                            Text("Add")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .card()
                        } else {
                            Text("Add")
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .background(Color(red: 0.3, green: 0.3, blue: 0.3))
            
            Text("Select Photos")
                .foregroundColor(.white)
                .font(.system(size: 17.4, weight: .medium))
                .card()
                .padding(.top, -UINavigationController().toolbar.frame.size.height/2 - 14.5)
            }
        }
    }
    
    func prepareImage(index: Int) -> UIImage {
        let element = photoAssets[index]
        var showingImage = UIImage()
        
        imageManager.requestImage(for: element.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options, resultHandler: { image, info in
            showingImage = image ?? UIImage()
        })
        
        return showingImage
    }
}

// ピンチジェスチャに対応する
struct TappedPoint: UIViewRepresentable {

   class Coordinator: NSObject {

      @Binding var point: CGPoint

      init(point: Binding<CGPoint>) {
         _point = point
      }

      @objc func tapped(_ gesture: UIPinchGestureRecognizer) {
         // stateは適当なイベントで、
         if gesture.state == .began {
            point = gesture.location(in: gesture.view)
         }
      }
   }

   /// タップされた座標
   @Binding var point: CGPoint

   func makeUIView(context: Context) -> UIView {
       let view = UIView(frame: .zero)

       let gesture = UIPinchGestureRecognizer(
          target: context.coordinator,
          action: #selector(Coordinator.tapped(_:))
       )
       view.addGestureRecognizer(gesture)
       return view
   }

   func makeCoordinator() -> TappedPoint.Coordinator {
       Coordinator(point: $point)
   }

   func updateUIView(_ uiView: UIView, context: Context) {}
}

struct HomeScrollView: View {
    
    let gradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0, opacity: 0.5), Color(red: 0, green: 0, blue: 0, opacity: 0)]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center,spacing: 0) {
                    ForEach(1..<8) { i in
                        ZStack(alignment: .topLeading) {
                            if i == 1 {
                                Image("mushokutensei\(i)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width+20, height: proxy.size.width*4/5)
                                    .clipped()
                                
                                Rectangle()
                                    .fill(gradient)
                                    .frame(width: proxy.size.width+20, height: proxy.size.width*3/5)
                                
                                VStack {
                                    Button(action: {
                                        
                                    }) {
                                        Account(image: UIImage(named: "mushokutensei3") ?? UIImage(), name: "理不尽な孫の手", imageSize: 40, textSize: 16)
                                            .card()
                                            .padding(.leading, 20)
                                            
                                            Spacer()
                                    }
                                    .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize()+60)
                                    
                                    HStack {
                                        Text("無職転生\(i)")
                                            .bold()
                                            .shadow(color: .black, radius: 10, x: 0, y: 0)
                                            .font(.system(size: 28))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .padding(.leading, 20)
                                        
                                        Spacer()
                                    }
                                }
                            } else {
                                Image("mushokutensei\(i)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width+20, height: proxy.size.width*2/5)
                                    .clipped()
                                
                                Rectangle()
                                    .fill(gradient)
                                    .frame(width: proxy.size.width+20, height: proxy.size.width/5)
                                
                                VStack {
                                    Button(action: {
                                        
                                    }) {
                                        HStack {
                                            Account(image: UIImage(named: "mushokutensei3") ?? UIImage(), name: "理不尽な孫の手", imageSize: 40, textSize: 16)
                                                .card()
                                                .padding(.leading, 20)
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding(.top, 10)
                                    
                                    HStack {
                                        Text("無職転生\(i)")
                                            .bold()
                                            .shadow(color: .black, radius: 10, x: 0, y: 0)
                                            .font(.system(size: 28))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .padding(.leading, 20)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CGImage {
    var isDark: Bool {
        get {
            guard let imageData = self.dataProvider?.data else { return false }

            // ピクセルレベルで画像の色を取得
            guard let ptr = CFDataGetBytePtr(imageData) else { return false }

            // CFDataの長さを返す
            let length = CFDataGetLength(imageData)

            // 閾値(各人で調整)
            let threshold = Int(Double(self.width * self.height) * 0.45)
            var darkPixels = 0

            // 閾値のループ
            for i in stride(from: 0, to: length, by: 4) {
                let r = ptr[i]
                let g = ptr[i + 1]
                let b = ptr[i + 2]

                // 明るさ(各人で調整)
                let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                if luminance < 150 {
                    darkPixels += 1

                    // 閾値を超えたら黒っぽい画像とする
                    if darkPixels > threshold {
                        return true
                    }
                }
            }
            // 最後まで閾値を超えなかったら、白っぽい画像とする
            return false
        }
    }
}

struct BottomRefreshControl: View {
    
    @State private var isRefreshing = false
    @Binding var height: CGFloat
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if height - 5 - geometry.frame(in: .named(coordinateSpaceName)).midY > 55 {
                Spacer()
                    .onAppear() {
                        isRefreshing = true
                    }
            } else if height - geometry.frame(in: .named(coordinateSpaceName)).maxY > 30 {
                Spacer()
                    .onAppear() {
                        if isRefreshing {
                            isRefreshing = false
                            onRefresh()
                        }
                    }
            }
            
            HStack {
                Spacer()
                if isRefreshing {
                    ProgressView()
                        .foregroundColor(.white)
                        .card()
                }
                Spacer()
            }
            .onChange(of: geometry.frame(in: .named(coordinateSpaceName)).maxY) { newValue in
                print(newValue)
            }
        }
        .padding(.bottom, -40)
    }
}

class SignInViewController: FUIAuthPickerViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        self.navigationController?.navigationBar.isHidden = true
        self.view.subviews[0].subviews[0].subviews[0].subviews.forEach { (view: UIView) in
            if let button = view as? UIButton {
                button.layer.cornerRadius = 8.0
                button.layer.masksToBounds = true
            }
        }
        
        setupUI()
    }
    
    private func setupUI() {
        let scrollView = self.view.subviews[0]
        scrollView.backgroundColor = .clear
        let contentView = scrollView.subviews[0]
        contentView.backgroundColor = .clear

        // 背景にイメージを追加
        let imageViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
        let imageView = UIImageView(frame: imageViewFrame)
        imageView.image = UIImage(named: "palow") // Change to Chaospace's Image.
        imageView.contentMode = .scaleAspectFill

        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

struct SignInView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> FUIAuthPickerViewController {
        let authUI = FUIAuth.defaultAuthUI()!
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://example.appspot.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setAndroidPackageName("com.firebase.example", installIfNotAvailable: false, minimumVersion: "12")
        let appleProvider = FUIOAuth.appleAuthProvider()
        let googleProvider = FUIGoogleAuth(authUI: FUIAuth.defaultAuthUI()!)
        
        let providers: [FUIAuthProvider] = [appleProvider, googleProvider]
        authUI.providers = providers
        authUI.shouldHideCancelButton = true
        
        return SignInViewController(authUI: authUI)
    }
    
    func updateUIViewController(_ uiViewController: FUIAuthPickerViewController, context: Context) {
    }
}

struct MembershipButtonImage: View {
    
    let premiumGradient = [Color.yellow, Color(red: 1, green: 1, blue: 0, opacity: 1)]
    
    var body: some View {
        LinearGradient(colors: premiumGradient, startPoint: .leading, endPoint: .trailing)
            .mask {
                Text("Membership")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 2)
                    )
            }
            .frame(width: textWidth(text: "Membership") + 14, height: 32, alignment: .center)
            .card()
            .padding(.top, statusBarSize())
            .padding(.trailing, 13)
    }
    
    func textWidth(text: String) -> CGFloat {
        let width = UIScreen.main.bounds.size.width - 40
        let textWidth = text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)], context: nil).width
        return textWidth
    }
}

struct ChatCreditCondition: View {
    
    let creditCondition = 0
    
    var body: some View {
        HStack {
            Image(systemName: "p.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            
            Text("\(creditCondition)")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))
                                
            Text("or more to participate")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .regular))
                .padding(.leading, 10)
        }
        .card()
        .padding(.top, 24)
        .padding([.leading, .trailing], 20)
    }
}

struct CreditPointSetting: View {
    
    @State var conditionBool = false
    @State var isOnOpacity = 0.0
    @State var pointNum = ""
    @State var isOnHeight = CGFloat(0)
    @State var appearBool = false
    @State var chatBoard = ChatBoard()
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    HStack {
                        Text("Condition of Credit Point")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .card()
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Toggle(isOn: $conditionBool) {}
                            .shadow(color: .black.opacity(isOnOpacity), radius: 5, x: 0, y: 0)
                            .tint(.black)
                    }
                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.top, 40)
            
            if appearBool {
                HStack(alignment: .center) {
                    Text("Minimum Point")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .card()
                    
                    Spacer()
                    
                    ZStack {
                        TextField("0000", text: $pointNum)
                            .keyboardType(.numberPad)
                            .onReceive(Just(pointNum), perform: { _ in
                                if pointNum.count > 4 {
                                    pointNum = String(pointNum.prefix(4))
                                }
                            })
                            .frame(width: 64, height: 32)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .background(.white.opacity(0.7))
                            .cornerRadius(10)
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 40, height: isOnHeight)
                .opacity(isOnOpacity)
                .padding([.leading, .trailing], 20)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isOnHeight = 52
                        isOnOpacity = 1.0
                    }
                }
                .onChange(of: conditionBool) { newValue in
                    if newValue == false {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isOnHeight = 0.0
                            isOnOpacity = 0.0
                        }
                    }
                }
            }
        }
        .onChange(of: conditionBool, perform: { newValue in
            if newValue == true {
                appearBool = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    appearBool = false
                }
            }
            
            chatBoard.conditionBool = newValue
        })
        .onChange(of: pointNum, perform: { newValue in
            chatBoard.condition = Int(newValue) ?? 0
        })
    }
}

struct SelectBirthDayAndGender: View {
    
    @State var birthDay = Date()
    @State var gender = 0
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Birth Day (Optional)")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))
                .card()
            
            Spacer()
            
            DatePicker("", selection: $birthDay, displayedComponents: .date)
                .colorInvert()
                .colorMultiply(.white)
        }
        .padding(.top, 40)
        
        HStack(alignment: .center) {
            Text("Gender (Optional)")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))
                .card()
            
            Spacer()
            
            Picker("", selection: $gender) {
                Text("Male")
                    .font(.system(size: 24, weight: .medium))
                    .tag(1)
                Text("Female")
                    .font(.system(size: 24, weight: .medium))
                    .tag(2)
                Text("Other")
                    .font(.system(size: 24, weight: .medium))
                    .tag(3)
            }
        }
        .padding(.top, 40)
    }
}
