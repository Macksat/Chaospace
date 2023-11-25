//
//  Features.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/12.
//

import SwiftUI
import Combine
import UIKit
import PhotosUI
import WebKit
import CoreMedia
import MediaPlayer
import AVKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import FirebaseAuthUI
import FirebaseCore
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebaseMessaging
import GoogleSignIn
import RealmSwift
import CryptoKit
import AuthenticationServices
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let windows = windowScene?.windows.first
        banner.rootViewController = windows?.rootViewController
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        
    }
}

struct HomeViewAd: View {
    
    @State var adMobNativeView = AdMobNativeView()
    let barSize = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + UINavigationController().navigationBar.frame.size.height + statusBarSize()
    
    var body: some View {
        ZStack {
            adMobNativeView
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - barSize - 80)
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 60)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight())
        }
        .ignoresSafeArea()
    }
}

struct AdMobNativeView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> GADNativeViewController {
        let viewController = GADNativeViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GADNativeViewController, context: Context) {
        
    }
}

class GADNativeViewController: UIViewController, GADNativeAdDelegate, GADNativeAdLoaderDelegate {
    
    var heightConstraint: NSLayoutConstraint?
    var adLoader: GADAdLoader!
    var nativeAdView: GADNativeAdView!
    let adUnitID = "ca-app-pub-3940256099942544/3986624511"

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            return assert(false, "Could not load nib file for adView")
        }
        setAdView(adView)
        refreshAd()
    }

    func setAdView(_ view: GADNativeAdView) {

        nativeAdView = view
        self.view.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func refreshAd() {
        adLoader = GADAdLoader(
            adUnitID: adUnitID, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.delegate = self
        heightConstraint?.isActive = false
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        nativeAdView.bodyView?.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        nativeAdView.bodyView?.layer.shadowRadius = 5

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (nativeAdView.callToActionView as? UIButton)?.contentHorizontalAlignment = .center
        (nativeAdView.callToActionView as? UIButton)?.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        nativeAdView.iconView?.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        nativeAdView.iconView?.layer.shadowRadius = 5

        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        nativeAdView.mediaView?.mediaContent?.mainImage = nativeAd.mediaContent.mainImage

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        nativeAdView.advertiserView?.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        nativeAdView.advertiserView?.layer.shadowRadius = 5

        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.callToActionView?.layer.borderWidth = 3
        nativeAdView.callToActionView?.layer.cornerRadius = 15
        nativeAdView.callToActionView?.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        nativeAdView.callToActionView?.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        nativeAdView.callToActionView?.layer.shadowRadius = 5

        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}

class GoogleSignInViewController: UIViewController {
    
    let googleButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: (UIScreen.main.bounds.size.width - 196) / 2, y: UIScreen.main.bounds.size.height * 3 / 5, width: 196, height: 40)
        self.view.backgroundColor = .clear
        
        googleButton.frame = CGRect(x: self.view.bounds.minX - 4, y: self.view.bounds.minY - 4, width: 204, height: 42)
        googleButton.contentMode = .scaleAspectFill
        googleButton.style = .wide
        googleButton.addTarget(self, action: #selector(googleAuth), for: .touchUpInside)
        self.view.addSubview(googleButton)
    }
    
    @objc func googleAuth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
                        
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

class AppleSignInViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    
    let appleButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .default,
        authorizationButtonStyle: .white
    )
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: (UIScreen.main.bounds.size.width - 196) / 2, y: UIScreen.main.bounds.size.height * 3 / 5, width: 196, height: 40)
        self.view.backgroundColor = .clear
            
        appleButton.frame = self.view.bounds
        appleButton.addTarget(self, action: #selector(appleAuth), for: .touchUpInside)
        self.view.addSubview(appleButton)
    }
}

extension AppleSignInViewController: ASAuthorizationControllerDelegate {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    @objc func appleAuth() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (_, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                  fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                  )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

struct GoogleSignInView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> GoogleSignInViewController {
        return GoogleSignInViewController()
    }
    
    func updateUIViewController(_ uiViewController: GoogleSignInViewController, context: Context) {
    }
}

struct AppleSignInView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> AppleSignInViewController {
        return AppleSignInViewController()
    }
    
    func updateUIViewController(_ uiViewController: AppleSignInViewController, context: Context) {
    }
}

struct CardViewModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(Color.clear)
            .shadow(color: color, radius: 5, x: 0, y: 0)
    }
}


extension View {
    func card(
        color: Color = Color.black,
        radius: CGFloat = 5) -> some View {
        self.modifier(CardViewModifier(color: color, radius: radius))
    }
}

struct BackgroundImage: View {
    
    let image: String
    let opacity: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .clipped()
                .opacity(1)
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.25))
        }
        .ignoresSafeArea()
    }
}

struct BackgroundUIImage: View {
    
    let image: UIImage
    let opacity: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .clipped()
                .opacity(1)
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.25))
        }
        .ignoresSafeArea()
    }
}

struct Title: View {
    let title: String
    let size: CGFloat
    
    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: size, weight: .bold))
            .multilineTextAlignment(.center)
            .card()
            .padding(.top, UINavigationController().navigationBar.frame.size.height+statusBarSize() + 10)
            .padding([.leading, .trailing], 20)
    }
}

struct Account: View {
    let image: UIImage
    let name: String
    let imageSize: CGFloat
    let textSize: CGFloat
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: textSize, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}

struct ArticleView: View {
    
    @StateObject var parentContent: ContentInfo
    @Binding var backgroundImage: UIImage
    var aspectFit: Bool
    @State var goCreate = false
    @State var gotContent = false
    @State var preIndex = -1
    @State var afterIndex = -1
    @StateObject var contentCategory: ContentCategory = ContentCategory()
    
