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
    @State private var selectedDate: Date = Date()
    @State private var calendarId = UUID() // For forcing calendar refresh
    
    var body: some View {
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
            Text("Your Dreams")
                .font(.largeTitle)
                .padding(.vertical, 15)
            
            // Calendar view
            CalendarView(selectedDate: $selectedDate, dreamsPerDay: viewModel.dreamsGroupedByDay)
                .padding(.horizontal)
                .padding(.top, 30)
                .frame(minHeight: 300, maxHeight: 300)
            
                .fixedSize(horizontal: false, vertical: true)
                .id(calendarId) // Force refresh when dream data changes
            
            // Date header
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .padding(.top,30)
            
            // Dreams for selected date
            if let dreamsForDay = viewModel.dreamsGroupedByDay[Calendar.current.startOfDay(for: selectedDate)], !dreamsForDay.isEmpty {
                List {
                    ForEach(dreamsForDay) { dream in
                        Button {
                            selectedDream = dream
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(dream.title)
                                    .font(.headline)
                                
                                Text(dream.date.formatted(date: .omitted, time: .shortened))
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
                }.padding(.top,30)
            }
        }
        .padding()
        
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
}
