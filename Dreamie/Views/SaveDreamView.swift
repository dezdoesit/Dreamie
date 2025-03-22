//
//  SaveDreamView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//
import SwiftUI

struct SaveDreamView: View {
    @Environment(DreamViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var dreamTitle = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Your Dream")
                .font(.title)
                .padding(.top)
            
            TextField("Dream Title", text: $dreamTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            ScrollView {
                Text(viewModel.transcribedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Button("Save") {
                    viewModel.currentDream.title = dreamTitle
                    Task {
                        await viewModel.saveDream()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .frame(width: 600, height: 450)
    }
}
