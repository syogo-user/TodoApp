//
//  Check.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/24.
//

import UIKit

class Check {
    
    // 空欄チェック(返り値 -> 空欄あり：true, なし：false)
    func isEmpty(inputArray: String...) -> Bool {
        var resutlt = false
        inputArray.forEach { item in
            if item.isEmpty {
                resutlt = true
            }
        }
        return resutlt
    }
    
    // 同値チェック(返り値 -> 同値でない：true, 同値：false)
    func isNotEqual(str1: String, str2: String) -> Bool {
        if str1 != str2 {
            return true
        }
        return false
    }
    
    // メールアドレス書式チェック(返り値 -> 誤：true, 正：false)
    func mailAddressFormatCheck(address: String) -> Bool {
        // [大文字小文字英数字と._%+-]@[大文字小文字英数字.-].[2文字から4文字の大文字小文字英数字]
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: address)
        return !result
    }
    
    // 文字数チェック(返り値 -> minCountより下：true, 以上：false)
    func charaMinCountCheck(str:String, minCount: Int) -> Bool {
        if str.count < minCount {
            return true
        }
        return false
    }
}
