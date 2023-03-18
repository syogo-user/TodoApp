//
//  TaskRepository.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import APIKit
import RxSwift

protocol TaskRepository {
    func fetchTask(userId: String, authorization: String) -> Single<TaskListAPI.Response>

    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response>

    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response>

    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response>
    
    func loadLocalTaskList() throws -> [TaskInfoRecord]

    func insertLocalTask(taskInfo: TaskInfoRecord) throws

    func updateLocalTask(taskInfo: TaskInfoRecord) throws

    func deleteLocalTask(taskId: String) throws
}

class TaskRepositoryImpl: TaskRepository {
    private let remoteStore: TaskRemoteStore = TaskRemoteStoreImpl()
    private let localStore: TaskLocalStore = TaskLocalStoreImpl()

    func fetchTask(userId: String, authorization: String) -> Single<TaskListAPI.Response> {
        remoteStore.fetchTask(userId: userId, authorization: authorization)
    }

    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response> {
        remoteStore.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
    }

    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response> {
        remoteStore.updateTask(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
    }

    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response> {
        remoteStore.deleteTask(taskId: taskId, authorization: authorization)
    }

    func loadLocalTaskList() throws -> [TaskInfoRecord] {
       try localStore.loadLocalTaskList()
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
       try localStore.insertLocalTask(taskInfo: taskInfo)
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
       try localStore.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) throws {
       try localStore.deleteLocalTask(taskId: taskId)
    }
}
