//
//  UserUseCase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Amplify
import AWSPluginsCore
import AWSCognitoAuthPlugin
import RxSwift

protocol UserUseCase {
    /// サインイン画面を経由したか
    var isFromSignIn: Bool { get set }
    /// トークンを取得
    func fetchCurrentAuthToken() async throws -> String
    /// ユーザ情報を取得
    func fetchUserInfo() async throws -> [AuthUserAttribute]
    /// ログイン中かどうか判定
    func isSignIn() -> Single<Bool>
    /// ソーシャルサインイン
    func socialSignIn(provider: AuthProvider) async throws
    /// サインアウト
    func signOut() async throws 
    /// ユーザ情報取得
    func loadLocalUser() throws -> UserInfoAttribute
    /// ユーザ情報を登録
    func insertLocalUser(userId: String, email: String) throws
    /// ユーザ情報を削除
    func deleteLocalUser() throws
}

class UserUseCaseImpl: UserUseCase {
    private var repository: UserRepository = UserRepositoryImpl()
    
    /// サインイン画面を経由したか
    var isFromSignIn: Bool {
        get { repository.isFromSignIn }
        set { repository.isFromSignIn = newValue }
    }

    /// トークンを取得
    func fetchCurrentAuthToken() async throws -> String {
        do {
            return try await self.repository.fetchCurrentAuthToken()
        } catch {
            throw DomainError.authError
        }
    }

    /// ユーザ情報を取得
    func fetchUserInfo() async throws -> [AuthUserAttribute] {
        do {
            return try await self.repository.fetchUserInfo() ?? []
        } catch {
            throw DomainError.authError
        }
    }

    /// ログイン中かどうか判定
    func isSignIn() -> Single<Bool> {
        return Single.create { single in
            Task {
                do {
                    let isSignIn = try await self.repository.isSignIn()
                    single(.success(isSignIn))
                } catch let error as AuthError {
                    print("Fetch session failed with error \(error)")
//                    single(.error(DomainError.authError))
                } catch {
                    print("Unexpected error: \(error)")
//                    single(.error(DomainError.authError))
                }
            }
            return Disposables.create()
        }
    }

    /// ソーシャルサインイン
    func socialSignIn(provider: AuthProvider) async throws {
        do {
            let signInResult = try await self.repository.socialSignIn(provider: provider)
            if !signInResult.isSignedIn {
                throw DomainError.authError
            }
        } catch {
            throw DomainError.authError
        }
    }

    /// サインアウト
    func signOut() async throws {
        let result = await self.repository.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            throw DomainError.authError
        }
        
        switch signOutResult {
        case .complete:
            print("Signed out successfully")
        case .partial:
            throw DomainError.authError
        case .failed(_):
            throw DomainError.authError
        }
    }

    /// ユーザ情報取得
    func loadLocalUser() throws -> UserInfoAttribute {
        do {
            let localUser = try repository.loadLocalUser().map { user in
                UserInfoAttribute(userId: user.userId, email: user.email)
            }
            if localUser.count != 1 {
                throw DomainError.localDbError
            }
            return localUser[0]
        } catch {
            throw DomainError.localDbError
        }
    }
    
    /// ユーザ情報を登録
    func insertLocalUser(userId: String, email: String) throws {
        do {
            try repository.insertLocalUser(userId: userId, email: email)
        } catch {
            throw DomainError.localDbError
        }
    }

    /// ユーザ情報を削除
    func deleteLocalUser() throws {
        do {
            try repository.deleteLocalUser()
        } catch {
            throw DomainError.localDbError
        }
    }
}
