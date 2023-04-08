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
    /// 並び順
    var sortOrder: String? { get set }
    /// 抽出条件
    var filterCondition: String? { get set }
    /// ローカルタスクリストの取得
    func loadLocalTaskList() -> Single<[TaskInfoRecord]>
    /// ローカルタスクの追加
    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルタスクリストの追加
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) -> Single<Void>
    /// ローカルタスクの更新
    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルタスクの削除
    func deleteLocalTask(taskId: String) -> Single<Void>
    /// ローカルタスクをすべて削除
    func deleteLocalTaskAll() -> Single<Void>
    /// ローカルタスクリストを削除
    func deleteLocalTaskList(taskIdList: [String]) -> Single<Void>
}

class TaskLocalStoreImpl: TaskLocalStore {
    private let accessor: DBAccessor = GRDBAccessor()

    private enum Key: String {
        case sortOrder = "sortOrder"
        case filterCondition = "filterCondition"
    }

    var sortOrder: String? {
        get { UserDefaults.standard.string(forKey: Key.sortOrder.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.sortOrder.rawValue)}
    }

    var filterCondition: String? {
        get { UserDefaults.standard.string(forKey: Key.filterCondition.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.filterCondition.rawValue)}
    }

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
