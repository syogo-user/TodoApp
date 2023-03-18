//
//  DomainError.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/16.
//

import Foundation

enum DomainError: Error {
    /// 認証関係のエラー
    case authError
    /// ローカルDBに関するエラー
    case localDBError
    /// その他のエラー
    case unownedError
    /// APIのエラー
    case unacceptableResultCode(code: String)
}
