//
//  LogInView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/09/19.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import RealmSwift

struct StartAppView: View {
    
    @State var goSignIn = false
    @State var appearTerms = false
    @State var agreeTerms = false
    @State var checkedTerms = false
    @State var authResult: AuthDataResult?
    @StateObject var authObserver = FirebaseAuthStateObserver()
    @Binding var goRootView: Bool
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                NavigationLink(destination: CustomSignInView(goRootView: $goRootView), isActive: $goSignIn) {
                    EmptyView()
                }
                
                BackgroundImage(image: "black", opacity: 0)
                
                VStack(alignment: .center, spacing: 24) {
                    Image("Chaospace_logo_dark_trans")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.size.height / 2 - 144 - (UINavigationController().navigationBar.frame.size.height + statusBarSize()), height: UIScreen.main.bounds.size.height / 2 - 144 - (UINavigationController().navigationBar.frame.size.height + statusBarSize()))
                    
                    Text("Welcome to Chaospace!!")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, -16)
                   
                    Spacer()
                    
                    Button(action: {
                        if agreeTerms == false {
                            appearTerms = true
                        } else {
                            goSignIn.toggle()
                        }
                    }) {
                        Text("Get Started")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .medium))
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.white, lineWidth: 3)
                            )
                            .card()
                    }
                    .alert(isPresented: $appearTerms) {
                        Alert(title: Text("I agree with privacy policy and terms."), primaryButton: .default(Text("No")), secondaryButton: .default(Text("Yes"), action: {
                            UserDefaults.standard.set(true, forKey: "agreeWithTerms")
                            agreeTerms = true
                            goSignIn.toggle()
                        }))
                    }
                    .padding(.bottom, 80)
                    
                    if let url = URL(string: "https://sites.google.com/view/chaospace-privacypolicy/%E3%83%9B%E3%83%BC%E3%83%A0") {
                        Link(destination: url) {
                            if #available(iOS 16.0, *) {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .underline()
                            } else {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize())
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 24)
            }
        }
        .ignoresSafeArea()
        .onWillAppear {
            if UserDefaults.standard.bool(forKey: "agreeWithTerms") {
                agreeTerms = true
            }
        }
    }
}

struct CustomSignInView: View {
    
    let realm = try! Realm()
    @State var email = ""
    @State var textEmail = ""
    @State var password = ""
    @State var goCreateAccount = false
    @State var wrongInfo = false
    @State var isDisappear = false
    @State var authResult: AuthDataResult?
    @StateObject var authObserver = FirebaseAuthStateObserver()
    @Binding var goRootView: Bool
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                NavigationLink(destination: CreateAccountView(email: email, goRootView: $goRootView, authResult: $authResult), isActive: $goCreateAccount) {
                    EmptyView()
                }
                
                BackgroundImage(image: "black", opacity: 0)
                
                VStack(alignment: .center, spacing: 24) {
                    Image("Chaospace_logo_dark_trans")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.size.height / 2 - 144 - (UINavigationController().navigationBar.frame.size.height + statusBarSize()), height: UIScreen.main.bounds.size.height / 2 - 144 - (UINavigationController().navigationBar.frame.size.height + statusBarSize()))
                    
