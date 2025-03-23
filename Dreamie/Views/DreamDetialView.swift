import SwiftUI

struct DreamDetailView: View {
    let dream: DreamEntry
    @Environment(\.dismiss) private var dismiss
    @State private var showingSpatialView = false
    
    var body: some View {
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
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button {
                showingSpatialView = true
            } label: {
                // GENERATE AI IMAGE HERE MAYBE
                Label("Visualize Photo", systemImage: "sparkles.rectangle.stack")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 700, height: 500)
        .sheet(isPresented: $showingSpatialView) {
            SpatialPhotoView(dream: dream)
                .environment(SpatialPhotoViewModel())
        }
    }
}
