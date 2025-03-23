//
//  DayView.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/22/25.
//



 import SwiftUI
 
 struct DayView: View {
     let day: CalendarDay
     let isSelected: Bool
     let hasDreams: Bool
     
     var body: some View {
         if day.isCurrentMonth {
             ZStack {
                 Circle()
                     .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                     .frame(width: 32, height: 32)
                 
                 VStack(spacing: 2) {
                     Text("\(Calendar.current.component(.day, from: day.date))")
                         .font(.callout)
                         .fontWeight(isSelected ? .bold : .regular)
                     
                     if hasDreams {
                         Circle()
                             .fill(Color.blue)
                             .frame(width: 6, height: 6)
                     } else {
                         Circle()
                             .fill(Color.clear)
                             .frame(width: 6, height: 6)
                     }
                 }
             }
             .padding(.vertical, 8)
         } else {
             // Empty day
             Text("")
                 .padding(.vertical, 8)
         }
     }
 }