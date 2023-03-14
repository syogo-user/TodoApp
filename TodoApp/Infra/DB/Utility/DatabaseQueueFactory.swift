//
//  DatabaseQueueFactory.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import GRDB
import RxSwift

enum DatabaseQueueFactory {
    /// データベースに接続する処理を何回繰り返し行うか
    private static let maxAttemptCount = 2

    static func create(definition: DatabaseDefinition) -> Single<DatabaseQueue> {
        Single<DatabaseQueue>.create { observer in
            do {
                let databasePath = try generateDatabasePath(dbFileName: definition.dbFileName)
                let dbQueue = try generateDatabaseQueue(dbName: definition.dbName, databasePath: databasePath)
                try definition.migrator.migrate(dbQueue)
                observer(.success(dbQueue))
            } catch {
                try! initialize(definition: definition)
                observer(.error(DatabaseError.openFailed(error)))
            }
            return Disposables.create()
        }
        .retry(maxAttemptCount)
        .subscribeOn(CurrentThreadScheduler.instance)
        .observeOn(MainScheduler.instance)
    }

    /// DatabaseQueueを生成
    private static func generateDatabaseQueue(dbName: String, databasePath: String) throws -> DatabaseQueue {
        var configuration = Configuration()
        configuration.label = dbName
        return try DatabaseQueue(path:databasePath, configuration: configuration)
    }

    /// データベース保存パス生成
    private static func generateDatabasePath(dbFileName: String) throws -> String {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbFileName).path
    }
    
    /// データベースの初期化
    private static func initialize(definition: DatabaseDefinition) throws {
        do {
            let databasePath = try generateDatabasePath(dbFileName: definition.dbFileName)
            if FileManager.default.fileExists(atPath: databasePath) {
                try FileManager.default.removeItem(atPath: databasePath)
            }
        } catch {
            throw error
        }
    }
}
