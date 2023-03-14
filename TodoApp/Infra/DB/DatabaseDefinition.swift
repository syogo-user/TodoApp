//
//  DatabaseDefinition.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import GRDB

protocol DatabaseDefinition {
    var dbName: String { get }
    var dbFileName: String { get }
    var migrator: DatabaseMigrator { get }
}
