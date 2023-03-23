//
//  UserInfoDao.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import Foundation
import GRDB
import RxGRDB
import RxSwift

protocol UserInfoDao {
    /// ユーザ情報を取得
    func loadLocalUserInfo() -> Single<[UserInfoRecord]>
    /// ローカルにユーザを追加する
    func insertLocalUserInfo(userInfo: UserInfoRecord) -> Single<Void>
    ///  ローカルのユーザ情報を削除する
    func deleteLocalUserInfo() -> Single<Void>
}

class UserInfoDaoImpl: GRDBAccessor, UserInfoDao {

    func loadLocalUserInfo() -> Single<[UserInfoRecord]> {
        readFromDBwith { db in
            try UserInfoRecord.fetchAll(db)
        }
    }

    func insertLocalUserInfo(userInfo: UserInfoRecord) -> Single<Void> {
        return writeToDBwith { db in
            try userInfo.insert(db)
        }
    }

    func deleteLocalUserInfo() -> Single<Void> {
        writeToDBwith { db in
            try UserInfoRecord.deleteAll(db)
        }
    }
}
