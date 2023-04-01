//
//  TaskInfoRecord.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import GRDB

class TaskInfoRecord : Record {
    override class var databaseTableName: String {
        "task_info"
    }

    let taskId: String
    let title: String
    let content: String
    let scheduledDate: Date
    let isCompleted: Bool
    let isFavorite: Bool
    let userId: String

    static func setupTable(_ db: Database, _ version: MainDatabase.Versions) throws {
        try db.create(table: databaseTableName, body: { (table:TableDefinition) in
            table.column("task_id", .integer).notNull().primaryKey(onConflict: .replace, autoincrement: false)
            table.column("title", .text).notNull()
            table.column("content", .text).notNull()
            table.column("scheduled_date", .date).notNull()
            table.column("is_completed", .boolean).notNull()
            table.column("is_favorite", .boolean).notNull()
            table.column("user_id", .text).notNull()
        })
    }

    enum Columns {
        static let taskId = Column("task_id")
        static let title = Column("title")
        static let content = Column("content")
        static let scheduledDate = Column("scheduled_date")
        static let isCompleted = Column("is_completed")
        static let isFavorite = Column("is_favorite")
        static let userId = Column("user_id")
    }

    init(taskId: String, title: String, content: String, scheduledDate: Date, isCompleted: Bool, isFavorite: Bool, userId: String) {
        self.taskId = taskId
        self.title = title
        self.content = content
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.isFavorite = isFavorite
        self.userId = userId
        super.init()
    }

    required init(row: Row) {
        self.taskId = row["task_id"]
        self.title = row["title"]
        self.content = row["content"]
        self.scheduledDate = row["scheduled_date"]
        self.isCompleted = row["is_completed"]
        self.isFavorite = row["is_favorite"]
        self.userId = row["user_id"]
        super.init()
    }

    override func encode(to container: inout PersistenceContainer) {
        container["task_id"] = self.taskId
        container["title"] = self.title
        container["content"] = self.content
        container["scheduled_date"] = self.scheduledDate
        container["is_completed"] = self.isCompleted
        container["is_favorite"] = self.isFavorite
        container["user_id"] = self.userId
    }

}
