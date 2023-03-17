//
//  UserLocalStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import Foundation
import APIKit
import RxSwift

protocol UserLocalStore {
    /// ユーザ情報を取得
    func loadLocalUserInfo() throws -> UserInfoRecord
    /// ユーザ情報を追加
    func insertLocalUser(userInfo: UserInfoRecord) -> Void
    /// ユーザ情報を削除
    func deleteLocalUser() -> Void
}

class UserLocalStoreImpl: UserLocalStore {
    private let dao: UserInfoDao = UserInfoDaoImpl()

    func loadLocalUserInfo() throws -> UserInfoRecord {
       try dao.loadLocalUserInfo()
    }

    func insertLocalUser(userInfo: UserInfoRecord) -> Void {
        dao.insertLocalUserInfo(userInfo: userInfo)
    }

    func deleteLocalUser() -> Void {
        dao.deleteLocalUserInfo()
    }
}
