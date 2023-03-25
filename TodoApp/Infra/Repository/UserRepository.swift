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
    /// サインイン画面を経由したか
    var isFromSignIn: Bool { get set }
    /// トークンの取得
    func fetchCurrentAuthToken() async throws -> String
    /// ユーザ情報の取得
    func fetchUserInfo() async throws -> [AuthUserAttribute]?
    /// サインイン判定
    func isSignIn() async throws -> Bool
    /// ソーシャルサインイン
    func sosialSignIn(provider: AuthProvider) async throws -> AuthSignInResult
    /// サインアウト
    func signOut() async -> AuthSignOutResult 
    /// ローカルのユーザ情報を取得
    func loadLocalUser() -> Single<[UserInfoRecord]>
    /// ローカルにユーザ情報を追加
    func insertLocalUser(userId: String, email: String) -> Single<Void>
    /// ローカルのユーザ情報を削除
    func deleteLocalUser() -> Single<Void>
}

class UserRepositoryImpl: UserRepository {
    private let remoteStore: UserRemoteStore = UserRemoteStoreImpl()
    private var localStore: UserLocalStore = UserLocalStoreImpl()

    var isFromSignIn: Bool {
        get { localStore.isFromSignIn }
        set { localStore.isFromSignIn = newValue }
    }

    func fetchCurrentAuthToken() async throws -> String {
        try await remoteStore.fetchCurrentAuthToken()
    }

    func fetchUserInfo() async throws -> [AuthUserAttribute]? {
        try await remoteStore.fetchUserInfo()
    }

    func isSignIn() async throws -> Bool {
        try await remoteStore.isSignIn()
    }

    func sosialSignIn(provider: AuthProvider) async throws -> AuthSignInResult {
        try await remoteStore.socialSignIn(provider: provider)
    }

    func signOut() async -> AuthSignOutResult {
        await remoteStore.signOut()
    }

    func loadLocalUser() -> Single<[UserInfoRecord]> {
        localStore.loadLocalUserInfo()
    }

    func insertLocalUser(userId: String, email: String) -> Single<Void> {
        let userInfo = UserInfoRecord(userId: userId, email: email)
        return localStore.insertLocalUser(userInfo: userInfo)
    }

    func deleteLocalUser() -> Single<Void> {
        localStore.deleteLocalUser()
    }
}
