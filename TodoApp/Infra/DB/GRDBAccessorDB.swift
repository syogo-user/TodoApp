//
//  GRDBAccessorDB.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/23.
//

import Foundation
import GRDB
import RxGRDB
import RxSwift

protocol DBAccessor {
    /// ユーザ情報
    var userInfoDao: UserInfoDao { get }
    /// タスク情報
    var taskInfoDao: TaskInfoDao { get }
}

class GRDBAccessor {
    /// 取得
    func readFromDBwith<T>(_ operation: @escaping ((GRDB.Database) throws -> (T))) -> Single<T> {
        MainDatabase.shared.dbQueueSingle()
            .flatMap { dbQueue in
                dbQueue.rx.read { db in
                    try operation(db)
                }
                .catchError { error in
                    throw DomainError.unKnownError
                }
            }
    }

    /// 更新
    func writeToDBwith(_ operation: @escaping ((GRDB.Database) throws -> Void)) -> Single<Void> {
        MainDatabase.shared.dbQueueSingle()
            .flatMap { dbQueue in
                dbQueue.rx.write { db in
                    try operation(db)
                }
                .andThen(Single.just(()))
                .catchError { error in
                    throw DomainError.unKnownError
                }
            }
    }
}

extension GRDBAccessor: DBAccessor {
    var userInfoDao: UserInfoDao {
        UserInfoDaoImpl()
    }

    var taskInfoDao: TaskInfoDao {
        TaskInfoDaoImpl()
    }
}
