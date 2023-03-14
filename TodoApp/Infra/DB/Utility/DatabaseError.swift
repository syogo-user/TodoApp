//
//  DatabaseError.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation

enum DatabaseError: Error {
    case openFailed(Error)
    case accessFailed(reason: String)
    case invalidPrimaryKeyValue
    case emptyResultSet
}

extension DatabaseError {
    var localizedDescription: String {
        switch self {
        case .openFailed:
            return "Failed to open database"
        case .accessFailed:
            return "Failed to access database"
        case .invalidPrimaryKeyValue:
            return "Failed to cast primary key"
        case .emptyResultSet:
            return "record not found"
        }
    }
}

extension DatabaseError: LocalizedError {
    var errorDescription: String? {
        localizedDescription
    }
    var failureReason: String? {
        switch self {
        case let .openFailed(error):
            return error.localizedDescription
        case let .accessFailed(reason):
            return reason
        default:
            return ""
        }
    }
}
