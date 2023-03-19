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
    func loadLocalUserInfo() -> Single<[UserInfoRecord]>
    /// ユーザ情報を追加
    func insertLocalUser(userInfo: UserInfoRecord) -> Void
    /// ユーザ情報を削除
    func deleteLocalUser() -> Void
}

class UserLocalStoreImpl: UserLocalStore {
    private let dao: UserInfoDao = UserInfoDaoImpl()
    private enum Key: String {
        case isFromSignIn = "isFromSignIn"
    }

    var isFromSignIn: Bool {
        get { UserDefaults.standard.bool(forKey: Key.isFromSignIn.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.isFromSignIn.rawValue)}
    }

    func loadLocalUserInfo() -> Single<[UserInfoRecord]> {
       dao.loadLocalUserInfo()
    }

    func insertLocalUser(userInfo: UserInfoRecord) -> Void {
        dao.insertLocalUserInfo(userInfo: userInfo)
    }

    func deleteLocalUser() -> Void {
        dao.deleteLocalUserInfo()
    }
}
