//
//  TaskUseCase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import RxSwift

protocol TaskUseCase {
    /// タスク取得
    func fetchTask(userId: String, authorization: String) -> Single<[TaskInfo]>
    /// タスク登録
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo>
    /// タスク更新
    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<TaskInfo>
    /// タスク削除
    func deleteTask(taskId: String, authorization: String) -> Single<String>
    /// ローカルからタスクを取得
    func loadLocalTaskList() -> Single<[TaskInfoRecord]>
    /// ローカルにタスクを登録
    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルにタスクリストを登録
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void> 
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルのタスクを削除
    func deleteLocalTask(taskId: String) -> Single<Void>
    /// ローカルのタスクをすべて削除
    func deleteLocalTaskAll() -> Single<Void>
    /// ローカルタスクを複数削除
    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void>
    /// タスクリストをソートする
    func sortTask<T: SortProtocol>(itemList: inout [T], sort: String)
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

    func fetchTask(userId: String, authorization: String) -> Single<[TaskInfo]> {
        repository.fetchTask(userId: userId, authorization: authorization)
            .do(onSuccess: { result in
                guard result.isAcceptable else {
                    throw DomainError.onAPIError(code: result.message)
                }
            })
            .map { task in
                try task.data.map { try TaskInfo(
                    taskId: $0.taskId,
                    title: $0.title,
                    content: $0.content,
                    scheduledDate: $0.scheduledDate.toDate(),
                    isCompleted: $0.isCompleted,
                    isFavorite: $0.isFavorite,
                    userId: $0.userId
                ) }
            }
    }

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

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        repository.insertLocalTask(taskInfo: taskInfo)
    }

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void> {
        repository.insertLocalTaskList(taskInfoList: taskInfoList)
    }

    func loadLocalTaskList() -> Single<[TaskInfoRecord]> {
        repository.loadLocalTaskList()
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        repository.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
        repository.deleteLocalTask(taskId: taskId)
    }

    func deleteLocalTaskAll() -> Single<Void> {
        repository.deleteLocalTaskAll()
    }

    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void> {
        repository.deleteLocalTaskList(taskIdList: taskIdList)
    }

    func sortTask<T: SortProtocol>(itemList: inout [T], sort: String) {
        itemList.sort{ (task1: T, task2: T) -> Bool in
            if task1.scheduledDate == task2.scheduledDate {
                // 日付が同じ場合
                return Int(task1.taskId) ?? 0  < Int(task2.taskId) ?? 0
            } else {
                // 日付が異なる場合
                if sort == Sort.ascendingOrderDate.rawValue {
                    return task1.scheduledDate < task2.scheduledDate
                } else {
                    return task1.scheduledDate > task2.scheduledDate
                }
            }
        }
    }

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

    func removeNotification(taskId: String) {
       UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
   }
}
