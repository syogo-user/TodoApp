//
//  UserRepository.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation
import APIKit
import RxSwift

protocol UserRepository {
    /// ユーザ情報を取得
    func loadLocalUser() throws -> UserInfoRecord
    /// ユーザ情報を追加
    func insertLocalUser(userId: String, email: String) -> Void
    /// ユーザ情報を削除
    func deleteLocalUser() -> Void
}

class UserRepositoryImpl: UserRepository {
    private let localStore: UserLocalStore = UserLocalStoreImpl()

    func loadLocalUser() throws -> UserInfoRecord {
        try localStore.loadLocalUserInfo()
    }

    func insertLocalUser(userId: String, email: String) -> Void {
        let userInfo = UserInfoRecord(userId: userId, email: email)
        localStore.insertLocalUser(userInfo: userInfo)
    }

    func deleteLocalUser() -> Void {
        localStore.deleteLocalUser()
    }
}