    var body: some View {
        VStack {
            Text("Thoughts of This Creation")
                .foregroundColor(.white)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .card()
                .padding(.bottom, 20)
                                    
            if parentContent.thisArticles.count > 0 {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: (UIScreen.main.bounds.size.width - 40)/2 - 20), alignment: .top)], alignment: .center) {
                    ForEach(0..<contentCount(), id: \.self) { i in
                        NavigationLink(destination: ContentArticleView(contentInfo: parentContent.thisArticles[i], backgroundImage: parentContent.backgroundImage, aspectFit: aspectFit, gotContent: $gotContent)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Image(uiImage: parentContent.thisArticles[i].backgroundImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.size.width - 40)/2 - 20, height: (UIScreen.main.bounds.size.width - 40)/2 - 20)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 15, x: 0, y: 0)
                                
                                Text(parentContent.thisArticles[i].name)
                                    .font(.system(size: 16, weight: .medium))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .card()
                                
                                HStack(alignment: .center, spacing: 0) {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                    
                                    Text("\(parentContent.thisArticles[i].likes.count)")
                                        .font(.system(size: 16, weight: .regular))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .padding(.leading, 8)
                                }
                                .foregroundColor(.white)
                                .card()
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded({ _ in
                            addViewCount(id: parentContent.thisArticles[i].id, collection: "contents")
                            
                            let group = DispatchGroup()
                            if parentContent.thisArticles[i].gotContent == false {
                                group.enter()
                                getArticleContents(parentContent: parentContent, i: i) { articleContent in
                                    parentContent.thisArticles[i].articleContents = articleContent
                                    parentContent.thisArticles[i].gotContent = true
                                    group.leave()
                                }
                                
                                group.notify(queue: .main) {
                                    gotContent = true
                                }
                            } else {
                                gotContent = true
                            }
                        }))
                    }
                }
                .padding([.leading, .trailing], 20)
                   
                NavigationLink(destination: SeeMoreView(title: parentContent.name + "'s Thoughts", parentContent: parentContent, backgroundImage: backgroundImage, aspectFit: aspectFit, contents: parentContent.thisArticles)) {
                    Text("See more")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .underline()
                        .multilineTextAlignment(.center)
                        .card()
                        .padding(.top, 10)
                }
            }
                        
            Button(action: {
                goCreate.toggle()
            }) {
                Text("Create Thought")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white, lineWidth: 2)
                    )
                    .card()
                    .padding(.top, 10)
            }
                        
            HStack {
                if preIndex >= 0 {
                    NavigationLink(destination: contentSegueView(contentInfo: contentCategory.contents[preIndex])) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .card()
                            
                            VStack {
                                Image(uiImage: contentCategory.contents[preIndex].backgroundImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.size.width - 40)*4/15, height: (UIScreen.main.bounds.size.width - 40)*4/15)
                                    .clipped()
                                    .cornerRadius(15)
                                    .card()
                                
                                Text(contentCategory.contents[preIndex].name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .frame(width: (UIScreen.main.bounds.size.width - 40)*4/15)
                                    .card()
                            }
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        addViewCount(id: contentCategory.contents[preIndex].id, collection: "contents")
                        
                        let group = DispatchGroup()
                        if contentCategory.contents[preIndex].gotContent == false {
                            if contentCategory.contents[preIndex].contentStyle == "scroll" {
                                group.enter()
                                getScrollContents(contentInfo: contentCategory.contents[preIndex]) { scrollContents, backgroundImage, musicData, musicURL in
                                    contentCategory.contents[preIndex].scrollContents = scrollContents
                                    contentCategory.contents[preIndex].backgroundImage = backgroundImage
                                    contentCategory.contents[preIndex].music = musicURL
                                    contentCategory.contents[preIndex].musicData = musicData
                                    contentCategory.contents[preIndex].gotContent = true
                                    group.leave()
                                }
                            } else if contentCategory.contents[preIndex].contentStyle == "show" {
                                group.enter()
                                getShowContents(contentInfo: contentCategory.contents[preIndex]) { showContents in
                                    contentCategory.contents[preIndex].showContents = showContents
                                    contentCategory.contents[preIndex].gotContent = true
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
                
                Spacer()
                
                if afterIndex < contentCategory.contents.count && afterIndex >= 0 {
                    NavigationLink(destination: contentSegueView(contentInfo: contentCategory.contents[afterIndex])) {
                        HStack {
                            VStack {
                                Image(uiImage: contentCategory.contents[afterIndex].backgroundImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.size.width - 40)*4/15, height: (UIScreen.main.bounds.size.width - 40)*4/15)
                                    .clipped()
                                    .cornerRadius(15)
                                    .card()
                                
                                Text(contentCategory.contents[afterIndex].name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .regular))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .frame(width: (UIScreen.main.bounds.size.width - 40)*4/15)
                                    .card()
                            }
                            
                            Image(systemName: "chevron.forward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .card()
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        addViewCount(id: contentCategory.contents[afterIndex].id, collection: "contents")
                        
                        let group = DispatchGroup()
                        if contentCategory.contents[afterIndex].gotContent == false {
                            if contentCategory.contents[afterIndex].contentStyle == "scroll" {
                                group.enter()
                                getScrollContents(contentInfo: contentCategory.contents[afterIndex]) { scrollContents, backgroundImage, musicData, musicURL in
                                    contentCategory.contents[afterIndex].scrollContents = scrollContents
                                    contentCategory.contents[afterIndex].backgroundImage = backgroundImage
                                    contentCategory.contents[afterIndex].music = musicURL
                                    contentCategory.contents[afterIndex].musicData = musicData
                                    contentCategory.contents[afterIndex].gotContent = true
                                    group.leave()
                                }
                            } else if contentCategory.contents[afterIndex].contentStyle == "show" {
                                group.enter()
                                getShowContents(contentInfo: contentCategory.contents[afterIndex]) { showContents in
                                    contentCategory.contents[afterIndex].showContents = showContents
                                    contentCategory.contents[afterIndex].gotContent = true
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
            }
            .padding(.top, 40)
            .padding([.leading, .trailing], 20)
            
            AdMobBannerView()
                .frame(width: UIScreen.main.bounds.size.width - 40, height: 50)
                .padding([.leading, .trailing], 20)
                .padding(.top, 20)
        }
        .onWillAppear {
            gotContent = false
            
            if let index = contentCategory.contents.firstIndex(where: { $0.id == parentContent.id }) {
                preIndex = index - 1
                afterIndex = index + 1
            } else {
                preIndex = -1
                afterIndex = contentCategory.contents.count
            }
        }
        .fullScreenCover(isPresented: $goCreate) {
            NavigationView {
                CreateArticleView(image: backgroundImage, parentContent: parentContent)
            }
            .accentColor(.white)
        }
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent, category: contentCategory)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent, category: contentCategory)
        }
    }
    
    func contentCount() -> Int {
        var contentCount = parentContent.thisArticles.count
        if parentContent.thisArticles.count > 4 {
            contentCount = 4
        }
        
        return contentCount
    }
}

struct RefreshControl: View {
    
    @State private var isRefreshing = false
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .named(coordinateSpaceName)).midY > 40 {
                Spacer()
                    .onAppear() {
                        isRefreshing = true
                    }
            } else if geometry.frame(in: .named(coordinateSpaceName)).maxY < 10 {
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
        }
        .padding(.top, -40)
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = .black
        scrollView.addSubview(hostedView)

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
          self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
          return hostingController.view
        }
    }
}


struct ViewWillAppearHandler: UIViewControllerRepresentable {
    
    let onWillAppear: () -> Void
    
    func makeCoordinator() -> ViewWillAppearHandler.Coordinator {
        Coordinator(onWillAppear: onWillAppear)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewWillAppearHandler>) -> UIViewController {
        context.coordinator
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewWillAppearHandler>) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
    class Coordinator: UIViewController {
        
        let onWillAppear: () -> Void
        
        init(onWillAppear: @escaping () -> Void) {
            self.onWillAppear = onWillAppear
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) in ViewWillAppearHandler has not been implemented.")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            onWillAppear()
        }
    }
}

struct ViewWillAppearModifier: ViewModifier {
    
    let callback: () -> Void
    
    func body(content: Content) -> some View {
        content.background(ViewWillAppearHandler(onWillAppear: callback))
    }
}

extension View {
    func onWillAppear(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewWillAppearModifier(callback: perform))
    }
}

struct ViewWillDisappearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> ViewWillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }

    let onWillDisappear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewWillDisappearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewWillDisappearHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

struct ViewWillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(ViewWillDisappearHandler(onWillDisappear: callback))
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewWillDisappearModifier(callback: perform))
    }
}

class KeyboardObserver: ObservableObject {
    
    @Published var keyboardHeight: CGFloat = 0.0
    
    func startObserve() {
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func stopObserve() {
        NotificationCenter
            .default
            .removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let keyboardEndFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let keyboardBeginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            let endMinY = keyboardEndFrame.cgRectValue.minY
            let beginMinY = keyboardBeginFrame.cgRectValue.minY
            
            keyboardHeight = beginMinY - endMinY
            if keyboardHeight < 0 {
                keyboardHeight = 0
            }
        }
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TextingView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var height: CGFloat
    var placeholder: String = ""
    @State var isEditing = false
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        if self.text == "" {
            textView.text = self.placeholder
            textView.textColor = .darkGray
        } else {
            textView.text = self.text
            textView.textColor = .black
        }
        
        return textView
    }
    
    func makeCoordinator() -> TextingView.Coordinator {
        Coordinator(textingView: self)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if isEditing == false {
            if self.text == "" {
                uiView.text = self.placeholder
                uiView.textColor = .darkGray
            }
        } else {
            if self.text == "" {
                uiView.text = ""
                uiView.textColor = .black
            }
        }
        
        DispatchQueue.main.async {
            if uiView.contentSize.height < 100 {
                self.height = uiView.contentSize.height
            } else {
                self.height = 100
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var textingView: TextingView
        
        init(textingView: TextingView) {
            self.textingView = textingView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textingView.isEditing = true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.textingView.text = textView.text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            textingView.isEditing = false
            if self.textingView.text == "" {
                textView.text = textingView.placeholder
                textView.textColor = .darkGray
            }
        }
    }
}

struct ContentTextingView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var viewBottomHeight: CGFloat
    @State var isEditing = false
    @State var textViewChanged = false
    
    var originalHeight: CGFloat = 80
    var fontSize: CGFloat = 16
    var fontWeight: UIFont.Weight = .regular
    var textAlignment: NSTextAlignment = .left
    var placeholder: String = ""
    var textLimit: Int = 0
    let doneFunc = DoneButtonFunc()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        textView.textAlignment = textAlignment
        textView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        textView.layer.cornerRadius = 15
        if self.text == "" {
            textView.text = self.placeholder
            textView.textColor = .darkGray
        } else {
            textView.text = self.text
            textView.textColor = .black
        }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self.doneFunc, action: #selector(self.doneFunc.doneFunc))
        toolbar.items = [spacer, doneButton]
        textView.inputAccessoryView = toolbar
        
        DispatchQueue.main.async {
            if textView.contentSize.height > self.originalHeight {
                self.height = textView.contentSize.height
            } else {
                self.height = self.originalHeight
            }
        }
        
        return textView
    }
    
    class DoneButtonFunc {
        @objc func doneFunc() {
            UIApplication.shared.closeKeyboard()
        }
    }
    
