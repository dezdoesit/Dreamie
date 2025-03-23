// ContentView.swift
//test comments
import SwiftUI
import RealityKit
import RealityKitContent
import Photos
import SwiftUI
import QuickLook
import PhotosUI



struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.8),
                        Color.black
                    ]),
                    center: .center,
                    startRadius: 560,
                    endRadius: 880
                )
                .edgesIgnoringSafeArea(.all)
                VStack {
                    PickerView()
                    
                }
            }
            
            
            .tabItem {
                
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            // Record Dream tab
            DreamRecordingView()
                .tabItem {
                    Label("Record Dream", systemImage: "mic")
                }
                .tag(1)
            
            // Dream List tab
            DreamListView()
                .tabItem {
                    Label("Dream Journal", systemImage: "book")
                }
                .tag(2)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
        .environment(DreamViewModel())
}


