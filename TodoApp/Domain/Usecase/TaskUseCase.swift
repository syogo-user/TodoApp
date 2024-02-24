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
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) async throws -> TaskInfo
    /// タスク更新
    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String)  async throws -> TaskInfo
    /// タスク削除
    func deleteTask(taskId: String, authorization: String) async throws -> String
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
        do {
            let response = try await repository.fetchTask(userId: userId, authorization: authorization)
            if !response.isAcceptable {
                throw DomainError.onAPIFetchError(code: response.message) // あとで修正
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
        } catch let error {
            throw DomainError.onAPIFetchError(code: error.localizedDescription)
        }
    }

    /// タスク登録
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) async throws -> TaskInfo {
        
        do {
            let response = try await repository.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
            if !response.isAcceptable {
                throw DomainError.onAPIUpdateError(code: response.message)
            }
            let task = response.data
            return TaskInfo(
                taskId: task.taskId,
                title: task.title,
                content: task.content,
                scheduledDate: try task.scheduledDate.toDate(),
                isCompleted: task.isCompleted,
                isFavorite: task.isFavorite,
                userId: task.userId
            )
        } catch let error {
            throw DomainError.onAPIUpdateError(code: error.localizedDescription)
        }
    }

    /// タスク更新
    func updateTask(taskId: String,title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) async throws -> TaskInfo {
        do {
            let response = try await repository.updateTask(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
            if !response.isAcceptable {
                throw DomainError.onAPIUpdateError(code: response.message)
            }
            let task = response.data
            return TaskInfo(
                taskId: task.taskId,
                title: task.title,
                content: task.content,
                scheduledDate: try task.scheduledDate.toDate(),
                isCompleted: task.isCompleted,
                isFavorite: task.isFavorite,
                userId: task.userId
            )
        } catch let error {
            throw DomainError.onAPIUpdateError(code: error.localizedDescription)
        }
    }

    /// タスク削除
    func deleteTask(taskId: String, authorization: String) async throws -> String {
        do {
            let response = try await repository.deleteTask(taskId: taskId, authorization: authorization)
            if !response.isAcceptable {
                throw DomainError.onAPIUpdateError(code: "APIエラー")
            }
            let task = response.data
            return task.taskId
        } catch let error {
            throw DomainError.onAPIUpdateError(code: error.localizedDescription)
        }
    }

    /// ローカルタスクリストを取得
    func loadLocalTaskList() throws -> [TaskInfoRecord] {
        do {
            return try repository.loadLocalTaskList()
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルにタスクを登録
    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
        do {
            return try repository.insertLocalTask(taskInfo: taskInfo)
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルにタスクリストを登録
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws {
        do {
            return try repository.insertLocalTaskList(taskInfoList: taskInfoList)
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
        do {
            return try repository.updateLocalTask(taskInfo: taskInfo)
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルタスクを削除
    func deleteLocalTask(taskId: String) throws {
        do {
            return try repository.deleteLocalTask(taskId: taskId)
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルタスクをすべて削除
    func deleteLocalTaskAll() throws {
        do {
            return try repository.deleteLocalTaskAll()
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ローカルタスクを複数削除
    func deleteLocalTaskList(taskIdList: [String]) throws {
        do {
            return try repository.deleteLocalTaskList(taskIdList: taskIdList)
        } catch {
            throw DomainError.localDbError
        }
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