    func makeCoordinator() -> ContentTextingView.Coordinator {
        Coordinator.init(contentTextingView: self)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if isEditing == false {
            if self.text == "" {
                uiView.text = self.placeholder
                uiView.textColor = .darkGray
            } else {
                uiView.text = self.text
                uiView.textColor = .black
            }
        } else {
            if uiView.textColor == .darkGray {
                uiView.text = ""
                uiView.textColor = .black
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var contentTextingView: ContentTextingView
        
        init(contentTextingView: ContentTextingView) {
            self.contentTextingView = contentTextingView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if contentTextingView.textLimit == 0 {
                return true
            } else {
                return textView.text.count + (text.count - range.length) <= contentTextingView.textLimit
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            contentTextingView.isEditing = true
               
            withAnimation(.easeOut(duration: 0.15)) {
                contentTextingView.viewBottomHeight = UIScreen.main.bounds.size.height/2
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            contentTextingView.text = textView.text
            DispatchQueue.main.async {
                if textView.contentSize.height > self.contentTextingView.originalHeight {
                    self.contentTextingView.height = textView.contentSize.height
                } else {
                    self.contentTextingView.height = self.contentTextingView.originalHeight
                }
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            contentTextingView.isEditing = false
            contentTextingView.text = textView.text
            
            if contentTextingView.text == "" {
                textView.text = contentTextingView.placeholder
                textView.textColor = .darkGray
            }
            
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.15)) {
                    self.contentTextingView.viewBottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
                }
            }
        }
    }
}

struct URLTextView: UIViewRepresentable {
    
    var text: NSAttributedString
    @Binding var url: String
    var width: CGFloat
    @Binding var height: CGFloat
    @Binding var openWeb: Bool
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.attributedText = text
        DispatchQueue.main.async {
            self.height = textView.contentSize.height
            textView.frame.size = CGSize(width: width, height: height)
        }
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.widthAnchor.constraint(equalToConstant: width).isActive = true
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.linkTextAttributes = [
            .font : UIFont.systemFont(ofSize: 16.0, weight: .medium),
            .foregroundColor : UIColor.systemBlue
        ]
        
        return textView
    }
    
    func makeCoordinator() -> URLTextView.Coordinator {
        Coordinator(view: self, text: self.text)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var view: URLTextView
        
        init(view: URLTextView, text: NSAttributedString) {
            self.view = view
            self.view.text = text
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            view.url = URL.absoluteString
            view.webViewVar.nowURL = URL.absoluteString
            view.openWeb = true
            return false
        }
    }
}

struct TagTextingView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var viewBottomHeight: CGFloat
    @Binding var tagArray: [String]
    @State var isEditing = false
    @State var textViewChanged = false
    
    var height: CGFloat = 48
    var fontSize: CGFloat = 16
    var fontWeight: UIFont.Weight = .regular
    var textAlignment: NSTextAlignment = .left
    var placeholder: String = ""
    var textLimit: Int = 0
    let doneFunc = DoneButtonFunc()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        textView.textAlignment = textAlignment
        textView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        textView.layer.cornerRadius = 15
        if self.text == "" {
            textView.text = self.placeholder
            textView.textColor = .darkGray
        } else {
            textView.text = self.text
            textView.textColor = .black
        }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self.doneFunc, action: #selector(self.doneFunc.doneFunc))
        toolbar.items = [spacer, doneButton]
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    class DoneButtonFunc {
        @objc func doneFunc() {
            UIApplication.shared.closeKeyboard()
        }
    }
    
