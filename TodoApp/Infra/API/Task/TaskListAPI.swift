//
//  TaskListAPI.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit

/// タスク取得API
enum TaskListAPI {
    struct Request: ServerRequest, ServerAuthorization {

        private enum Keys: String {
            case userId = "user_id"
        }

        typealias Response = TaskListAPI.Response

        let userId: String
        var authorization: String

        var apiRoute: ServerAPIRoutes {
            .taskList
        }

        var queryParameters: [String : Any]? {
            var data = [String: String]()
            data[Keys.userId.rawValue] = userId
            return data
        }

    }

    struct Response: Decodable, APIResult {
        var message: String
        let data: [Task]

        private enum CodingKeys: String, CodingKey {
            case message = "message"
            case data = "data"
        }

        struct Task: Decodable {
            let taskId: String
            let title: String
            let content: String
            let scheduledDate: String
            let isCompleted: Bool
            let isFavorite: Bool
            let userId: String

            private enum CodingKeys: String, CodingKey {
                case taskId = "task_id"
                case title = "title"
                case content = "content"
                case scheduledDate = "scheduled_date"
                case isCompleted = "is_completed"
                case isFavorite = "is_favorite"
                case userId = "user_id"
            }
        }
    }
}
