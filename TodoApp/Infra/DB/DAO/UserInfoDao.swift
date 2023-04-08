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
    /// ローカルユーザ情報取得
    func loadLocalUserInfo() -> Single<[UserInfoRecord]>
    /// ローカルユーザ追加
    func insertLocalUserInfo(userInfo: UserInfoRecord) -> Single<Void>
    ///  ローカルユーザ情報を削除
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
