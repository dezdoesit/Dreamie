// DreamieApp.swift
import SwiftUI

@main
struct DreamieApp: App {
    @State private var appModel = AppModel()
    @State private var dreamViewModel = DreamViewModel()
    @State private var spatialPhotoViewModel = SpatialPhotoViewModel(dreamStorage: DreamStorageService())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(dreamViewModel)
                .environment(spatialPhotoViewModel)
        }
      
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
