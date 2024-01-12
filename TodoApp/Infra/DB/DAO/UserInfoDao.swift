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
    func loadLocalUserInfo() throws -> [UserInfoRecord]
    /// ローカルユーザ追加
    func insertLocalUserInfo(userInfo: UserInfoRecord) throws -> Void
    ///  ローカルユーザ情報を削除
    func deleteLocalUserInfo() throws -> Void
}

class UserInfoDaoImpl: GRDBAccessor, UserInfoDao {

    func loadLocalUserInfo() throws -> [UserInfoRecord] {
        try! readFromDBwith { db in
            try UserInfoRecord.fetchAll(db)
        }
    }

    func insertLocalUserInfo(userInfo: UserInfoRecord) throws -> Void {
        try writeToDBwith { db in
            try userInfo.insert(db)
        }
    }

    func deleteLocalUserInfo() throws -> Void {
        try writeToDBwith { db in
            try UserInfoRecord.deleteAll(db)
        }
    }
}
