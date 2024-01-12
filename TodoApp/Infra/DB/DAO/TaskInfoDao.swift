//
//  TaskInfoDao.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import GRDB
import RxGRDB
import RxSwift

protocol TaskInfoDao {
    /// ローカルのタスクを取得
    func loadLocalTask() throws -> [TaskInfoRecord]
    /// ローカルにユーザを追加
    func insertLocalTask(taskInfo: TaskInfoRecord) throws
    /// ローカルにユーザリストを追加
    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) throws
    ///  ローカルのタスクを削除
    func deleteLocalTask(taskId: String) throws
    ///  ローカルのタスクをすべて削除
    func deleteLocalTaskAll() throws
    ///  ローカルのタスクを複数削除
    func deleteLocalTaskList(taskIdList: [String]) throws
}

class TaskInfoDaoImpl: GRDBAccessor, TaskInfoDao {

    func loadLocalTask() throws -> [TaskInfoRecord] {
        try readFromDBwith { db in
            try TaskInfoRecord.fetchAll(db)
        }
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) throws {
        try writeToDBwith { db in
            try taskInfo.insert(db)
        }
    }

    func insertLocalTaskList(taskInfoList: [TaskInfoRecord]) throws {
        try writeToDBwith { db in
            try taskInfoList.forEach { try $0.insert(db) }
        }
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) throws {
        try writeToDBwith { db in
            try taskInfo.updateChanges(db)
        }
    }

    func deleteLocalTask(taskId: String) throws {
        try writeToDBwith { db in
            try TaskInfoRecord.deleteOne(db, key: taskId)
        }
    }

    func deleteLocalTaskAll() throws {
        try writeToDBwith { db in
            try TaskInfoRecord.deleteAll(db)
        }
    }

    func deleteLocalTaskList(taskIdList: [String]) throws {
        try writeToDBwith { db in
            try taskIdList.forEach { try TaskInfoRecord.deleteOne(db, key: $0) }
        }
    }
}
