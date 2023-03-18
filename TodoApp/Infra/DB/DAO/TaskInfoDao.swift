//
//  TaskInfoDao.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import GRDB

protocol TaskInfoDao {
    /// ローカルのタスクを取得
    func loadLocalTask() throws -> [TaskInfoRecord]
    /// ローカルにユーザを追加
    func insertLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws
    ///  ローカルのタスクを削除
    func deleteLocalTask(taskId: String) throws
}

class TaskInfoDaoImpl: TaskInfoDao {

    func loadLocalTask() throws -> [TaskInfoRecord] {
        let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
        let taskInfoRecord = try dbQueue.read { db in
            let taskInfo = try TaskInfoRecord.fetchAll(db)
//                throw DomainError.localDBError
//            }
            return taskInfo
        }
        return taskInfoRecord
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
        let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
        try dbQueue.write { db in
            try taskInfo.insert(db)
        }
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
        let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
        try dbQueue.write { db in
            try taskInfo.updateChanges(db)
        }
    }

    func deleteLocalTask(taskId: String) throws {
        let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
        let _ = try dbQueue.write { db in
            try TaskInfoRecord.deleteOne(db, key: taskId)
        }
    }
}
