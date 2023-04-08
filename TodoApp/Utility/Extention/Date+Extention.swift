//
//  Date+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

import Foundation
public extension Date {
    // Date → String に変換
    func dateFormat() -> String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.dateFormat = "yyyyMMddHHmm"
        return format.string(from: self)
    }
}
