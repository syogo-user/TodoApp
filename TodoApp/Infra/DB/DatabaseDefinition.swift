//
//  DatabaseDefinition.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import GRDB

protocol DatabaseDefinition {
    /// データベース名
    var dbName: String { get }
    /// データファイル名
    var dbFileName: String { get }
    /// マイグレーション
    var migrator: DatabaseMigrator { get }
}
