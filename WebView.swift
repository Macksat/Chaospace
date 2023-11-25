//
//  WebView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/04/22.
//

import SwiftUI
import WebKit
import UIKit

struct WebView: View {
    
    var viewName: String = ""
    var addBool: Bool = false
    @State var showWebView: ShowWebView
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var webViewVar: WebViewVaridates
    
    var body: some View {
        NavigationView {
            showWebView
                .navigationBarTitle(Text(webViewVar.nowURL), displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                            webViewVar.nowURL = ""
                            webViewVar.goB = false
                            webViewVar.goF = false
                        }) {
                            Image(systemName: "multiply")
                                .foregroundColor(Color.init(uiColor: .systemBlue))
                        }
                        
                        Button(action: {
                            if webViewVar.goB {
                                showWebView.goBack()
                            }
                        }) {
                            if webViewVar.goB {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(Color.init(uiColor: .systemBlue))
                            } else {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(Color.init(uiColor: .gray))
                            }
                        }
                        
                        Button(action: {
                            if webViewVar.goF {
                                showWebView.goForward()
                            }
                        }) {
                            if webViewVar.goF {
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color.init(uiColor: .systemBlue))
                            } else {
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color.init(uiColor: .gray))
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            showWebView.reload()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color.init(uiColor: .systemBlue))
                        }
                        
                        if addBool == true {
                            Button(action: {
                                webViewVar.title = showWebView.webView.title ?? webViewVar.nowURL
                                webViewVar.image = getScreenShot()
                                
                                dismiss()
                            }) {
                                Text("Add")
                                    .foregroundColor(Color.init(uiColor: .systemBlue))
                                    .bold()
                            }
                        }
                    }
                }
        }
    }
    
    func getScreenShot() -> UIImage {
        let rect = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            showWebView.webView.layer.render(in: context)
            let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()

            return capturedImage
        } else {
            return UIImage()
        }
    }
}

//struct WebView_Previews: PreviewProvider {
    //static var previews: some View {
        //WebView()
    //}
//}
