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
    func loadLocalUserInfo() -> Single<UserInfoRecord>
    /// ローカルにユーザを追加する
    func insertLocalUserInfo(userInfo: UserInfoRecord)
    ///  ローカルのユーザ情報を削除する
    func deleteLocalUserInfo(userId: String)
}

class UserInfoDaoImpl: UserInfoDao {
    func loadLocalUserInfo() -> Single<UserInfoRecord> {
        MainDatabase.shared.dbQueue()
            .flatMap { dbQueue in
                dbQueue.rx.read { db in
                    guard let userInfoRecord = try UserInfoRecord.fetchOne(db) else {
                        // TODO: エラークラスを作成する
                        throw NSError(domain: "fetchError", code: 0, userInfo: nil)
                    }
                    return userInfoRecord
                }
            }
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

    func deleteLocalUserInfo(userId: String) {
        do {
            let dbQueue: DatabaseQueue = try MainDatabase.shared.dbQueue()
            let _ = try dbQueue.write { db in
                // 指定されたuserIdを持つレコードを削除する
                try UserInfoRecord.deleteOne(db, key: userId)
            }
        } catch {
            // エラー処理を行う
        }
    }
}
