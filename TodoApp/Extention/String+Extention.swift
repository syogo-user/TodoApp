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
    
    // アドレス書式
    func mailAddressFormatCheck() -> Bool {
        // [大文字小文字英数字と._%+-]@[大文字小文字英数字.-].[2文字から4文字の大文字小文字英数字]
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        // 正：true　誤：false
        return result
    }
}
