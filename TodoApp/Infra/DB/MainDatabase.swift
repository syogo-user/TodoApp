//
//  MainDatabase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import GRDB
import RxSwift

final class MainDatabase {
    struct Definition: DatabaseDefinition {
        let dbName: String = "MainDatabase"
        let dbFileName: String = "main.sqlite"
        var migrator = DatabaseMigrator.mainDatabase
    }

    static let shared = MainDatabase()
    private init() {}

    enum Versions: String {
        case v1
    }

    private var _dbQueue: DatabaseQueue?

    func dbQueue() throws -> DatabaseQueue {
        guard let dbQueue = _dbQueue else {
            throw DatabaseError.accessFailed(reason: "データベースが1度もopenされていません")
        }
        print("####dbQueue():\(dbQueue.path)")
        return dbQueue
    }

    func dbQueue() -> Single<DatabaseQueue> {
        return Single.just(try! dbQueue())
    }

    func open() -> Single<DatabaseQueue> {
        DatabaseQueueFactory.create(definition: Definition())
            .do(onSuccess: { [unowned self] dbQueue in
                self._dbQueue = dbQueue
                print("####dbQueue():\(dbQueue.path)")
            })
    }
}


extension DatabaseMigrator {
    static var mainDatabase: DatabaseMigrator {
        var databaseMigrator = DatabaseMigrator()
        databaseMigrator.registerMigration(.v1) { db, version in
            try UserInfoRecord.setupTable(db, version)
        }
        return databaseMigrator
    }
}


private extension DatabaseMigrator {
    mutating func registerMigration(_ version: MainDatabase.Versions, migrate: @escaping(Database, MainDatabase.Versions) throws -> Void) {
        registerMigration(version.rawValue) {
            try migrate($0, version)
        }

    }
}

