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
    /// 並び順
    var sortOrder: String? { get set }
    /// 抽出条件
    var filterCondition: String? { get set }
    /// タスクの取得
    func fetchTask(userId: String, authorization: String) async throws -> TaskListAPI.Response
    /// タスクの登録
    func addTask(title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<AddTaskAPI.Response>
    /// タスクの更新
    func updateTask(taskId: String, title: String, content: String, scheduledDate: String, isCompleted: Bool, isFavorite: Bool, userId: String, authorization: String) -> Single<UpdateTaskAPI.Response>
    /// タスクの削除
    func deleteTask(taskId: String, authorization: String) -> Single<DeleteTaskAPI.Response>
    /// ローカルタスクリストの取得
    func loadLocalTaskList() throws -> [TaskInfoRecord]
    /// ローカルタスクの取得
    func insertLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルタスクリストの追加
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws
    /// ローカルタスクの更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルタスクの削除
    func deleteLocalTask(taskId: String) throws
    /// ローカルタスクをすべて削除
    func deleteLocalTaskAll() throws
    /// ローカルタスクリストを削除
    func deleteLocalTaskList(taskIdList: [String]) throws
}

class TaskRepositoryImpl: TaskRepository {
    private let remoteStore: TaskRemoteStore = TaskRemoteStoreImpl()
    private var localStore: TaskLocalStore = TaskLocalStoreImpl()

    var sortOrder: String? {
        get { localStore.sortOrder }
        set { localStore.sortOrder = newValue }
    }

    var filterCondition: String? {
        get { localStore.filterCondition }
        set { localStore.filterCondition = newValue }
    }

    func fetchTask(userId: String, authorization: String) async throws -> TaskListAPI.Response {
        try await remoteStore.fetchTask(userId: userId, authorization: authorization)
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

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws {
        try localStore.insertLocalTaskList(taskInfoList: taskInfoList)
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
        try localStore.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) throws {
        try localStore.deleteLocalTask(taskId: taskId)
    }

    func deleteLocalTaskAll() throws {
        try localStore.deleteLocalTaskAll()
    }

    func deleteLocalTaskList(taskIdList: [String]) throws {
        try localStore.deleteLocalTaskList(taskIdList: taskIdList)
    }
}
