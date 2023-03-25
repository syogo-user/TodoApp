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

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void>

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>

    func deleteLocalTask(taskId: String) -> Single<Void>

    func deleteLocalTaskAll() -> Single<Void>

    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void>
}

class TaskLocalStoreImpl: TaskLocalStore {
    private let accessor: DBAccessor = GRDBAccessor()

    func loadLocalTaskList() -> Single<[TaskInfoRecord]> {
        accessor.taskInfoDao.loadLocalTask()
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        accessor.taskInfoDao.insertLocalTask(taskInfo: taskInfo)
    }

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void> {
        accessor.taskInfoDao.insertLocalTaskList(taskInfoList: taskInfoList)
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        accessor.taskInfoDao.updateLocalTask(taskInfo: taskInfo)
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
        accessor.taskInfoDao.deleteLocalTask(taskId: taskId)
    }

    func deleteLocalTaskAll() -> Single<Void> {
        accessor.taskInfoDao.deleteLocalTaskAll()
    }

    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void> {
        accessor.taskInfoDao.deleteLocalTaskList(taskIdList: taskIdList)
    }
}
