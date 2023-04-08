//
//  UserRemoteStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import APIKit
import RxSwift
import Amplify
import AWSPluginsCore
import AWSCognitoAuthPlugin

protocol UserRemoteStore {
    /// トークンの取得
    func fetchCurrentAuthToken() async throws -> String
    /// ユーザ情報の取得
    func fetchUserInfo() async throws -> [AuthUserAttribute]?
    /// サインイン判定
    func isSignIn() async throws -> Bool
    /// ソーシャルサインイン
    func socialSignIn(provider: AuthProvider) async throws -> AuthSignInResult
    /// サインアウト
    func signOut() async -> AuthSignOutResult
}

class UserRemoteStoreImpl: UserRemoteStore {
    /// トークンの取得
    func fetchCurrentAuthToken() async throws -> String {
        guard let cognitoTokenProvider = try await Amplify.Auth.fetchAuthSession() as? AuthCognitoTokensProvider else {
            throw DomainError.authError
        }
        let token = try cognitoTokenProvider.getCognitoTokens().get()
        return token.idToken
    }

    /// ユーザ情報の取得
    func fetchUserInfo() async throws -> [AuthUserAttribute]? {
        try await Amplify.Auth.fetchUserAttributes()
    }

    /// サインイン判定
    func isSignIn() async throws -> Bool {
        let session = try await Amplify.Auth.fetchAuthSession()
        return session.isSignedIn
    }

    /// ソーシャルサインイン
    func socialSignIn(provider: AuthProvider) async throws -> AuthSignInResult {
        try await Amplify.Auth.signInWithWebUI(for: provider, presentationAnchor: nil)
    }

    /// サインアウト
    func signOut() async  -> AuthSignOutResult {
        await Amplify.Auth.signOut()
    }
}
