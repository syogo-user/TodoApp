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
}
