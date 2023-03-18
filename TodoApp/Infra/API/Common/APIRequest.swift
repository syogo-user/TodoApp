//
//  APIRequest.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit

protocol ServerRequest: Request {
    var apiRoute: ServerAPIRoutes { get }
}

extension Request where Response: Decodable {
    var dataParser: DataParser {
        DecodableDataParser()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

extension ServerRequest  {
    var path: String {
        apiRoute.path
    }

    var method: HTTPMethod {
        apiRoute.method
    }

    var baseURL: URL {
        URL(string: Environment.serverApiBaseUrl)!
    }

    var headerFields: [String: String] {
        var header = [String: String]()
        header["charset"] = "utf-8"
        return header
    }
}


protocol ServerAuthorization {
    var authorization: String { get set }
}

extension ServerRequest where Self: ServerAuthorization {

    var headerFields: [String : String] {
        var header = [String: String]()
        header["charset"] = "utf-8"
        header["Authorization"] = authorization
        return header
    }
}
