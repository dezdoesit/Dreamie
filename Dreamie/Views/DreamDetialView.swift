//
//  DreamDetialView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//
import SwiftUI

struct DreamDetailView: View {
    let dream: DreamEntry
    @Environment(\.dismiss) private var dismiss
    
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
            
            Spacer()
        }
        .frame(width: 700, height: 500)
    }
}
