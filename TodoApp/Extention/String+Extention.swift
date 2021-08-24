//
//  String+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/20.
//

import Foundation

extension String {
    
    // yyyyMMdd → yyyy年MM月dd日 に変換
    func dateJpFormat() -> String {
        let year = String(self.prefix(4))
        let startIndex = self.index(self.startIndex, offsetBy: 4)
        let endIndex = self.index(self.endIndex, offsetBy: -3)
        let month = String(self[startIndex...endIndex])
        let day = String(self.suffix(2))
        let str = "\(year)年\(month)月\(day)日"
        return str
    }
}
