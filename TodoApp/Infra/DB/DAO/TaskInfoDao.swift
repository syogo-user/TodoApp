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
    func loadLocalTask() -> Single<[TaskInfoRecord]>
    /// ローカルにユーザを追加
    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    /// ローカルのタスクを更新
    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void>
    ///  ローカルのタスクを削除
    func deleteLocalTask(taskId: String) -> Single<Void>
    ///  ローカルのタスクをすべて削除
    func deleteLocalTaskAll() -> Single<Void>
}

class TaskInfoDaoImpl: GRDBAccessor, TaskInfoDao {

    func loadLocalTask() -> Single<[TaskInfoRecord]> {
        readFromDBwith { db in
            try TaskInfoRecord.fetchAll(db)
        }
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        writeToDBwith { db in
            try taskInfo.insert(db)
        }
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        writeToDBwith { db in
            try taskInfo.updateChanges(db)
        }
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
        writeToDBwith { db in
            try TaskInfoRecord.deleteOne(db, key: taskId)
        }
    }

    func deleteLocalTaskAll() -> Single<Void> {
        writeToDBwith { db in
            try TaskInfoRecord.deleteAll(db)
        }
    }
}
