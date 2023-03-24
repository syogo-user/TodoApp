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
    var userInfoDao: UserInfoDao { get }
    var taskInfoDao: TaskInfoDao { get }
}

class GRDBAccessor {

    func readFromDBwith<T>(_ operation: @escaping ((GRDB.Database) throws -> (T))) -> Single<T> {
        MainDatabase.shared.dbQueue()
            .flatMap { dbQueue in
                dbQueue.rx.read { db in
                    try operation(db)
                }
                .catchError { error in
                    throw DomainError.unKnownError
                }
            }
    }

    func writeToDBwith(_ operation: @escaping ((GRDB.Database) throws -> Void)) -> Single<Void> {
        MainDatabase.shared.dbQueue()
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