    func makeCoordinator() -> TagTextingView.Coordinator {
        Coordinator.init(tagTextingView: self)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if isEditing == false {
            if self.text == "" {
                uiView.text = self.placeholder
                uiView.textColor = .darkGray
            } else {
                uiView.text = self.text
                uiView.textColor = .black
            }
        } else {
            if uiView.textColor == .darkGray {
                uiView.text = ""
                uiView.textColor = .black
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var tagTextingView: TagTextingView
        
        init(tagTextingView: TagTextingView) {
            self.tagTextingView = tagTextingView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if tagTextingView.textLimit == 0 {
                return true
            } else {
                return textView.text.count + (text.count - range.length) <= tagTextingView.textLimit
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            tagTextingView.isEditing = true
               
            withAnimation(.easeOut(duration: 0.15)) {
                tagTextingView.viewBottomHeight = UIScreen.main.bounds.size.height/2
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.text.contains("\n") {
                var tagText = textView.text ?? ""
                tagText.removeLast()
                if tagText != "" {
                    tagTextingView.tagArray.append(tagText)
                }
                tagTextingView.text = ""
                textView.text = ""
            } else {
                tagTextingView.text = textView.text
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            tagTextingView.isEditing = false
            tagTextingView.text = textView.text
            
            if tagTextingView.text == "" {
                textView.text = tagTextingView.placeholder
                textView.textColor = .darkGray
            }
            
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.15)) {
                    self.tagTextingView.viewBottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight()
                }
            }
        }
    }
}

struct SingleImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var mediaTypes: [String] // ["public.image"] or ["public.movie"]
    @Binding var urls: [URL]
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SingleImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = mediaTypes
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func makeCoordinator() -> SingleImagePicker.Coordinator {
        Coordinator(imagePicker: self)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<SingleImagePicker>) {
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var imagePicker: SingleImagePicker
        
        init(imagePicker: SingleImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imagePicker.images.append(image)
            } else if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                imagePicker.urls.append(mediaURL)
            }
            imagePicker.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            imagePicker.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PHPicker: UIViewControllerRepresentable {
    
    var filter: [PHPickerFilter] = [.images]
    var selectionLimit: Int = 0
    @Binding var urls: [URL]
    @Binding var images: [UIImage]
    @Environment(\.dismiss) var dismiss
        
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .any(of: filter)
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
        
    func makeCoordinator() -> PHPicker.Coordinator {
        Coordinator(phPicker: self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var phPicker: PHPicker
        
        init(phPicker: PHPicker) {
            self.phPicker = phPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var typeIdentifier = String()
            let group = DispatchGroup()
            
            if results.count == 0 {
                self.phPicker.dismiss()
            }
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    typeIdentifier = UTType.image.identifier
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { item, error in
                        if let image = item as? UIImage {
                            self.phPicker.images.append(image)
                        } else if let error = error {
                            print(error)
                        }
                        group.leave()
                    }
                    
                    if result.itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                        group.enter()
                        result.itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { (url, error) in
                            if let error = error {
                                print(error)
                            } else if let url = url as? URL {
                                self.phPicker.urls.append(url)
                            }
                            group.leave()
                        }
                    }
                } else {
                    typeIdentifier = UTType.movie.identifier
                    if result.itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                        group.enter()
                        result.itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { (url, error) in
                            if let error = error {
                                print(error)
                            } else if let url = url as? URL {
                                self.phPicker.urls.append(url)
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.phPicker.dismiss()
            }
        }
    }
}

struct ChatPHPicker: UIViewControllerRepresentable {
    
    var filter: PHPickerFilter = .images
    @EnvironmentObject var textingBool: TextingBool
    @EnvironmentObject var chatBoardID: ChatBoardID
    @EnvironmentObject var accountInfo: AccountInfo
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = filter
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> ChatPHPicker.Coordinator {
        Coordinator(phPicker: self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var phPicker: ChatPHPicker
        
        init(phPicker: ChatPHPicker) {
            self.phPicker = phPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var urls = [String]()
            var resizeUrls = [String]()
            var imageArray = [UIImage]()
            let group = DispatchGroup()
            let ref = Firestore.firestore().collection("chatBoard").document(self.phPicker.chatBoardID.id).collection("chatContent")
            
            if results.count == 0 {
                self.phPicker.dismiss()
            }
            
            for (index, result) in results.enumerated() {
                if self.phPicker.filter == .images {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { item, error in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        } else if let image = item as? UIImage {
                            imageArray.append(image)
                            
                            let storage = Storage.storage()
                            let reference = storage.reference()
                            let data = image.jpegData(compressionQuality: 0.3) ?? Data()
                            let path = "gs://chaospace-8a8b5/storage/chaospace-8a8b5.appspot.com/user/\(self.phPicker.accountInfo.id)/chatBoards/\(self.phPicker.chatBoardID.id)/\(UUID()).png"
                            let imageRef = reference.child(path)
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/png"
                            let uploadTask = imageRef.putData(data, metadata: metadata)
                            var downloadURL: URL?
                            
                            group.enter()
                            DispatchQueue(label: "uploadChatImage").async {
                                group.enter()
                                uploadTask.observe(.success) { _ in
                                    group.enter()
                                    imageRef.downloadURL { url, error in
                                        if let url = url {
                                            downloadURL = url
                                            urls.append(downloadURL?.absoluteString ?? "")
                                            var resizeURL = downloadURL?.absoluteString ?? ""
                                            if let png = resizeURL.range(of: ".png") {
                                                resizeURL.replaceSubrange(png, with: "_250x250.png")
                                                resizeUrls.append(resizeURL)
                                            }
                                        }
                                        group.leave()
                                    }
                                    group.leave()
                                }
                                
                                uploadTask.observe(.failure) { snapshot in
                                    if let message = snapshot.error?.localizedDescription {
                                        print("Error: \(message)")
                                    }
                                }
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                    
                    group.notify(queue: .main) {
                        if index == results.count - 1 {
                            ref.addDocument(data: [
                                "content": "",
                                "date": Date(),
                                "userID": self.phPicker.accountInfo.id,
                                "images": urls,
                                "resizeImages": resizeUrls
                            ])
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            
                            self.phPicker.chatBoardID.chatAdded = true
                            self.phPicker.textingBool.bottomHeight = bottomInsetHeight()
                            self.phPicker.dismiss()
                        }
                    }
                }
            }
        }
    }
}

func compressImageData(image: UIImage) -> Data {
    var data = Data()
    if let imgData = image.jpegData(compressionQuality: 0.85) {
        data = imgData
        print(data.count)
        var rate = 0.8
        while data.count > 2500000 {
            data = image.jpegData(compressionQuality: rate) ?? Data()
            rate -= 0.1
            
            if rate == 0.0 {
                break
            }
        }
    }
    print(data.count)
    
    return data
}

func customCompressImage(image: UIImage, rate: Double) -> Data {
    let imgData = image.jpegData(compressionQuality: rate) ?? Data()
    print(imgData.count)
    
    return imgData
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func getURLFromText(text: String) -> [(String, String)] {
    do {
        let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let links = detector.matches(in: text, range: NSRange(location: 0, length: text.count))
        
        return links.map { result -> (String, String) in
            return ((text as NSString).substring(with: result.range), result.url!.absoluteString)
        }
    } catch {
        return []
    }
}

func getAttributeString(text: String) -> NSAttributedString {
    let textAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 16.0, weight: .medium),
        .foregroundColor : UIColor.white
    ]
    
    let links = getURLFromText(text: text)
    let attributedString = NSMutableAttributedString(string: text, attributes: textAttributes)

    for i in links {
        attributedString.addAttribute(.link,
                                      value: i.1,
                                      range: NSString(string: text).range(of: i.0))
    }
    
    return attributedString
}

struct ShowWebView: UIViewRepresentable {
    
    var url: String = "https://google.com"
    var webView = WKWebView()
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: webViewVar.nowURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            let url = URL(string: "https://google.com")
            let request = URLRequest(url: url!)
            webView.load(request)
        }
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func makeCoordinator() -> ShowWebView.Coordinator {
        Coordinator(showWebView: self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    func nowURL() -> String {
        if let url = webView.url?.absoluteString {
            return url
        } else {
            return self.url
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        var showWebView: ShowWebView
        
        init(showWebView: ShowWebView) {
            self.showWebView = showWebView
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            let urlString = self.showWebView.nowURL()
            self.showWebView.webViewVar.nowURL = urlString
            self.showWebView.webViewVar.goB = webView.canGoBack
            self.showWebView.webViewVar.goF = webView.canGoForward
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let urlString = self.showWebView.nowURL()
            self.showWebView.webViewVar.nowURL = urlString
            self.showWebView.webViewVar.goB = webView.canGoBack
            self.showWebView.webViewVar.goF = webView.canGoForward
        }
    }
}

struct DragAndDrop: ViewModifier {
    
    var index: Int
    
    func body(content: Content) -> some View {
        content
            .onDrag {
                let provider = NSItemProvider()
                let text = "\(index)"
                provider.registerDataRepresentation(forTypeIdentifier: String(), visibility: .all) { completion -> Progress? in
                    completion(text.data(using: .utf8), nil)
                    return nil
                }
                return provider
            }
    }
}

extension View {
    func drag(index: Int) -> some View {
        self.modifier(DragAndDrop(index: index))
    }
}

struct ContentBackgroundImage: View {
    
    var image: UIImage = UIImage(named: "black") ?? UIImage()
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var opacity: Double = 0.0
    var aspectFit: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            if aspectFit == false {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .blur(radius: 5, opaque: true)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            }
            
            Rectangle()
                .frame(width: width, height: height)
                .foregroundColor(.black.opacity(opacity))
        }
        .ignoresSafeArea()
    }
}

struct FadePageView: View {
    
    @State var selection = 0
    @State var opacity = 1.0
    @State var timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    @Binding var contentArray: [ContentInfo]
    @Binding var worldArray: [WorldInfo]
    var width: CGFloat = UIScreen.main.bounds.size.width
    var height: CGFloat = UIScreen.main.bounds.size.width*3/4
   
    var body: some View {
        ZStack(alignment: .topLeading) {
            if contentArray.count > 0 {
                if selection > 0 {
                    Image(uiImage: contentArray[selection - 1].backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                } else {
                    Image(uiImage: contentArray[contentArray.count - 1].backgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                }
            } else {
                if worldArray.count > 0 {
                    if selection > 0 {
                        Image(uiImage: worldArray[selection - 1].backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                    } else {
                        Image(uiImage: worldArray[worldArray.count - 1].backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                    }
                }
            }
            
            if contentArray.count > 0 || worldArray.count > 0 {
                TabView(selection: $selection) {
                    if contentArray.count > 0 {
                        ForEach(0..<contentArray.count, id: \.self) { i in
                            Image(uiImage: contentArray[i].backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipped()
                                .tag(i)
                        }
                    } else {
                        if worldArray.count > 0 {
                            ForEach(0..<worldArray.count, id: \.self) { i in
                                Image(uiImage: worldArray[i].backgroundImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: height)
                                    .clipped()
                                    .tag(i)
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .opacity(opacity)
                .transition(.opacity)
                .onReceive(timer) { _ in
                    if contentArray.count > 0 {
                        if selection < contentArray.count - 1 {
                            selection += 1
                            opacity = 0.0
                        } else {
                            selection = 0
                            opacity = 0.0
                        }
                    }
                    
                    if worldArray.count > 0 {
                        if selection < worldArray.count - 1 {
                            selection += 1
                            opacity = 0.0
                        } else {
                            selection = 0
                            opacity = 0.0
                        }
                    }
                    
                    withAnimation(.linear(duration: 0.5)) {
                        opacity = 1.0
                    }
                }
                .frame(width: width, height: height)
            }
            
            Rectangle()
                .frame(width: width, height: height)
                .foregroundColor(.black.opacity(0.2))
        }
        .onWillAppear {
            timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

struct FileView: UIViewControllerRepresentable {
    
    var multipleSelection: Bool = false
    var fileType: String = ""
    @Binding var urls: [URL]
        
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        var documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        if fileType == "video" {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie])
        } else if fileType == "photo" {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        } else if fileType == "photoVideo" {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .movie])
        }
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = multipleSelection
        return documentPicker
    }
    
    func makeCoordinator() -> FileView.Coordinator {
        Coordinator(fileView: self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        var fileView: FileView
        
        init(fileView: FileView) {
            self.fileView = fileView
        }
    
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if urls.first == nil || !urls.first!.startAccessingSecurityScopedResource() {
                return
            }
            
            var contentNames = urls.map( { $0.lastPathComponent } )
            for i in 0..<contentNames.count {
                contentNames[i].removeLast(4)
            }
            
            if fileView.multipleSelection {
                fileView.urls = urls
            } else {
                fileView.urls.append(urls[0])
            }
        }
        
        func fixFileName(string: String) -> String {
            var title = string
            
            if title.suffix(4) == ".mp3" {
                title.removeLast(4)
            }
            return title
        }
    }
}

private func generateTags(tagList: [String]) -> some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    
    return ZStack(alignment: .topLeading) {
      ForEach(tagList, id: \.self) { tag in
        item(for: tag)
          .padding([.horizontal, .vertical], 4)
          .alignmentGuide(.leading, computeValue: { d in
            if abs(width - d.width) > 330 {
              width = 0
              height -= d.height
            }
            let result = width
            if tag == tagList.last {
              width = 0
            } else {
              width -= d.width
            }
            return result
          })
          .alignmentGuide(.top, computeValue: { _ in
            let result = height
            if tag == tagList.last {
              height = 0
            }
            return result
          })
      }
    }
}
  
func item(for text: String) -> some View {
    Text(text)
        .font(.system(size: 20, weight: .medium))
        .padding(5)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 2)
        }
        .foregroundColor(.white)
        .card()
}

// make image from video.
func captureImage(movieURL: URL, capturingTime: CMTime) -> CGImage? {
    let asset: AVAsset = AVURLAsset(url: movieURL, options: nil)
    let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
    do {
        let cgImage: CGImage = try imageGenerator.copyCGImage(at: capturingTime, actualTime: nil)
        return cgImage
    } catch {
        return nil
    }
}

struct PlayVideoView: UIViewControllerRepresentable {
    
    var playerController = AVPlayerViewController()
    var url: URL = URL(fileURLWithPath: "")
    @Binding var didChange: Bool
    private var player: AVPlayer {
        return AVPlayer(url: url)
    }
    @State var timer = Timer()
    @EnvironmentObject var music: Music
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
                
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        do {
            try audioSession.setActive(true)
            print("Audio session set active !!")
        } catch {
            
        }
        
        playerController.player = player
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            if playerController.player?.timeControlStatus == .playing && music.pauseBool == false {
                DispatchQueue.main.async {
                    music.pauseBool = true
                    self.timer.invalidate()
                }
            }
        }
        
        return playerController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if didChange == true {
            uiViewController.player?.pause()
            uiViewController.player = player
        }
        
        if music.pauseBool == false && timer.isValid == false {
            timer.fire()
        }
    }
}

struct ChooseBackgroundView: View {
    
    @Binding var showContentMenu: Bool
    @Binding var image: UIImage
    @Binding var showImage: Bool
    var text: String = NSLocalizedString("Tap to Choose Content", comment: "")
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white.opacity(0.7))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/5)
            
            HStack {
                Button(action: {
                    showContentMenu = true
                }) {
                    Text(text)
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .medium))
                        .frame(width: ((UIScreen.main.bounds.size.width - 40)*4/5) - 24, alignment: .leading)
                        .lineLimit(2)
                }
                
                
                Spacer()
                
                Button(action: {
                    if image != UIImage() && image != UIImage(named: "black") ?? UIImage() {
                        showImage = true
                    }
                }) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: ((UIScreen.main.bounds.size.width - 40)/5) - 16, height: ((UIScreen.main.bounds.size.width - 40)/5) - 16)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 56, alignment: .center)
            .padding([.leading, .trailing], 8)
        }
        .cornerRadius(15)
    }
}

