//
//  SwiftUIView.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/11.
//

import SwiftUI

struct SwiftUIView: UIViewRepresentable {
    let count: Int

        func makeUIView(context: Context) -> UILabel {
            UILabel()
        }

        func updateUIView(_ uiLabel: UILabel, context: Context) {
            uiLabel.text = "I am a UILabel and count is \(count)"
        }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
