//
//  BackgroundView.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/23/25.
//

import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        ZStack {
            // Radial Gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8), // Center color
                    Color.black // Edge color
                ]),
                center: .center,
                startRadius: 10,
                endRadius: 300
            )
            .edgesIgnoringSafeArea(.all)
            
            // Overlay Linear Gradient (optional for extra depth)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.5),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct GradientBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        GradientBackgroundView()
    }
}
