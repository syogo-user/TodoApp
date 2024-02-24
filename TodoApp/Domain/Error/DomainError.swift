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
    case localDbError
    /// APIのエラー
    case onAPIFetchError(code: String)
    /// APIの更新エラー
    case onAPIUpdateError(code: String)
    /// パースエラー
    case parseError
    /// ネットワークエラー
    case networkError
    /// その他のエラー
    case unKnownError
}
