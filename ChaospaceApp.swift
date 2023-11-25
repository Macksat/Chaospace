//
//  ChaospaceApp.swift
//  Shared
//
//  Created by Sato Masayuki on 2022/01/19.
//

import SwiftUI
import Firebase
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import GoogleMobileAds
import FirebaseMessaging
import RealmSwift

@main
struct ChaospaceApp: SwiftUI.App {
    
    let nameObject = Name()
    let textingBool = TextingBool()
    let webViewVar = WebViewVaridates()
    let accountInfo = AccountInfo()
    let music = Music()
    let playAudio = PlayMusic()
    let chatBoardID = ChatBoardID()
    let tabBarHidden = TabBarHidden()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.55)
        
        UICollectionView.appearance().backgroundColor = .clear
        
        UIDatePicker.appearance().tintColor = .darkGray
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(nameObject)
                .environmentObject(textingBool)
                .environmentObject(webViewVar)
                .environmentObject(accountInfo)
                .environmentObject(music)
                .environmentObject(playAudio)
                .environmentObject(chatBoardID)
                .environmentObject(tabBarHidden)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    
    @Published var notifiedWorldID = ""
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        firebaseConfigure()
        
        let setting = FirestoreSettings()
        setting.isPersistenceEnabled = true
        setting.cacheSizeBytes = 1024 * 1024 * 1024
        Firestore.firestore().settings = setting
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
                
        return true
    }
    
    func firebaseConfigure() {
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        //let filePath = Bundle.main.path(forResource: "GoogleService-forTest-Info", ofType: "plist")
        guard let filePath = filePath else { return }
        guard let options = FirebaseOptions(contentsOfFile: filePath) else { return }
        
        FirebaseApp.configure(options: options)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let realm = try! Realm()
        if let userInfo = realm.objects(DeviceUser.self).first {
            if userInfo.fcmToken != fcmToken {
                let ref = Firestore.firestore().collection("users").document(userInfo.accountID)
                ref.updateData(["fcmToken": FieldValue.arrayRemove([userInfo.fcmToken])])
                ref.updateData(["fcmToken": FieldValue.arrayUnion([fcmToken ?? ""])])
                updateFCMTokenOfWorld(id: userInfo.accountID, preTokens: [userInfo.fcmToken], nowTokens: [fcmToken ?? ""])
                
                try! realm.write {
                    userInfo.fcmToken = fcmToken ?? ""
                }
            }
        }
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        //if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            //return true
        //}
        // other URL handling goes here.
        //return false
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.banner, .badge, .list, .sound])
    }

    // 通知センター等でプッシュ通知をタップした場合に呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let worldID = userInfo["worldID"] as? String
        print("world id: \(worldID ?? "")")
        notifiedWorldID = worldID ?? ""
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct CustomBackButtonView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .card()
        }
    }
}

struct GradientNavigationBar: View {
    
    let gradient = LinearGradient(colors: [.black.opacity(0.6), .black.opacity(0)], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(gradient)
                .frame(width: UIScreen.main.bounds.size.width, height: UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                .padding(.top, 0)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}

struct CustomBackButton: ViewModifier {
    
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .card()
                    }
                }
            }
    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButton())
    }
}