class StorageUploader {
    fileprivate struct SUComponent {
        var file:URL?
        var data:Data?
        var childRef:StorageReference?
        var metadata:StorageMetadata?
        var isComplete = false
    }

    var progressHandler: (_ completedUnitCount: Int64, _ totalUnitCount: Int64) -> Void = {_, _ in }
    var completeHandler: (_ metaDatas: [StorageMetadata]) -> Void = {_ in }
    var failureHandler: (_ error: NSError?) -> Void = {_ in }

    fileprivate var components = [SUComponent]()
    fileprivate var uploadTasks = [StorageUploadTask]()
    fileprivate var totalUnitCount:Int64 = 1
    fileprivate var completedUnitCount:Int64 = 0
    fileprivate var isfailure = false

    func addFile(file:URL, childRef:StorageReference, metadata:StorageMetadata) {
        var uploadInfo = SUComponent()
        uploadInfo.file = file
        uploadInfo.childRef = childRef
        uploadInfo.metadata = metadata
        components.append(uploadInfo)
    }

    func addData(data:Data, childRef:StorageReference, metadata:StorageMetadata) {
        var uploadInfo = SUComponent()
        uploadInfo.data = data
        uploadInfo.childRef = childRef
        uploadInfo.metadata = metadata
        components.append(uploadInfo)
    }

    func start() {
        prepareUpload()
        progressHandler(completedUnitCount, totalUnitCount)
    }

    fileprivate func prepareUpload() {
        components.forEach { uploadInfo in
            let childRef = uploadInfo.childRef
            let metadata = uploadInfo.metadata
            if let file = uploadInfo.file {
                guard let uploadTask = childRef?.putFile(from: file, metadata: metadata) else {
                    return
                }
                observeStatus(uploadTask)
            } else if let data = uploadInfo.data {
                guard let uploadTask = childRef?.putData(data, metadata: metadata) else {
                    return
                }
                observeStatus(uploadTask)
            }
        }
    }

    fileprivate func observeStatus(_ uploadTask: StorageUploadTask) {
        uploadTasks.append(uploadTask)
        uploadTask.observe(.progress) { snapshot in
            var currentCompletedUnitCount:Int64 = 0
            var currentTotalUnitCount:Int64 = 0
            self.uploadTasks.forEach { uploadTask in
                currentCompletedUnitCount += (uploadTask.snapshot.progress?.completedUnitCount ?? 0)
                currentTotalUnitCount += (uploadTask.snapshot.progress?.totalUnitCount ?? 0)
            }
            self.completedUnitCount = currentCompletedUnitCount
            self.totalUnitCount = currentTotalUnitCount
            self.progressHandler(currentCompletedUnitCount, currentTotalUnitCount)
        }
        uploadTask.observe(.success) { snapshot in
            if self.completedUnitCount == self.totalUnitCount {
                let metaDatas = self.uploadTasks.map { uploadTask -> StorageMetadata in
                    return uploadTask.snapshot.metadata ?? StorageMetadata()
                }
                self.completeHandler(metaDatas)
            }
        }
        uploadTask.observe(.failure) { snapshot in
            if !self.isfailure {
                self.isfailure = true
                self.uploadTasks.forEach { uploadTask in
                    if uploadTask.snapshot.progress?.isCancellable ?? false {
                        uploadTask.cancel()
                    }
                }
                let error = snapshot.error as NSError?
                self.failureHandler(error)
            }
        }
    }
}

struct ChooseFileOrLibrary: View {
    
    @Binding var photoLibraryShow: Bool
    @Binding var fileShow: Bool
    @Binding var menuShow: Bool
    @Binding var padding: CGFloat
    @Binding var opacity: Double
    @Binding var viewName: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(.white.opacity(0.7))
                .frame(width: UIScreen.main.bounds.size.width - 40, height: 150)
                .cornerRadius(20)
            
            VStack(alignment: .trailing, spacing: 0) {
                Button(action: {
                    removeMenu()
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .medium))
                }
                .padding(.bottom, 10)
                
                VStack(spacing: 1) {
                    ForEach(0..<2, id: \.self) { i in
                        Button(action: {
                            if viewName == "MakingShowContentView" {
                                viewName = "MakingShowAddContent"
                            }
                            
                            if i == 0 {
                                photoLibraryShow.toggle()
                            } else {
                                if viewName == "CreateWorldView" {
                                    viewName = "WorldViewPhoto"
                                } else if viewName == "EditWorldInfoView" {
                                    viewName = "EditWorldViewPhoto"
                                }
                                fileShow.toggle()
                            }
                            
                            removeMenu()
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: UIScreen.main.bounds.size.width - 60, height: 48)
                                
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
            }
            .padding(10)
        }
        .opacity(opacity)
        .padding(.bottom, padding)
        .gesture(DragGesture().onEnded({ value in
            if value.translation.height > 30 {
                removeMenu()
            }
        }))
    }
    
    func removeMenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            padding = -20.0
            opacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            menuShow = false
        }
    }
}

func uploadToStorage(path: String, data: Data, type: String, document: DocumentReference, contentName: String, _ completion: @escaping((_progress: Double, _status: String)) -> Void) {
    let storageRef = Storage.storage().reference()
    let metadata = StorageMetadata()
    metadata.contentType = type
    let reference = storageRef.child(path)
    let uploadTask = reference.putData(data, metadata: metadata)
    
    uploadTask.observe(.progress) { snapshot in
        let progress = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        completion((progress, "progress"))
        if progress == 100 {
            uploadTask.removeAllObservers(for: .progress)
        }
    }
    
    uploadTask.observe(.success) { _ in
        completion((100.0, "succeeded"))
        uploadTask.removeAllObservers()
    }
    
    uploadTask.observe(.failure) { _ in
        completion((100.0, "failed"))
        uploadTask.removeAllObservers()
    }
    
    document.updateData([contentName: path])
}

func uploadToStorageObserve(path: String, data: Data, type: String, document: DocumentReference, contentName: String, _ completion: @escaping((_progress: Double, _status: String)) -> Void) {
    let storageRef = Storage.storage().reference()
    let metadata = StorageMetadata()
    metadata.contentType = type
    let reference = storageRef.child(path)
    let uploadTask = reference.putData(data, metadata: metadata)
    var urlStr = ""
    
    uploadTask.observe(.progress) { snapshot in
        let progress = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        completion((progress, "progress"))
        if progress == 100 {
            uploadTask.removeAllObservers(for: .progress)
        }
    }
        
    uploadTask.observe(.success) { _ in
        reference.downloadURL { url, err in
            if let url = url {
                urlStr = url.absoluteString
                document.updateData([contentName: urlStr])
                completion((100.0, "succeeded"))
                uploadTask.removeAllObservers()
            } else if let err = err {
                print("Failed to get url: \(err)")
            }
        }
    }
    
    uploadTask.observe(.failure) { err in
        completion((100.0, "failed"))
        uploadTask.removeAllObservers()
    }
}

struct CirclarProgress: View {
    
    @Binding var progress: Double
    let color: Color
    let strokeWidth: CGFloat
    var lineCap: CGLineCap = .butt
    var angle: Double = -90
    
    private var offset: CGFloat {
        strokeWidth / 2
    }

    var body: some View {
        Circle()
            .trim(from: 0.0, to: progress / 100.0)
            .stroke(color, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: lineCap))
            .rotationEffect(Angle(degrees: angle))
            .padding(offset)
            .aspectRatio(1, contentMode: .fit)
            .animation(.easeOut, value: progress)
    }
}

extension UICollectionReusableView {
    override open var backgroundColor: UIColor? {
        get { .clear }
        set { }
    }
}

struct UploadProgressView: View {
    
    @Binding var progressCount: Double
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black.opacity(0.5))
            
            VStack {
                Spacer()
                
                VStack {
                    ZStack {
                        CirclarProgress(progress: $progressCount, color: .white, strokeWidth: 4)
                            .frame(width: UIScreen.main.bounds.size.width/2 - 20, height: UIScreen.main.bounds.size.width/2 - 20)
                        
                        Text("\(Int(progressCount))%")
                            .foregroundColor(.white)
                            .font(.system(size: 32, weight: .semibold))
                    }
                    
                    Text("Uploading...")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Spacer()
            }
        }
    }
}

