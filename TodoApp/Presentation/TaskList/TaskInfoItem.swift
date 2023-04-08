//
//  TaskInfoItem.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation

protocol SortProtocol {
    /// タスクID
    var taskId: String { get }
    /// 予定日時
    var scheduledDate: Date { get }
}

class TaskInfoItem: SortProtocol {
    /// タスクID
    let taskId: String
    /// タイトル
    let title: String
    /// 内容
    let content: String
    /// 予定日時
    let scheduledDate: Date
    /// 完了済みか
    let isCompleted: Bool
    /// お気に入りか
    let isFavorite: Bool
    /// ユーザID
    let userId: String

    init(taskId: String, title: String, content: String, scheduledDate: Date, isCompleted: Bool, isFavorite: Bool, userId: String)  {
        self.taskId = taskId
        self.title = title
        self.content = content
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.isFavorite = isFavorite
        self.userId = userId
    }
}
