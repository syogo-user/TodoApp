//
//  TaskInfoItem.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation

protocol SortProtocol {
    var taskId: String { get }
    var scheduledDate: String { get }
}

class TaskInfoItem: SortProtocol {
    let taskId: String
    let title: String
    let content: String
    let scheduledDate: String
    let isCompleted: Bool
    let isFavorite: Bool
    let userId: String

    init(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String)  {
        self.taskId = taskId
        self.title = title
        self.content = content
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.isFavorite = isFavorite
        self.userId = userId
    }
}
