//
//  DateExtention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

import Foundation
extension Date {
    // Date → String に変換
    func dateFormat() -> String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ja_JP")
        format.dateFormat = "yyyyMMddHHmm"
        return format.string(from: self)
    }
}
