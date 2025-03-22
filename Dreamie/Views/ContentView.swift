// ContentView.swift
//test comments
import SwiftUI
import RealityKit
import RealityKitContent
import Photos

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            VStack {
                Text("Welcome to your dream world")
                    .font(.largeTitle)
                
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
