//
//  CustomTabbar.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/04/05.
//

import SwiftUI

struct CustomTabbar<Content: View>: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func makeCoordinator() -> () {
        return Coordinator()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
