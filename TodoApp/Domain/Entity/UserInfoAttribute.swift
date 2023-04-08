//
//  UserInfoAttribute.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation

class UserInfoAttribute {
    /// ユーザID
    let userId: String
    /// メールアドレス
    let email: String

    init(userId: String, email:String) {
        self.userId = userId
        self.email = email
    }
}
