//
//  UserLocalStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import Foundation
import RxSwift

protocol UserLocalStore {
    /// サインイン画面を経由したか
    var isFromSignIn: Bool { get set }
    /// ユーザ情報を取得
    func loadLocalUserInfo() throws -> [UserInfoRecord]
    /// ユーザ情報を追加
    func insertLocalUser(userInfo: UserInfoRecord) throws
    /// ユーザ情報を削除
    func deleteLocalUser() throws
}

class UserLocalStoreImpl: UserLocalStore {
    private let accessor: DBAccessor = GRDBAccessor()

    private enum Key: String {
        case isFromSignIn = "isFromSignIn"
    }

    var isFromSignIn: Bool {
        get { UserDefaults.standard.bool(forKey: Key.isFromSignIn.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.isFromSignIn.rawValue)}
    }

    func loadLocalUserInfo() throws -> [UserInfoRecord] {
        try accessor.userInfoDao.loadLocalUserInfo()
    }

    func insertLocalUser(userInfo: UserInfoRecord) throws {
        try accessor.userInfoDao.insertLocalUserInfo(userInfo: userInfo)
    }

    func deleteLocalUser() throws {
        try accessor.userInfoDao.deleteLocalUserInfo()
    }
}
