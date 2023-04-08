//
//  DatabaseError.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation

enum DatabaseError: Error {
    /// DBオープン失敗
    case openFailed(Error)
    /// DBアクセス失敗
    case accessFailed(reason: String)
}
