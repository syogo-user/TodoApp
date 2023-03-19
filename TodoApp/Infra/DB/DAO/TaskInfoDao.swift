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
}

class TaskInfoDaoImpl: TaskInfoDao {

    func loadLocalTask() -> Single<[TaskInfoRecord]> {
        MainDatabase.shared.dbQueue()
            .flatMap { dbQueue in
                dbQueue.rx.read { db in
                    try TaskInfoRecord.fetchAll(db)
                }
                .catchError { error in
                    throw DomainError.localDBError
                }
            }
    }

    func insertLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
         MainDatabase.shared.dbQueue()
            .flatMap { dbQueue in
                dbQueue.rx.write { db in
                    try taskInfo.insert(db)
                }
                .andThen(Single.just(()))
                .catchError { error in
                    throw DomainError.localDBError
                }
            }
    }

    func updateLocalTask(taskInfo: TaskInfoRecord) -> Single<Void> {
        MainDatabase.shared.dbQueue()
           .flatMap { dbQueue in
               dbQueue.rx.write { db in
                   try taskInfo.updateChanges(db)
               }
               .andThen(Single.just(()))
               .catchError { error in
                   throw DomainError.localDBError
               }
           }
    }

    func deleteLocalTask(taskId: String) -> Single<Void> {
        MainDatabase.shared.dbQueue()
           .flatMap { dbQueue in
               dbQueue.rx.write { db in
                   try TaskInfoRecord.deleteOne(db, key: taskId)
               }
               .andThen(Single.just(()))
               .catchError { error in
                   throw DomainError.localDBError
               }
           }
    }
}
