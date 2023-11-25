//
//  DataSet.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/07/31.
//

import Foundation
import SwiftUI
import RealmSwift
import Firebase
import FirebaseAuth

class DeviceUser: Object {
    @objc dynamic var email = ""
    @objc dynamic var accountID = ""
    @objc dynamic var fcmToken = ""
}

class FirebaseAuthStateObserver: ObservableObject {
    @Published var isSignIn: Bool = false
    @Published var email: String = ""
    private var listener: AuthStateDidChangeListenerHandle!

    init() {
        listener = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("sign-in")
                self.isSignIn = true
                self.email = user.email ?? ""
            } else {
                print("sign-out")
                self.isSignIn = false
                self.email = ""
            }
        }
    }

    deinit {
        Auth.auth().removeStateDidChangeListener(listener)
    }
}

class Name: ObservableObject {
    @Published var name = ""
}

class LoadObserver: ObservableObject {
    @Published var isLoading = false
    @Published var opacity = Double(0)
}

class ChatBoardID: ObservableObject {
    @Published var id: String = ""
    @Published var chatAdded: Bool = false
}

class TabBarHidden: ObservableObject {
    @Published var hidden = false
}

class Music: ObservableObject {
    @Published var musicURL = URL(fileURLWithPath: "")
    @Published var musicMuteBool = true
    @Published var musicLoop = false
    @Published var pauseBool = true
    @Published var listPressed = false
    @Published var finished = false // <- Signal to go to the next music.
    @Published var listIndex = 0 // <- Not to influence other player's behaviour on the same view.
}

class TextingBool: ObservableObject {
    @Published var bool = false
    @Published var keyboardHeight = CGFloat(0)
    @Published var bottomHeight = CGFloat(bottomInsetHeight())
    @Published var bottomPadding = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 10
}

struct ChatImage: Identifiable {
    var id: String = ""
    var image: UIImage = UIImage()
}

struct Chat: Identifiable {
    var id: String = ""
    var name: String = ""
    var icon: UIImage = UIImage()
    var userID: String = ""
    var content: String = ""
    var images: [UIImage] = []
    var date: String = ""
    var dateValue: Date = Date()
    var chatImages: [ChatImage] = []
    var height: CGFloat = CGFloat(0)
}

class ChatBoard: ObservableObject {
    @Published var chatName = ""
    @Published var explanation = ""
    @Published var conditionBool = false
    @Published var condition = 0
    @Published var boardID = ""
    @Published var parentWorld = ""
    @Published var createdDate = Date()
    @Published var updatedDate = Date()
    @Published var createdUser = ""
    @Published var createdUserIcon = UIImage(named: "black2") ?? UIImage()
    @Published var userID = ""
    @Published var chats: [Chat] = []
}

class WorldInfo: ObservableObject {
    @Published var id: String = ""
    @Published var backgroundImage: UIImage = UIImage(named: "black") ?? UIImage()
    @Published var backgroundURL: String = ""
    @Published var name: String = ""
    @Published var explanation: String = ""
    @Published var bgm: String = ""
    @Published var bgmURL: URL = URL(fileURLWithPath: "")
    @Published var bgmData: Data = Data()
    @Published var bgmName: String = ""
    @Published var tags: [String] = []
    @Published var category: [String] = []
    @Published var chatBoards: [ChatBoard] = []
    @Published var contentCategory: [ContentCategory] = []
    @Published var announcements: [Announcement] = []
    @Published var createdUser: String = ""
    @Published var createdUserName: String = ""
    @Published var createdUserIcon: UIImage = UIImage(named: "black2") ?? UIImage()
    @Published var following: Bool = false
    @Published var createdDate: Date = Date()
    @Published var updatedDate: Date = Date()
    @Published var deleted: Bool = false
}

class ContentCategory: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var backgroundImage: UIImage = UIImage(named: "black") ?? UIImage()
    @Published var backgroundURL: String = ""
    @Published var id: String = ""
    @Published var contents: [ContentInfo] = []
    @Published var opacity: Double = 1
    @Published var index: Int = 0
}

