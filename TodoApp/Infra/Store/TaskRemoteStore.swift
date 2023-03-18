//
//  TaskRemoteStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit
import RxSwift

protocol TaskRemoteStore {
    func fetchTask(userId: String, authorization: String) -> Single<TaskListAPI.Response>

    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response>

    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response>

    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response>
}

class TaskRemoteStoreImpl: TaskRemoteStore {
    func fetchTask(userId: String, authorization: String) -> Single<TaskListAPI.Response> {
        let request = TaskListAPI.Request(userId: userId, authorization: authorization)
        return Session.rx_send(request)
    }

    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response> {
        let request = AddTaskAPI.Request(title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
        return Session.rx_send(request)
    }

    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response> {
        let request = UpdateTaskAPI.Request(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId, authorization: authorization)
        return Session.rx_send(request)
    }

    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response> {
        let request = DeleteTaskAPI.Request(taskId: taskId, authorization: authorization)
        return Session.rx_send(request)
    }
}
