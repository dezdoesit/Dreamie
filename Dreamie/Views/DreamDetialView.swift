import SwiftUI
import AVFoundation


struct DreamDetailView: View {
    let dream: DreamEntry
    @Environment(\.dismiss) private var dismiss
    @State private var showingSpatialView = false
    @State private var dreamStorage = DreamStorageService()
    @State private var viewModel = SpatialPhotoViewModel(dreamStorage: DreamStorageService())
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.purple.opacity(0.8),
                    Color.black
                ]),
                center: .center,
                startRadius: 540,
                endRadius: 880
            )
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                
                Text(dream.title)
                    .font(.largeTitle)
                    .padding(.horizontal)
                
                Text(dream.date.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                ScrollView {
                    Text(dream.content)
                        .padding()
                    Text(dream.aiStory ?? "")
                        .padding()
                    
                    
                    // Display spatial photo thumbnail if available
                    if let photoData = dream.spatialPhotoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                Button {
                    if let urlString = dream.spatialPhotoURL, let url = URL(string: urlString) {
                        // If we already have a spatial photo, open it directly
                        viewModel.spawnView = url
                        Task {
                            print(url, "SPAWNVIEW 2")
                            await viewModel.SPAWNVIEW()
                            startTextToSpeech()
                        }
                    } else {
                        // Otherwise, show the spatial photo creation view
                        showingSpatialView = true
                    }
                } label: {
                    Label(
                        dream.spatialPhotoURL != nil ? "View Spatial Photo" : "Create Spatial Photo",
                        systemImage: dream.spatialPhotoURL != nil ? "eye" : "sparkles.rectangle.stack"
                    )
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .background(Color.purple.opacity(0.8))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(width: 700, height: 500)
            .sheet(isPresented: $showingSpatialView) {
                SpatialPhotoView(dream: dream).environment(viewModel)
            }
            .padding()
            .onAppear {
                // Initialize the view model with the dream storage
                Task {
                    // This ensures we're using the latest dream data with any spatial photo updates
                    if let updatedDream = try? await dreamStorage.getDream(with: dream.id) {
                        // In a real app, you'd need to handle updating the dream reference
                        // This is a simplified approach for demonstration
                        if let urlString = updatedDream.spatialPhotoURL, let url = URL(string: urlString) {
                            viewModel.spawnView = url
                        }
                    }
                }
            }
        }
    }
    
    func startTextToSpeech() {
        let speechSynthesizer = AVSpeechSynthesizer()
          let speechUtterance = AVSpeechUtterance(string: dream.aiStory ?? "There is no story")
          speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
          speechSynthesizer.speak(speechUtterance)
      }
}