class Announcement: ObservableObject {
    @Published var id: String = ""
    @Published var content: String = ""
    @Published var name: String = ""
    @Published var index: Int = 0
    @Published var categoryIndex: Int = 0
    @Published var image: UIImage = UIImage()
    @Published var opacity: Double = 1
    @Published var space: CGFloat = 20
}

class AccountInfo: ObservableObject {
    @Published var iconImage: UIImage = UIImage(named: "black2") ?? UIImage()
    @Published var iconURL: String = ""
    @Published var backgroundImage: UIImage = UIImage(named: "black") ?? UIImage()
    @Published var backgroundURL: String = ""
    @Published var name: String = ""
    @Published var profile: String = ""
    @Published var born: Date = Date()
    @Published var id: String = ""
    @Published var createdContents: [ContentInfo] = []
    @Published var createdWorlds: [WorldInfo] = []
    @Published var readChats: [(readID: String, chatID: String, readPoint: Int)] = []
    @Published var email: String = ""
    @Published var fcmTokens: [String] = []
    @Published var createdDate: Date = Date()
    @Published var accountID: String = ""
    @Published var gender: String = ""
    @Published var blockedUsers: [String] = []
}

struct ScrollContent: Hashable {
    var type: String = ""
    var content: String = ""
    var height: CGFloat = 0.0
    var image: UIImage = UIImage()
    var opacity: Double = 1.0
    var bottomHeight: Double = 10.0
    var url: String = ""
    var videoURL: URL = URL(fileURLWithPath: "")
    var imageURL: URL = URL(fileURLWithPath: "")
    var music: [URL] = []
    var data: [Data] = []
    var musicName: [String] = []
    var index: Int = 0
}

struct ShowContent: Hashable {
    var index: Int = 0
    var title: String = ""
    var text: String = ""
    var image: UIImage = UIImage()
    var imageURL: URL = URL(fileURLWithPath: "")
    var video: URL = URL(fileURLWithPath: "")
    var backgroundImage: UIImage = UIImage(named: "black") ?? UIImage()
    var backgroundAspectFit = true
    var music: URL = URL(fileURLWithPath: "")
    var musicData: Data = Data()
    var loopPlay: Bool = true
    var stopBool: Bool = true
    var opacity: Double = 1.0
    var height: CGFloat = 0.0
    var bottomHeight: CGFloat = 20.0
}

struct ArticleContent: Hashable {
    var type: String = ""
    var content: String = ""
    var height: CGFloat = 0.0
    var imageData: UIImage = UIImage()
    var opacity: Double = 1.0
    var buttonHeight: CGFloat = 10.0
    var webTitle: String = ""
    var index: Int = 0
}

class ContentInfo: ObservableObject {
    @Published var id: String = ""
    @Published var backgroundImage: UIImage = UIImage(named: "black") ?? UIImage()
    @Published var backgroundAspectFit: Bool = true
    @Published var loopPlay: Bool = true
    @Published var music: URL = URL(fileURLWithPath: "")
    @Published var musicData: Data = Data()
    @Published var name: String = ""
    @Published var explanation: String = ""
    @Published var contentStyle: String = "scroll"
    @Published var scrollContents: [ScrollContent] = []
    @Published var showContents: [ShowContent] = []
    @Published var articleContents: [ArticleContent] = []
    @Published var thisArticles: [ContentInfo] = []
    @Published var parentWorld: String = ""
    @Published var parentCategory: String = ""
    @Published var createdUserID: String = ""
    @Published var createdUserName: String = ""
    @Published var createdUserIcon: UIImage = UIImage(named: "black2") ?? UIImage()
    @Published var createdDate: Date = Date()
    @Published var updatedDate: Date = Date()
    @Published var gotContent: Bool = false
    @Published var likes: [String] = []
    @Published var isFavorite: Bool = false
    @Published var deleted: Bool = false
}

class WebViewVaridates: ObservableObject {
    @Published var goF = false
    @Published var goB = false
    @Published var nowURL = ""
    @Published var title = ""
    @Published var image = UIImage()
}
