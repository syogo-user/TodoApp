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
    /// 並び順
    var sortOrder: String? { get set }
    /// ユーザ情報を取得
    func loadLocalUserInfo() -> Single<[UserInfoRecord]>
    /// ユーザ情報を追加
    func insertLocalUser(userInfo: UserInfoRecord) -> Single<Void>
    /// ユーザ情報を削除
    func deleteLocalUser() -> Single<Void>
}

class UserLocalStoreImpl: UserLocalStore {
    private let accessor: DBAccessor = GRDBAccessor()
    private enum Key: String {
        case isFromSignIn = "IsFromSignIn"
        case sortOrder = "SortOrder"
    }

    var isFromSignIn: Bool {
        get { UserDefaults.standard.bool(forKey: Key.isFromSignIn.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.isFromSignIn.rawValue)}
    }

    var sortOrder: String? {
        get { UserDefaults.standard.string(forKey: Key.sortOrder.rawValue)}
        set { UserDefaults.standard.set(newValue, forKey: Key.sortOrder.rawValue)}
    }

    func loadLocalUserInfo() -> Single<[UserInfoRecord]> {
        accessor.userInfoDao.loadLocalUserInfo()
    }

    func insertLocalUser(userInfo: UserInfoRecord) -> Single<Void> {
        accessor.userInfoDao.insertLocalUserInfo(userInfo: userInfo)
    }

    func deleteLocalUser() -> Single<Void> {
        accessor.userInfoDao.deleteLocalUserInfo()
    }
}
