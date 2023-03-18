//
//  TaskLocalStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import APIKit

protocol TaskLocalStore {

    func loadLocalTaskList() throws -> [TaskInfoRecord]

    func insertLocalTask(taskInfo: TaskInfoRecord) throws

    func updateLocalTask(taskInfo: TaskInfoRecord) throws

    func deleteLocalTask(taskId: String) throws
}

class TaskLocalStoreImpl: TaskLocalStore {
    private let dao: TaskInfoDao = TaskInfoDaoImpl()

    func loadLocalTaskList() throws -> [TaskInfoRecord] {
        try dao.loadLocalTask()
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
       try dao.insertLocalTask(taskInfo: taskInfo)
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
       try dao.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) throws {
       try dao.deleteLocalTask(taskId: taskId)
    }
}
