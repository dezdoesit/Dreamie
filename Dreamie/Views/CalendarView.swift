//
//  CalendarView.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/22/25.
//



 import SwiftUI
 
 struct CalendarView: View {
     @Binding var selectedDate: Date
     let dreamsPerDay: [Date: [DreamEntry]]
     
     @State private var currentMonth: Date = Date()
     
     var body: some View {
         VStack {
             // Month navigation
             HStack {
                 Button(action: previousMonth) {
                     Image(systemName: "chevron.left")
                         .padding()
                 }
                 
                 Spacer()
                 
                 Text(currentMonth.formatted(.dateTime.year().month(.wide)))
                     .font(.title3.bold())
                 
                 Spacer()
                 
                 Button(action: nextMonth) {
                     Image(systemName: "chevron.right")
                         .padding()
                 }
             }
             .padding(.horizontal)
             
             // Day of week header
             HStack {
                 ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                     Text(day)
                         .frame(maxWidth: .infinity)
                         .font(.caption)
                 }
             }
             
             // Calendar grid
             LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                 ForEach(days) { day in
                     DayView(
                         day: day,
                         isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate),
                         hasDreams: dreamsPerDay[Calendar.current.startOfDay(for: day.date)] != nil
                     )
                     .onTapGesture {
                         selectedDate = day.date
                     }
                 }
             }
         }
         .onChange(of: selectedDate) { _, _ in
             // If selected date is in a different month, update current month
             if !Calendar.current.isDate(selectedDate, equalTo: currentMonth, toGranularity: .month) {
                 currentMonth = selectedDate
             }
         }
     }
     
     private var days: [CalendarDay] {
         let calendar = Calendar.current
         let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
         let range = calendar.range(of: .day, in: .month, for: start)!
         
         let firstWeekday = calendar.component(.weekday, from: start)
         let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
         
         var days = [CalendarDay]()
         
         // Add empty days at the start
         for _ in 0..<leadingEmptyDays {
             days.append(CalendarDay(id: UUID(), date: Date.distantPast, isCurrentMonth: false))
         }
         
         // Add days of the month
         for day in range {
             let date = calendar.date(byAdding: .day, value: day - 1, to: start)!
             days.append(CalendarDay(id: UUID(), date: date, isCurrentMonth: true))
         }
         
         return days
     }
     
     private func previousMonth() {
         if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
             currentMonth = newMonth
         }
     }
     
     private func nextMonth() {
         if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
             currentMonth = newMonth
         }
     }
 }
