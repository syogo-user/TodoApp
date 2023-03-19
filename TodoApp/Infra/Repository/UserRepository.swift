//
//  UserRepository.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/14.
//

import Foundation
import APIKit
import RxSwift
import Amplify

protocol UserRepository {
    /// トークンの取得
    func fetchCurrentAuthToken() async throws -> String
    /// ユーザ情報の取得
    func fetchUserInfo() async throws -> [AuthUserAttribute]?
    /// ローカルのユーザ情報を取得
    func loadLocalUser() -> Single<[UserInfoRecord]>
    /// ローカルにユーザ情報を追加
    func insertLocalUser(userId: String, email: String) -> Void
    /// ローカルのユーザ情報を削除
    func deleteLocalUser() -> Void
}

class UserRepositoryImpl: UserRepository {
    private let remoteStore: UserRemoteStore = UserRemoteStoreImpl()
    private let localStore: UserLocalStore = UserLocalStoreImpl()

    func fetchCurrentAuthToken() async throws -> String {
        try await remoteStore.fetchCurrentAuthToken()
    }

    func fetchUserInfo() async throws -> [AuthUserAttribute]? {
        try await remoteStore.fetchUserInfo()
    }

    func loadLocalUser() -> Single<[UserInfoRecord]> {
        localStore.loadLocalUserInfo()
    }

    func insertLocalUser(userId: String, email: String) -> Void {
        let userInfo = UserInfoRecord(userId: userId, email: email)
        localStore.insertLocalUser(userInfo: userInfo)
    }

    func deleteLocalUser() -> Void {
        localStore.deleteLocalUser()
    }
}
