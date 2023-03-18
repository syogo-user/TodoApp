//
//  APIResult.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation

enum APIResultCode {
    /// 成功
    static let ok = "OK"

    // TODO:

    /// 不明なエラー
    static let errUnknown = "ERR_UNKNOWN"
}

protocol APIResult {

    /// 処理結果
    var message: String { get }
    /// エラーの有無
    var isAcceptable: Bool { get }
}

extension APIResult {
    var isAcceptable: Bool {
        message == APIResultCode.ok
    }
}