                    Text("Sign in with Following Ways")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, -16)
                    
                    VStack(spacing: 0) {
                        TextField("Email", text: $textEmail)
                            .onChange(of: textEmail, perform: { newValue in
                                email = newValue
                            })
                            .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            .foregroundColor(.black)
                        
                        SecureField("Password", text: $password)
                            .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            .foregroundColor(.black)
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 80)
                    .background(.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    AppleSignInView()
                        .frame(width: 196, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    GoogleSignInView()
                        .frame(width: 196, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    NavigationLink(destination: EmailSignUpView(goRootView: $goRootView)) {
                        Text("Sign up with Email")
                            .underline()
                            .foregroundColor(.white)
                            .card()
                    }
                    
                    Spacer()
                    
                    if let url = URL(string: "https://sites.google.com/view/chaospace-privacypolicy/%E3%83%9B%E3%83%BC%E3%83%A0") {
                        Link(destination: url) {
                            if #available(iOS 16.0, *) {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .underline()
                            } else {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize())
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 24)
            }
        }
        .ignoresSafeArea()
        .onWillAppear {
            isDisappear = false
        }
        .onWillDisappear {
            isDisappear = true
        }
        .onChange(of: authObserver.isSignIn, perform: { value in
            if isDisappear == false {
                if value {
                    let ref = Firestore.firestore().collection("users").whereField("email", isEqualTo: authObserver.email)
                    ref.getDocuments { snapshot, err in
                        if let err = err {
                            print(err)
                        } else {
                            guard let snapshot = snapshot else { return }
                            if snapshot.documents.count > 0 {
                                addUserData(email: authObserver.email, accountID: snapshot.documents.first?.documentID ?? "")
                            } else {
                                email = authObserver.email
                                goCreateAccount = true
                            }
                        }
                    }
                }
            }
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if email != "" && password != "" {
                    Button(action: {
                        Auth.auth().signIn(withEmail: email, password: password) { _, err in
                            if let err = err {
                                print(err)
                                wrongInfo = true
                            } else {
                                let ref = Firestore.firestore().collection("users").whereField("email", isEqualTo: email)
                                ref.getDocuments { snapshot, _ in
                                    guard let snapshot = snapshot else { return }
                                    if snapshot.documents.count > 0 {
                                        addUserData(email: email, accountID: snapshot.documents.first?.documentID ?? "")
                                    } else {
                                        goCreateAccount = true
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Sign in")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    }
                    .alert(isPresented: $wrongInfo, content: {
                        Alert(title:Text( "Email address or password is wrong."),
                              message: Text("Please enter correct email address and password."),
                              dismissButton: .default(Text("OK"), action: {
                                wrongInfo = false
                        }))
                    })
                } else {
                    Text("Sign in")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                }
            }
        }
    }
    
    func addUserData(email: String, accountID: String) {
        let userData = DeviceUser()
        userData.email = email
        userData.accountID = accountID
        
        let objects = realm.objects(DeviceUser.self)
        try! realm.write {
            realm.delete(objects)
        }
        try! realm.write {
            realm.add(userData)
        }
        
        goRootView = false
    }
}

struct EmailSignUpView: View {
    
    let realm = try! Realm()
    @State var email = ""
    @State var password = ""
    @State var goCreateAccount = false
    @State var alreadyExsist = false
    @State var authResult: AuthDataResult?
    @Binding var goRootView: Bool
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                NavigationLink(destination: CreateAccountView(email: email, password: password, goRootView: $goRootView, authResult: $authResult), isActive: $goCreateAccount) {
                    EmptyView()
                }
                
                BackgroundImage(image: "black", opacity: 0)
                
                VStack(alignment: .center, spacing: 16) {
                    VStack(spacing: 0) {
                        TextField("Email", text: $email)
                            .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            .foregroundColor(.black)
                        
                        SecureField("Password", text: $password)
                            .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            .foregroundColor(.black)
                    }
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 80)
                    .background(.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Text("You must use a password with 8 or more characters.")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                    
                    Spacer()
                    
                    if let url = URL(string: "https://sites.google.com/view/chaospace-privacypolicy/%E3%83%9B%E3%83%BC%E3%83%A0") {
                        Link(destination: url) {
                            if #available(iOS 16.0, *) {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .underline()
                            } else {
                                Text("Privacy policy and terms")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 24)
            }
        }
        .ignoresSafeArea()
        .navigationBarTitle(Text(""), displayMode: .inline)
        .customBackButton()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if email != "" && password != "" && password.count >= 8 {
                    Button(action: {
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, err in
                            if let err = err {
                                print(err)
                                alreadyExsist = true
                            } else {
                                guard let authResult = authResult else { return }
                                self.authResult = authResult
                                goCreateAccount = true
                            }
                        }
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .bold()
                            .card()
                    }
                    .alert(isPresented: $alreadyExsist, content: {
                        Alert(title:Text( "This email adress is already used."),
                              message: Text("Try to use the other email adress."),
                              dismissButton: .default(Text("OK"), action: {
                                alreadyExsist = false
                        }))
                    })
                } else {
                    Text("Next")
                        .foregroundColor(.white.opacity(0.5))
                        .bold()
                        .card()
                }
            }
        }
    }
}

struct CreateAccountView: View {
    
    let realm = try! Realm()
    let email: String
    let topHeight = UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10
    let bottomHeight = UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 24
    var password: String = ""
    @State var nickname = ""
    @State var accountID = ""
    @State var birthDay = Date()
    @State var gender = 0
    @State var idExsist = false
    @Binding var goRootView: Bool
    @Binding var authResult: AuthDataResult?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                BackgroundImage(image: "black", opacity: 0)
                
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Nickname")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .card()
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 40)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("Enter Your Nickname", text: $nickname)
                                    .foregroundColor(.black)
                                    .background(.clear)
                                    .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 16)
                            
                            Text("Account ID")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .semibold))
                                .card()
                                .padding(.top, 40)
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 40)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("Enter Your Account ID", text: $accountID)
                                    .foregroundColor(.black)
                                    .background(.clear)
                                    .frame(width: UIScreen.main.bounds.size.width - 56, height: 40, alignment: .center)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 16)
                        }
                        .padding([.leading, .trailing], 20)
                        
                        Spacer()
                        
                        if let url = URL(string: "https://sites.google.com/view/chaospace-privacypolicy/%E3%83%9B%E3%83%BC%E3%83%A0") {
                            Link(destination: url) {
                                if #available(iOS 16.0, *) {
                                    Text("Privacy policy and terms")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white)
                                        .underline()
                                } else {
                                    Text("Privacy policy and terms")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.bottom, 0)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.size.height - topHeight - bottomHeight)
                    .padding(.top, UINavigationController().navigationBar.frame.size.height + statusBarSize() + 10)
                    .padding(.bottom, UITabBarController().tabBar.frame.size.height + bottomInsetHeight() + 24)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    if let authResult = authResult {
                        authResult.user.delete()
                    }
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .card()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if nickname != "", accountID != "" {
                    Button(action: {
                        let idRef = Firestore.firestore().collection("users").whereField("accountID", isEqualTo: accountID)
                        idRef.getDocuments { snapshot, _ in
                            guard let snapshot = snapshot else { return }
                            if snapshot.documents.count > 0 {
                                idExsist = true
                            } else {
                                var genderStr = ""
                                switch gender {
                                case 1:
                                    genderStr = "Male"
                                case 2:
                                    genderStr = "Female"
                                case 3:
                                    genderStr = "Other"
                                default:
                                    genderStr = ""
                                }
                                
                                let ref = Firestore.firestore().collection("users")
                                let document = ref.addDocument(data: [
                                    "name": nickname,
                                    "accountID": accountID,
                                    "born": birthDay,
                                    "gender": genderStr,
                                    "email": email.lowercased(),
                                    "profile": "",
                                    "backgroundImage": "",
                                    "thumbnail": "",
                                    "createdDate": Date(),
                                    "updatedDate": Date(),
                                    "blockedUsers": []
                                ])
                                
                                let userData = DeviceUser()
                                userData.email = email.lowercased()
                                userData.accountID = document.documentID
                                try! realm.write {
                                    realm.add(userData)
                                }
                                
                                goRootView.toggle()
                            }
                        }
                    }) {
                        Text("Sign up")
                            .bold()
                            .foregroundColor(.white)
                            .card()
                    }
                    .alert(isPresented: $idExsist) {
                        Alert(title: Text("This account ID is already used."), message: Text("Try to use the other account ID."), dismissButton: .default(Text("OK"), action: {
                            idExsist = false
                        }))
                    }
                } else {
                    Text("Sign up")
                        .bold()
                        .foregroundColor(.white.opacity(0.5))
                        .card()
                }
            }
        }
    }
}
