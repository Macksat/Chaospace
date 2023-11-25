//
//  CreatorHomeSettingView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/06/04.
//

import SwiftUI

struct CreatorHomeSettingView: View {
    
    @State var image = UIImage(named: "palow")!
    @State var worldName = "World Name"
    
    var body: some View {
        ZStack {
            BackgroundUIImage(image: image, opacity: 0.2)
            
            ScrollView {
                
            }
            
            GradientNavigationBar()
        }
    }
}

struct CreatorHomeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorHomeSettingView()
    }
}
