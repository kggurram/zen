//
//  Task.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//

import Foundation

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var date: Date = Date()
}
