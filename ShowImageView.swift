//
//  ShowImageView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/21.
//

import SwiftUI

struct ShowImageView: View {
    
    var image: UIImage
    @Binding var showImageBool: Bool
    @Binding var barHidden: Bool
    @EnvironmentObject var name: Name
    @EnvironmentObject var tabBarHidden: TabBarHidden
    @Binding var preName: String
    @Binding var opacity: Double
    
    func imageFrame(image: UIImage) -> CGRect {
        var frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: image.size.height*UIScreen.main.bounds.size.width/image.size.width)
        if frame.size.height > UIScreen.main.bounds.height {
            let imageHeight = UIScreen.main.bounds.size.height
            let imageWidth = imageHeight * image.size.width / image.size.height
            frame.size.width = imageWidth
            frame.size.height = imageHeight
        }
        
        return frame
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            ZoomableScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            if barHidden == false {
                GradientNavigationBar()
            }
        }
        .onWillAppear {
            name.name = "ShowImageView"
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
        }
        .onWillDisappear {
            name.name = preName
        }
        .gesture(TapGesture().onEnded({ _ in
            barHidden.toggle()
            tabBarHidden.hidden = barHidden
        }))
        .gesture(DragGesture()
            .onEnded({ value in
                if value.translation.height > 50 || value.translation.height < -50 {
                    backFunc()
                }
                if value.translation.width > 50 || value.translation.width < -50 {
                    backFunc()
                }
            })
        )
        .navigationBarBackButtonHidden(true)
        .background(.black.opacity(opacity))
        .navigationBarTitle(Text(""), displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
    }
    
    func backFunc() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0.0
        }
        self.name.name = preName
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showImageBool = false
        }
    }
}

//struct ShowImageView_Previews: PreviewProvider {
    //static var previews: some View {
        //ShowImageView(image: "adtechno4")
    //}
//}
