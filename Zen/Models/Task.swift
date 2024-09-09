//
//  Task.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-17.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var date: Date  // This is the creation date of the task

    init(title: String, isCompleted: Bool = false, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.date = date  // Initialize the date when the task is created
    }
}