func getScrollContents(contentInfo: ContentInfo, _ completion: @escaping((_scrollContents: [ScrollContent], _backgroundImage: UIImage, _musicData: Data, _musicURL: URL)) -> Void) {
    var scrollContents = [ScrollContent]()
    var backgroundImage = UIImage(named: "black") ?? UIImage()
    var musicURL = URL(fileURLWithPath: "")
    var musicData = Data()
    let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
    let group = DispatchGroup()
    ref.getDocument { document, err in
        if let document = document {
            let backgroundImagePath = document.data()?["backgroundImage"] as? String ?? ""
            let bgmPath = document.data()?["bgm"] as? String ?? ""
            
            if bgmPath != "" {
                group.enter()
                Storage.storage().reference().child(bgmPath).getData(maxSize: 1024 * 1024 * 20) { data, err in
                    if let data = data {
                        musicURL = URL(fileURLWithPath: bgmPath)
                        musicData = data
                    }
                    group.leave()
                }
            }
            
            if backgroundImagePath != "" {
                group.enter()
                Storage.storage().reference(forURL: backgroundImagePath).getData(maxSize: 1024 * 1024 * 20) { data, err in
                    if let data = data {
                        if let image = UIImage(data: data) {
                            backgroundImage = image
                        }
                    } else if let err = err {
                        print("Something is wrong.")
                        print(err)
                    }
                    group.leave()
                }
            }
                    
            group.notify(queue: .main) {
                let subContentStoreRef = ref.collection("scrollContent")
                group.enter()
                subContentStoreRef.getDocuments { subDocuments, _ in
                    if let subDocuments = subDocuments {
                        for sdoc in subDocuments.documents {
                            var scrollContent = ScrollContent()
                            scrollContent.type = sdoc.data()["type"] as! String
                            scrollContent.index = sdoc.data()["index"] as! Int
                            if scrollContent.type == "image" || scrollContent.type == "video"  {
                                scrollContent.url = sdoc.data()["content1"] as! String
                                group.enter()
                                Storage.storage().reference().child(scrollContent.url).downloadURL { someURL, _ in
                                    if let someURL = someURL {
                                        if scrollContent.type == "video" {
                                            scrollContent.videoURL = someURL
                                        } else if scrollContent.type == "image" {
                                            group.enter()
                                            requestImageFromURLSession(url: someURL as NSURL) { image in
                                                scrollContent.image = image
                                                group.leave()
                                            }
                                        }
                                    }
                                    group.leave()
                                }
                            } else if scrollContent.type == "link" {
                                scrollContent.content = sdoc.data()["content2"] as! String
                                scrollContent.url = sdoc.data()["content1"] as! String
                                group.enter()
                                Storage.storage().reference().child(sdoc.data()["content3"] as! String).downloadURL { linkURL, _ in
                                    if let linkURL = linkURL {
                                        group.enter()
                                        requestImageFromURLSession(url: linkURL as NSURL) { image in
                                            scrollContent.image = image
                                            group.leave()
                                        }
                                    }
                                    group.leave()
                                }
                            } else if scrollContent.type == "music" {
                                let musicRef = sdoc.reference.collection("musicList")
                                group.enter()
                                musicRef.getDocuments { musicDocs, _ in
                                    if let musicDocs = musicDocs {
                                        var musicNames: [(index: Int, name: String)] = []
                                        var musicDataArray: [(index: Int, data: Data, url: URL)] = []
                                        for (musicIndex, musicDoc) in musicDocs.documents.enumerated() {
                                            group.enter()
                                            Storage.storage().reference().child(musicDoc.data()["music"] as! String).getData(maxSize: 1024 * 1024 * 20) { data, _ in
                                                if let data = data {
                                                    musicDataArray.append((musicDoc.data()["index"] as! Int, data, URL(fileURLWithPath: musicDoc.data()["music"] as! String)))
                                                } else {
                                                    musicDataArray.append((musicDoc.data()["index"] as! Int, Data(), URL(fileURLWithPath: musicDoc.data()["music"] as! String)))
                                                }
                                                
                                                if musicIndex == musicDocs.documents.count - 1 {
                                                    musicDataArray.sort { a, b in
                                                        return a.index < b.index
                                                    }
                                                    scrollContent.data = musicDataArray.map( { $0.data } )
                                                    scrollContent.music = musicDataArray.map( { $0.url })
                                                }
                                                group.leave()
                                            }
                                            musicNames.append((musicDoc.data()["index"] as! Int, musicDoc.data()["musicName"] as! String))
                                        }
                                        musicNames.sort { a, b in
                                            return a.index < b.index
                                        }
                                        scrollContent.musicName = musicNames.map( { $0.name } )
                                    }
                                    group.leave()
                                }
                            } else {
                                scrollContent.content = sdoc.data()["content1"] as! String
                            }
                            
                            group.notify(queue: .main) {
                                scrollContents.append(scrollContent)
                            }
                        }
                    }
                    group.leave()
                    
                    group.notify(queue: .main) {
                        scrollContents.sort { a, b in
                            return a.index < b.index
                        }
                        completion((scrollContents, backgroundImage, musicData, musicURL))
                    }
                }
            }
        }
    }
}

