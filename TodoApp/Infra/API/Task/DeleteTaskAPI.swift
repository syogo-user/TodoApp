//
//  DeleteTaskAPI.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit

enum DeleteTaskAPI {
    struct Request: ServerRequest, ServerAuthorization {

        typealias Response = DeleteTaskAPI.Response

        let taskId: String
        var authorization: String

        var apiRoute: ServerAPIRoutes {
            .deleteTask(taskId: taskId)
        }
    }

    struct Response: Decodable, APIResult {

        var message: String

        private enum CodingKeys: String, CodingKey {
            case message = "message"
        }
    }
}
