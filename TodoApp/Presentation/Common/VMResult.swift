//
//  VMResult.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation

class VMResult<T>: CustomStringConvertible {
    private(set) var isLoading: Bool = false
    private(set) var isReady: Bool = false
    private(set) var data: T?
    private(set) var error: Error?

    var isCompleted: Bool {
        data != nil || error != nil
    }

    var description: String {
        ""
    }

    init() {
    }

    init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    init(isReady: Bool) {
        self.isReady = isReady
    }

    init(data: T?) {
        self.data = data
    }

    init(error: Error?) {
        self.error = error
    }

    static func loading() -> VMResult<T> {
        VMResult<T>(isLoading: true)
    }

    static func ready() -> VMResult<T> {
        VMResult<T>(isLoading: true)
    }

    static func success(_ data: T) ->VMResult<T> {
        VMResult<T>(data: data)
    }

    static func failure(_ error: Error) -> VMResult<T> {
        VMResult<T>(error: error)
    }
}
