//
//  Date+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/16.
//

import UIKit

extension Date {
    
    // Date → String に変換
    func dateFormat() -> String {
        var strDate:String = ""
        let format  = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        strDate = format.string(from:self)
        return strDate
    }
}
