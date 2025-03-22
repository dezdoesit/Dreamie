//
//  DreamListView.swift
//  Dreamie
//
//  Created by Dezmond Blair on 3/22/25.
//

import SwiftUI

struct DreamListView: View {
    @Environment(DreamViewModel.self) private var viewModel
    @State private var selectedDream: DreamEntry?
    
    var body: some View {
        VStack {
            Text("Your Dreams")
                .font(.largeTitle)
                .padding(.top)
            
            if viewModel.dreamEntries.isEmpty {
                Text("No dreams recorded yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.dreamEntries.sorted(by: { $0.date > $1.date })) { dream in
                        Button {
                            selectedDream = dream
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(dream.title)
                                    .font(.headline)
                                
                                Text(dream.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(dream.content.prefix(100))
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteDream(at: indexSet)
                    }
                }
            }
        }
        .sheet(item: $selectedDream) { dream in
            DreamDetailView(dream: dream)
        }
        .onAppear {
            Task {
                await viewModel.loadDreams()
            }
        }
    }
}
