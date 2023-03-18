//
//  UserInfoDao.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/13.
//

import Foundation
import GRDB

protocol UserInfoDao {
    /// ユーザ情報を取得
    func loadLocalUserInfo() throws -> UserInfoRecord
    /// ローカルにユーザを追加する
    func insertLocalUserInfo(userInfo: UserInfoRecord)
    ///  ローカルのユーザ情報を削除する
    func deleteLocalUserInfo()
}

class UserInfoDaoImpl: UserInfoDao {

    func loadLocalUserInfo() throws -> UserInfoRecord {
        let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
        let userInfoRecord = try dbQueue.read { db in
            guard let userInfo = try UserInfoRecord.fetchOne(db) else {
                throw DomainError.localDBError
            }
            return userInfo
        }
        return userInfoRecord
    }

    func insertLocalUserInfo(userInfo: UserInfoRecord) {
        do {
            let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
            try dbQueue.write { db in
                try userInfo.insert(db)
            }
        } catch {

        }
    }

    func deleteLocalUserInfo() {
        do {
            let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
            let _ = try dbQueue.write { db in
                try UserInfoRecord.deleteAll(db)
            }
        } catch {
            // エラー処理を行う
        }
    }
}
