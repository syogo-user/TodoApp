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
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルのタスクを削除
    func deleteLocalTask(taskId: String) -> Single<Void>
    /// ローカルのタスクをすべて削除
    func deleteLocalTaskAll() -> Single<Void>
}

class TaskUseCaseImpl: TaskUseCase {
    private var repository: TaskRepository = TaskRepositoryImpl()

    func fetchTask(userId: String, authorization: String) -> Single<[TaskInfo]> {
        repository.fetchTask(userId: userId, authorization: authorization)
            .do(onSuccess: { result in
                guard result.isAcceptable else {
                    throw DomainError.unacceptableResultCode(code: result.message)
                }
            })
            .map { task in
                task.data.map { TaskInfo(
                    taskId: $0.taskId,
                    title: $0.title,
                    content: $0.content,
                    scheduledDate: $0.scheduledDate,
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
                    throw DomainError.unacceptableResultCode(code: result.message)
                }
            })
            .map {
                let task = $0.data
                return TaskInfo(
                    taskId: task.taskId,
                    title: task.title,
                    content: task.content,
                    scheduledDate: task.scheduledDate,
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
                    throw DomainError.unacceptableResultCode(code: result.message)
                }
            })
            .map {
                let task = $0.data
                return TaskInfo(
                    taskId: task.taskId,
                    title: task.title,
                    content: task.content,
                    scheduledDate: task.scheduledDate,
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
                    throw DomainError.unacceptableResultCode(code: result.message)
                }
            })
            .map {
                $0.data.taskId
            }
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        repository.insertLocalTask(taskInfo: taskInfo) }

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
}
