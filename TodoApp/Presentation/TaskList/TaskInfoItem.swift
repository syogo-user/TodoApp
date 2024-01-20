//
//  TaskInfoItem.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation

protocol SortProtocol: ObservableObject {
    /// タスクID
    var taskId: String { get }
    /// 予定日時
    var scheduledDate: Date { get }
}

class TaskInfoItem: SortProtocol, Identifiable {
    /// タスクID
    @Published var taskId: String
    /// タイトル
    @Published var title: String
    /// 内容
    @Published var content: String
    /// 予定日時
    @Published var scheduledDate: Date
    /// 完了済みか
    @Published var isCompleted: Bool
    /// お気に入りか
    @Published var isFavorite: Bool
    /// ユーザID
    @Published var userId: String

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
