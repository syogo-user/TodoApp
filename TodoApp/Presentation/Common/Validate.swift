//
//  Validate.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/21.
//

import Foundation

class Validate {
    /// 空欄チェック
    func isEmpty(inputArray: String...) -> Bool {
        var result = false
        inputArray.forEach { item in
            if item.isEmpty {
                result = true
            }
        }
        return result
    }

    /// 文字数チェック
    func isWordLengthOver(word: String, wordLimit: Int) -> Bool {
        word.count > wordLimit
    }
}