func getShowContents(contentInfo: ContentInfo, _ completion: @escaping(_ showContents: [ShowContent]) -> Void) {
    var showContents = [ShowContent]()
    let ref = Firestore.firestore().collection("contents").document(contentInfo.id)
    let group = DispatchGroup()
    let subContentStoreRef = ref.collection("showContent")
    subContentStoreRef.getDocuments { subDocuments, err in
        if let subDocuments = subDocuments {
            for sdoc in subDocuments.documents {
                var showContent = ShowContent()
                showContent.title = sdoc.data()["title"] as! String
                showContent.text = sdoc.data()["text"] as! String
                showContent.backgroundAspectFit = sdoc.data()["backgroundAspectFit"] as! Bool
                showContent.loopPlay = sdoc.data()["bgmLoop"] as! Bool
                showContent.index = sdoc.data()["index"] as! Int
                
                if let backgroundImageURL = sdoc.data()["backgroundImage"] as? String, backgroundImageURL != "" {
                    if backgroundImageURL == "same" {
                        showContent.backgroundImage = UIImage(systemName: "circle") ?? UIImage()
                    } else {
                        group.enter()
                        Storage.storage().reference().child(backgroundImageURL).downloadURL { backgroundURL, err in
                            if let backgroundURL = backgroundURL {
                                group.enter()
                                requestImageFromURLSession(url: backgroundURL as NSURL) { image in
                                    showContent.backgroundImage = image
                                    group.leave()
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                if let imageURLStr = sdoc.data()["image"] as? String, imageURLStr != "" {
                    group.enter()
                    Storage.storage().reference().child(imageURLStr).downloadURL { imageURL, err in
                        if let imageURL = imageURL {
                            group.enter()
                            requestImageFromURLSession(url: imageURL as NSURL) { image in
                                showContent.image = image
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                }
                
                if let bgmURLStr = sdoc.data()["bgm"] as? String {
                    if bgmURLStr == "same" {
                        showContent.musicData = Data()
                    } else if bgmURLStr == "" {
                        showContent.musicData = String("nothing").data(using: .utf8) ?? Data()
                    } else {
                        showContent.music = URL(fileURLWithPath: bgmURLStr)
                        group.enter()
                        Storage.storage().reference().child(bgmURLStr).getData(maxSize: 1024 * 1024 * 20) { musicData, error in
                            if let musicData = musicData {
                                showContent.musicData = musicData
                            }
                            group.leave()
                        }
                    }
                }
                
                if let videoURLStr = sdoc.data()["video"] as? String, videoURLStr != "" {
                    group.enter()
                    Storage.storage().reference().child(videoURLStr).downloadURL { videoURL, err in
                        if let videoURL = videoURL {
                            showContent.video = videoURL
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    showContents.append(showContent)
                }
            }
        }
        
        group.notify(queue: .main) {
            showContents.sort { a, b in
                return a.index < b.index
            }
            
            for xIndex in 0..<showContents.count {
                if showContents[xIndex].backgroundImage == UIImage(systemName: "circle") {
                    showContents[xIndex].backgroundImage = showContents[xIndex - 1].backgroundImage
                }
                
                if showContents[xIndex].musicData == String("same").data(using: .utf8) {
                    showContents[xIndex].musicData = showContents[xIndex - 1].musicData
                }
            }
            
            // null content to display ArticleView.
            if showContents.count > 0 {
                showContents.append(ShowContent(index: showContents.count, backgroundImage: showContents[showContents.count - 1].backgroundImage, backgroundAspectFit: showContents[showContents.count - 1].backgroundAspectFit, music: showContents[showContents.count - 1].music, musicData: Data(), loopPlay: showContents[showContents.count - 1].loopPlay))
            }
            print("getting show content Completed")
            completion(showContents)
        }
    }
}

func getArticleContents(parentContent: ContentInfo, i: Int, _ completion: @escaping(_ articleContents: [ArticleContent]) -> Void) {
    var articleContents = [ArticleContent]()
    let ref = Firestore.firestore().collection("contents").document(parentContent.thisArticles[i].id)
    let group = DispatchGroup()
    let subContentStoreRef = ref.collection("articleContent")
    group.enter()
    subContentStoreRef.getDocuments { subDocuments, _ in
        if let subDocuments = subDocuments {
            for sdoc in subDocuments.documents {
                var articleContent = ArticleContent()
                articleContent.type = sdoc.data()["type"] as! String
                articleContent.index = sdoc.data()["index"] as! Int
                if articleContent.type == "image" {
                    group.enter()
                    Storage.storage().reference().child(sdoc.data()["content1"] as! String).downloadURL { someURL, _ in
                        if let someURL = someURL {
                            group.enter()
                            requestImageFromURLSession(url: someURL as NSURL) { image in
                                articleContent.imageData = image
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                } else if articleContent.type == "link" {
                    articleContent.webTitle = sdoc.data()["content2"] as! String
                    articleContent.content = sdoc.data()["content1"] as! String
                    group.enter()
                    Storage.storage().reference().child(sdoc.data()["content3"] as! String).downloadURL { linkURL, _ in
                        if let linkURL = linkURL {
                            group.enter()
                            requestImageFromURLSession(url: linkURL as NSURL) { image in
                                articleContent.imageData = image
                                group.leave()
                            }
                        }
                        group.leave()
                    }
                } else {
                    articleContent.content = sdoc.data()["content1"] as! String
                }
                
                group.notify(queue: .main) {
                    articleContents.append(articleContent)
                }
            }
        }
        group.leave()
        
        group.notify(queue: .main) {
            articleContents.sort { a, b in
                return a.index < b.index
            }
            completion(articleContents)
        }
    }
}

func requestImageFromURLSession(url: NSURL, _ completion: @escaping(_ image: UIImage) -> Void) {
    var dataTask: URLSessionDataTask
    let request = URLRequest(url: url as URL)
    
    dataTask = URLSession.shared.dataTask(with: request) { data, response, err in
        if let data = data {
            if let imageFromURL = UIImage(data: data) {
                completion(imageFromURL)
            } else {
                completion(UIImage())
            }
        } else {
            completion(UIImage())
        }
    }
    
    dataTask.resume()
}

func getUserNameAndIcon(id: String, _ completion: @escaping((_name: String, _icon: UIImage)) -> Void) {
    let ref = Firestore.firestore().collection("users").document(id)
    ref.getDocument { document, err in
        if let document = document {
            let name = document.data()?["name"] as? String ?? ""
            let iconURL = document.data()?["thumbnail"] as? String ?? ""
            
            if iconURL != "" {
                Storage.storage().reference(forURL: iconURL).getData(maxSize: 1024 * 1024 * 10) { data, err in
                    if let err = err {
                        print("Error: \(err)")
                    } else if let data = data {
                        let icon = UIImage(data: data) ?? UIImage()
                        completion((name, icon))
                    }
                }
            } else {
                completion((name, UIImage(named: "black2") ?? UIImage()))
            }
        }
    }
}

struct PauseMusic: ViewModifier {
    
    @StateObject var music: Music
    @StateObject var playAudio: PlayMusic
    
    func body(content: Content) -> some View {
        content
            .onChange(of: music.pauseBool) { newValue in
                if newValue == false && music.musicURL != URL(fileURLWithPath: "") {
                    playAudio.player?.play()
                } else {
                    playAudio.player?.pause()
                }
            }
    }
}

extension View {
    func pauseMusic(music: Music, playAudio: PlayMusic) -> some View {
        self.modifier(PauseMusic(music: music, playAudio: playAudio))
    }
}

func addViewCount(id: String, collection: String) {
    let contentRef = Firestore.firestore().collection(collection).document(id)
    contentRef.getDocument { snapshot, _ in
        guard let snapshot = snapshot else { return }
        let newCount = (snapshot.data()?["viewCount"] as? Int ?? 0) + 1
        print(newCount)
        contentRef.updateData(["viewCount": newCount])
    }
}

struct SearchBar: UIViewRepresentable {
    
    var placeholder: String = ""
    @Binding var text: String
    @Binding var isCancel: Bool
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.tintColor = .white
        searchBar.searchTextField.layer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.setShowsCancelButton(true, animated: false)
        if let cancelButton: UIButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        searchBar.becomeFirstResponder()
        
        return searchBar
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(searchBar: self)
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        var searchBar: SearchBar
        
        init(searchBar: SearchBar) {
            self.searchBar = searchBar
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard var result = searchBar.text else { return }
            while result.last == " " || result.last == "　" {
                result.removeLast()
            }
            self.searchBar.text = result
            searchBar.endEditing(true)
            if let cancelButton: UIButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.searchBar.isCancel = true
            searchBar.text = ""
            searchBar.endEditing(true)
        }
    }
}

struct WorldSearchView: View {
    
    @Binding var resultArray: [WorldInfo]
    @Binding var searchText: String
    @Binding var gotSearchResult: Bool
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(0)
                
                if gotSearchResult {
                    ScrollView {
                        VStack(alignment: .leading) {
                            if searchText != "" {
                                Text("\(NSLocalizedString("Result: ", comment: ""))\(resultArray.count)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                    .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 20)
                                    .padding(.bottom, 20)
                            }
                            
                            ForEach(0..<resultArray.count, id: \.self) { i in
                                NavigationLink(destination: CreatorHomeView(worldInfo: resultArray[i])) {
                                    ZStack {
                                        Image(uiImage: resultArray[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                        
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                            .foregroundColor(.black.opacity(0.2))
                                            .cornerRadius(20)
                                        
                                        VStack(alignment: .leading) {
                                            Text(resultArray[i].name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .semibold))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(1)
                                                .card()
                                            
                                            Spacer()
                                            
                                            Account(image: resultArray[i].createdUserIcon, name: resultArray[i].createdUserName, imageSize: ((UIScreen.main.bounds.size.width - 40) - 20)/10, textSize: 16)
                                                .card()
                                        }
                                        .frame(width: UIScreen.main.bounds.size.width - 60, alignment: .leading)
                                        .padding(10)
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentSearchView: View {
    
    @Binding var resultArray: [ContentInfo]
    @Binding var searchText: String
    @Binding var gotSearchResult: Bool
    @State var gotContent = false
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(0)
                
                if gotSearchResult {
                    ScrollView {
                        VStack(alignment: .leading) {
                            if searchText != "" {
                                Text("\(NSLocalizedString("Result: ", comment: ""))\(resultArray.count)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .semibold))
                                    .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                                    .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 20)
                                    .padding(.bottom, 20)
                            }
                            
                            ForEach(0..<resultArray.count, id: \.self) { i in
                                NavigationLink(destination: contentSegueView(contentInfo: resultArray[i])) {
                                    ZStack {
                                        Image(uiImage: resultArray[i].backgroundImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                        
                                        Rectangle()
                                            .frame(width: UIScreen.main.bounds.size.width - 40, height: (UIScreen.main.bounds.size.width - 40)/4)
                                            .foregroundColor(.black.opacity(0.2))
                                            .cornerRadius(20)
                                        
                                        VStack(alignment: .leading) {
                                            Text(resultArray[i].name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .semibold))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(1)
                                                .card()
                                            
                                            Spacer()
                                            
                                            Account(image: resultArray[i].createdUserIcon, name: resultArray[i].createdUserName, imageSize: ((UIScreen.main.bounds.size.width - 40) - 20)/10, textSize: 16)
                                                .card()
                                        }
                                        .frame(width: UIScreen.main.bounds.size.width - 60, alignment: .leading)
                                        .padding(10)
                                    }
                                }
                                .simultaneousGesture(TapGesture().onEnded({ _ in
                                    let group = DispatchGroup()
                                    if resultArray[i].gotContent == false {
                                        if resultArray[i].contentStyle == "scroll" {
                                            group.enter()
                                            getScrollContents(contentInfo: resultArray[i]) { scrollContents, backgroundImage, musicData, musicURL in
                                                resultArray[i].scrollContents = scrollContents
                                                resultArray[i].backgroundImage = backgroundImage
                                                resultArray[i].music = musicURL
                                                resultArray[i].musicData = musicData
                                                resultArray[i].gotContent = true
                                                group.leave()
                                            }
                                        } else if resultArray[i].contentStyle == "show" {
                                            group.enter()
                                            getShowContents(contentInfo: resultArray[i]) { showContents in
                                                resultArray[i].showContents = showContents
                                                resultArray[i].gotContent = true
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
                                .padding(.top, 10)
                            }
                        }
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder func contentSegueView(contentInfo: ContentInfo) -> some View {
        if contentInfo.contentStyle == "scroll" {
            ContentScrollView(contentInfo: contentInfo, gotContent: $gotContent)
        } else if contentInfo.contentStyle == "show" {
            ContentShowView(contentInfo: contentInfo, gotContent: $gotContent)
        }
    }
}

final class TextConverter {
    private init() {}
    enum JPCharacter {
        case hiragana
        case katakana
        fileprivate var transform: CFString {
            switch self {
            case .hiragana:
                return kCFStringTransformLatinHiragana
            case .katakana:
                return kCFStringTransformLatinKatakana
            }
        }
    }

    static func convert(_ text: String, to jpCharacter: JPCharacter) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                CFStringTransform((text as! CFMutableString), nil, jpCharacter.transform, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }
}

extension String {
    // ひらがなかどうか
    var isHiragana: Bool {
        let range = "^[ぁ-ゞ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
    // カタカナかどうか
    var isKatakana: Bool {
        let range = "^[ァ-ヾ]+$"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
    // 英数字かどうか
    var isAlphanumeric: Bool {
        let range = "[a-zA-Z0-9]+"
        return NSPredicate(format: "SELF MATCHES %@", range).evaluate(with: self)
    }
}

func searchMapArray(text: String) -> [String] {
    let replacedValue = text.replacingOccurrences(of: "　", with: " ")
    var searchWords = replacedValue.components(separatedBy: " ")
    var queryWords = [String]()
                    
    for i in 0..<searchWords.count {
        if (searchWords[i].range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil) {
            searchWords[i] = TextConverter.convert(searchWords[i], to: .katakana)
            let theWord = searchWords[i]
            for jIndex in 0..<theWord.count {
                if jIndex < theWord.count - 1 {
                    let wordIndex = theWord.index(theWord.startIndex, offsetBy: jIndex)
                    let nextIndex = theWord.index(theWord.startIndex, offsetBy: jIndex + 1)
                    let element = theWord[wordIndex...nextIndex]
                    queryWords.append(String(element))
                }
            }
            if searchWords[i].count == 1 {
                queryWords.append(searchWords[i])
            }
        } else {
            searchWords[i] = searchWords[i].localizedLowercase
            queryWords.append(searchWords[i])
        }
    }
    
    return queryWords
}

func deleteDesignatedStorageFolder(path: String) {
    Storage.storage().reference(forURL: path).listAll { result, _ in
        guard let result = result else { return }
        loopDeletingStorageFolder(result: result)
    }
}

func loopDeletingStorageFolder(result: StorageListResult) {
    for i in result.items {
        i.delete { _ in
        }
    }
    
    if result.prefixes.count > 0 {
        for i in result.prefixes {
            i.listAll { subResult, _ in
                guard let subResult = subResult else { return }
                loopDeletingStorageFolder(result: subResult)
            }
        }
    }
}

struct LoadingView: View {
        
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Rectangle()
                    .foregroundColor(.black.opacity(0.3))
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
            .ignoresSafeArea()
        }
    }
}

class FCMToken {
    func token() -> String {
        return Messaging.messaging().fcmToken ?? ""
    }
}

struct NoHighlightedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.clear : Color.clear)
    }
}

func deleteFCMTokenFromWorld(id: String, fcmTokens: [String]) {
    let ref = Firestore.firestore().collection("world").whereField("followers", arrayContains: id)
    ref.getDocuments { snapshot, _ in
        guard let snapshot = snapshot else { return }
        for i in snapshot.documents {
            let document = Firestore.firestore().collection("world").document(i.documentID)
            document.updateData(["followerTokens": FieldValue.arrayRemove(fcmTokens)])
        }
    }
}

func addFCMTokenToWorld(id: String, fcmTokens: [String]) {
    let ref = Firestore.firestore().collection("world").whereField("followers", arrayContains: id)
    ref.getDocuments { snapshot, _ in
        guard let snapshot = snapshot else { return }
        for i in snapshot.documents {
            let document = Firestore.firestore().collection("world").document(i.documentID)
            document.updateData(["followerTokens": FieldValue.arrayUnion(fcmTokens)])
        }
    }
}

func updateFCMTokenOfWorld(id: String, preTokens: [String], nowTokens: [String]) {
    let ref = Firestore.firestore().collection("world").whereField("followers", arrayContains: id)
    ref.getDocuments { snapshot, _ in
        guard let snapshot = snapshot else { return }
        for i in snapshot.documents {
            let document = Firestore.firestore().collection("world").document(i.documentID)
            document.updateData(["followerTokens": FieldValue.arrayRemove(preTokens)])
            document.updateData(["followerTokens": FieldValue.arrayUnion(nowTokens)])
        }
    }
}

struct ReportButton: View {
    
    var accountID: String
    var contentType: String
    var contentID: String
    var contentName: String
    @State var reportBool = false
    @State var doneBool = false
    
    var body: some View {
        if doneBool {
            Image(systemName: "flag.fill")
                .foregroundColor(.white.opacity(0.5))
                .card()
        } else {
            Button(action: {
                reportBool.toggle()
            }) {
                Image(systemName: "flag.fill")
                    .foregroundColor(.white)
                    .card()
            }
            .alert(isPresented: $reportBool) {
                Alert(title: Text("Do you want to report?"), message: Text("You must report only when this content or world contains objectionable things."), primaryButton: .cancel(Text("Cancel"), action: {
                    reportBool = false
                }), secondaryButton: .destructive(Text("Report"), action: {
                    let ref = Firestore.firestore().collection("reports")
                    ref.addDocument(data: [
                        "idOfUserReported": accountID,
                        "reportedContentID": contentID,
                        "reportedContentType": contentType,
                        "reportedContentName": contentName,
                        "reportedDate": Date()
                    ])
                    reportBool = false
                    doneBool.toggle()
                }))
            }
        }
    }
}

func requestFirebaseSnapshot(ref: CollectionReference, whereField: String, equalTo: Any, _ completion: @escaping(_ snapshot: QuerySnapshot) -> Void) {
    if whereField == "" {
        ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            completion(snapshot)
        }
    } else {
        let query = ref.whereField(whereField, isEqualTo: equalTo)
        query.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            completion(snapshot)
        }
    }
}

extension Color {
    static let chaosBlack = Color("chaosBlack")
}

struct ChatBar: View {
    
    @State var textFieldText = ""
    @State var textingHeight = CGFloat(40)
    @Binding var photoLibraryShow: Bool
    @ObservedObject var keyboard = KeyboardObserver()
    @EnvironmentObject var textingBool: TextingBool
    @EnvironmentObject var accountInfo: AccountInfo
    @EnvironmentObject var chatBoardID: ChatBoardID
    @EnvironmentObject var tabBarHidden: TabBarHidden
    
    var body: some View {
        ZStack {
            if textingBool.bool && tabBarHidden.hidden {
                VStack {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.size.width, height: 50)
                            .foregroundColor(.white.opacity(0.00001))
                            .padding(.bottom, 0)
                        
                        HStack(alignment: .bottom) {
                            Button(action: {
                                photoLibraryShow = true
                                UIApplication.shared.closeKeyboard()
                                textingBool.bottomHeight = bottomInsetHeight()
                                textingBool.bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
                            }) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 24, alignment: .trailing)
                                    .padding(.trailing, 5)
                                    .foregroundColor(.white)
                                    .card()
                            }
                            .padding(.leading, 10)
                            .padding(.bottom, 5)
                            
                            ZStack(alignment: .center) {
                                TextingView(text: $textFieldText, height: $textingHeight, placeholder: NSLocalizedString("Add Comment", comment: ""))
                                    .frame(height: textingHeight)
                            }
                            
                            Button(action: {
                                if textFieldText != "" {
                                    let ref = Firestore.firestore().collection("chatBoard").document(chatBoardID.id).collection("chatContent")
                                    ref.addDocument(data: [
                                        "content": textFieldText,
                                        "date": Date(),
                                        "userID": accountInfo.id,
                                        "images": [],
                                        "resizeImages": []
                                    ])
                                    chatBoardID.chatAdded = true
                                }
                                textFieldText = ""
                            }) {
                                Image(systemName: "paperplane")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 24, alignment: .leading)
                                    .padding(.leading, 5)
                                    .foregroundColor(.white)
                                    .card()
                            }
                            .padding(.trailing, 10)
                            .padding(.bottom, 5)
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.bottom, 0)
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width, height: textingBool.bottomHeight)
                        .onChange(of: keyboard.keyboardHeight, perform: { newValue in
                            if newValue > 60 {
                                textingBool.keyboardHeight = newValue
                                withAnimation(.easeOut(duration: 0.235)) {
                                    textingBool.bottomHeight = newValue - 10
                                }
                            }
                        })
                        .onWillAppear {
                            DispatchQueue.main.async {
                                textingBool.bottomHeight = bottomInsetHeight()
                            }
                        }
                        .foregroundColor(.clear)
                }
                .gesture(DragGesture().onChanged({ value in
                    if value.translation.height > 40 {
                        UIApplication.shared.closeKeyboard()
                        textingBool.keyboardHeight = 0
                        textingBool.bottomHeight = bottomInsetHeight()
                    }
                }))
                .accentColor(.black)
            }
        }
    }
}
