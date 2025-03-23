//
//  CalendarDay.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/22/25.
//


import SwiftUI
 
 
 struct CalendarDay: Identifiable {
     let id: UUID
     let date: Date
     let isCurrentMonth: Bool
 }