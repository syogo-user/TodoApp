//
//  TaskLocalStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import APIKit
import RxSwift

protocol TaskLocalStore {

    func loadLocalTaskList() -> Single<[TaskInfoRecord]>

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>

    func deleteLocalTask(taskId: String) -> Single<Void>
}

class TaskLocalStoreImpl: TaskLocalStore {
    private let dao: TaskInfoDao = TaskInfoDaoImpl()

    func loadLocalTaskList() -> Single<[TaskInfoRecord]> {
        dao.loadLocalTask()
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        dao.insertLocalTask(taskInfo: taskInfo)
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
       dao.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
       dao.deleteLocalTask(taskId: taskId)
    }
}
