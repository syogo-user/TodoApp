//
//  TaskUseCase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import RxSwift

protocol TaskUseCase {
    /// 並び順
    var sortOrder: String? { get set }
    /// 抽出条件
    var filterCondition: String? { get set }
    /// タスク取得
    func fetchTask(userId: String, authorization: String) async throws -> [TaskInfo]
    /// タスク登録
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo>
    /// タスク更新
    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo>
    /// タスク削除
    func deleteTask(taskId: String, authorization: String) -> Single<String>
    /// ローカルタスクリストを取得
    func loadLocalTaskList() throws -> [TaskInfoRecord]
    /// ローカルにタスクを登録
    func insertLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルにタスクリストを登録
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルのタスクを削除
    func deleteLocalTask(taskId: String) throws
    /// ローカルのタスクをすべて削除
    func deleteLocalTaskAll() throws
    /// ローカルタスクを複数削除
    func deleteLocalTaskList(taskIdList: [String]) throws
    /// タスクリストをソート
    func sortTask<T: SortProtocol>(itemList: inout [T], sort: String)
    /// タスクをフィルター
    func filterTask(itemList: inout [TaskInfoItem], condition: String)
    /// 通知の登録/更新
    func registerNotification(notificationId: String, title: String, body: String, scheduledDate: Date)
    /// 通知の削除
    func removeNotification(taskId: String)
}

class TaskUseCaseImpl: TaskUseCase {
    private var repository: TaskRepository = TaskRepositoryImpl()

    init(repository: TaskRepository) {
        self.repository = repository
    }

    init() {}

    /// 並び順
    var sortOrder: String? {
        get { repository.sortOrder }
        set { repository.sortOrder = newValue }
    }

    /// 抽出条件
    var filterCondition: String? {
        get { repository.filterCondition }
        set { repository.filterCondition = newValue }
    }

    /// タスク取得
    func fetchTask(userId: String, authorization: String) async throws -> [TaskInfo] {
        let response = try await repository.fetchTask(userId: userId, authorization: authorization)
        if !response.isAcceptable {
            throw DomainError.onAPIError(code: "APIエラー") // あとで修正
        }
        let tasks = response.data
        return try tasks.map {
            TaskInfo(
                taskId: $0.taskId,
                title: $0.title,
                content: $0.content,
                scheduledDate: try $0.scheduledDate.toDate(),
                isCompleted: $0.isCompleted,
                isFavorite: $0.isFavorite,
                userId: $0.userId
            )
        }
        
        
            // 以下削除する
//            .do(onSuccess: { result in
//                guard result.isAcceptable else {
//                    throw DomainError.onAPIError(code: result.message)
//                }
//            })
//            .map { task in
//                try task.data.map { try TaskInfo(
//                    taskId: $0.taskId,
//                    title: $0.title,
//                    content: $0.content,
//                    scheduledDate: $0.scheduledDate.toDate(),
//                    isCompleted: $0.isCompleted,
//                    isFavorite: $0.isFavorite,
//                    userId: $0.userId
//                ) }
//            }
    }

    /// タスク登録
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo> {
        repository.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
            .do(onSuccess: { result in
                guard result.isAcceptable else {
                    throw DomainError.onAPIError(code: result.message)
                }
            })
            .map {
                let task = $0.data
                return try TaskInfo(
                    taskId: task.taskId,
                    title: task.title,
                    content: task.content,
                    scheduledDate: task.scheduledDate.toDate(),
                    isCompleted: task.isCompleted,
                    isFavorite: task.isFavorite,
                    userId: task.userId
                )
            }
    }

    /// タスク更新
    func updateTask(taskId: String,title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo> {
        repository.updateTask(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
            .do(onSuccess: { result in
                guard result.isAcceptable else {
                    throw DomainError.onAPIError(code: result.message)
                }
            })
            .map {
                let task = $0.data
                return try TaskInfo(
                    taskId: task.taskId,
                    title: task.title,
                    content: task.content,
                    scheduledDate: task.scheduledDate.toDate(),
                    isCompleted: task.isCompleted,
                    isFavorite: task.isFavorite,
                    userId: task.userId
                )
            }
    }

    /// タスク削除
    func deleteTask(taskId: String, authorization: String) -> Single<String> {
        repository.deleteTask(taskId: taskId, authorization: authorization)
            .do(onSuccess: { result in
                guard result.isAcceptable else {
                    throw DomainError.onAPIError(code: result.message)
                }
            })
            .map {
                $0.data.taskId
            }
    }

    /// ローカルタスクリストを取得
    func loadLocalTaskList() throws -> [TaskInfoRecord] {
        try repository.loadLocalTaskList()
    }

    /// ローカルにタスクを登録
    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
        try repository.insertLocalTask(taskInfo: taskInfo)
    }

    /// ローカルにタスクリストを登録
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws {
        try repository.insertLocalTaskList(taskInfoList: taskInfoList)
    }

    /// ローカルタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
        try repository.updateLocalTask(taskInfo: taskInfo)
    }

    /// ローカルタスクを削除
    func deleteLocalTask(taskId: String) throws {
        try repository.deleteLocalTask(taskId: taskId)
    }

    /// ローカルタスクをすべて削除
    func deleteLocalTaskAll() throws {
        try repository.deleteLocalTaskAll()
    }

    /// ローカルタスクを複数削除
    func deleteLocalTaskList(taskIdList: [String]) throws {
        try repository.deleteLocalTaskList(taskIdList: taskIdList)
    }

    /// タスクリストをソート
    func sortTask<T: SortProtocol>(itemList: inout [T], sort: String) {
        itemList.sort{ (task1: T, task2: T) -> Bool in
            if task1.scheduledDate == task2.scheduledDate {
                // 日付が同じ場合
                return Int(task1.taskId) ?? 0  < Int(task2.taskId) ?? 0
            } else {
                // 日付が異なる場合
                if sort == SortOrder.ascendingOrderDate.rawValue {
                    return task1.scheduledDate < task2.scheduledDate
                } else {
                    return task1.scheduledDate > task2.scheduledDate
                }
            }
        }
    }

    /// タスクをフィルター
    func filterTask(itemList: inout [TaskInfoItem], condition: String) {
        itemList = itemList.filter({ item in
            switch condition {
            case FilterCondition.onlyFavorite.rawValue:
                // お気に入りのみ抽出(完了済も含む)
                return item.isFavorite
            case FilterCondition.includeCompleted.rawValue:
                // 完了済も含めてすべて抽出
                return true
            case FilterCondition.notIncludeCompleted.rawValue:
                // 完了済は含めない
                return !item.isCompleted
            default:
                // 完了済は含めない
                return !item.isCompleted
            }
        })
    }

    /// 通知の登録/更新
    func registerNotification(notificationId: String, title: String, body: String, scheduledDate: Date) {
        let targetDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate)
        // トリガーとコンテンツの作成
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: targetDate, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest.init(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        // 通知リクエストの登録
        UNUserNotificationCenter.current().add(request)
    }

    /// 通知の削除
    func removeNotification(taskId: String) {
       UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
   }
}
