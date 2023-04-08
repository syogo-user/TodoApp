//
//  UserInfoRecord.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import GRDB

class UserInfoRecord : Record {
    override class var databaseTableName: String {
        "user_info"
    }

    /// ユーザID
    let userId: String
    /// メールアドレス
    let email: String

    static func setupTable(_ db: Database, _ version: MainDatabase.Versions) throws {
        try db.create(table: databaseTableName, body: { (table:TableDefinition) in
            table.column("userId", .text).notNull().primaryKey(onConflict: .replace, autoincrement: false)
            table.column("email", .text).notNull()
        })
    }

    enum Columns {
        static let userId = Column("userId")
        static let email = Column("email")
    }

    init(userId: String, email: String) {
        self.userId = userId
        self.email = email
        super.init()
    }

    required init(row: Row) {
        self.userId = row["userId"]
        self.email = row["email"]
        super.init()
    }

    override func encode(to container: inout PersistenceContainer) {
        container["userId"] = self.userId
        container["email"] = self.email
    }
}
