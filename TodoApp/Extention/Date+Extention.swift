//
//  Date+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/16.
//

import Foundation

extension Date {
    
    // Date → String に変換
    func dateFormat() -> String {
        var strDate:String = ""
        let format  = DateFormatter()
        format.locale = Locale(identifier: "ja_JP")
        format.dateFormat = "yyyyMMdd"
        strDate = format.string(from:self)
        return strDate
    }
}
