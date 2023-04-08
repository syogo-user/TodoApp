//
//  APIRoutes.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit

enum ServerAPIRoutes {
    case taskList
    case addTask
    case updateTask(taskId: String)
    case deleteTask(taskId: String)

    var apiUrlPath: String {
        switch self {
        case .taskList:
            return "list"
        case .addTask:
            return "list"
        case .updateTask(let taskId ):
            return "list/\(taskId)"
        case .deleteTask(let taskId):
            return "list/\(taskId)"
        }
    }

    var path: String {
        apiUrlPath
    }

    var method: HTTPMethod {
        switch self {
        case .taskList:
            return .get
        case .addTask:
            return .post
        case .updateTask:
            return .put
        case .deleteTask:
            return .delete
        }
    }
}
