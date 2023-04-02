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
    /// 並び順
    var sortOrder: String? { get set }
    /// トークンを取得
    func fetchCurrentAuthToken() -> Single<String>
    /// ユーザ情報を取得
    func fetchUserInfo() -> Single<[AuthUserAttribute]>
    /// ログイン中かどうか判定
    func isSignIn() -> Single<Bool>
    /// ソーシャルサインイン
    func socialSignIn(provider: AuthProvider) -> Single<Void>
    /// サインアウト
    func signOut() -> Single<Void>
    /// ユーザ情報取得
    func loadLocalUser() -> Single<UserInfoAttribute>
    /// ユーザ情報を登録
    func insertLocalUser(userId: String, email: String) -> Single<Void>
    /// ユーザ情報を削除
    func deleteLocalUser() -> Single<Void>
}

class UserUseCaseImpl: UserUseCase {
    private var repository: UserRepository = UserRepositoryImpl()

    var isFromSignIn: Bool {
        get { repository.isFromSignIn }
        set { repository.isFromSignIn = newValue }
    }

    var sortOrder: String? {
        get { repository.sortOrder }
        set { repository.sortOrder = newValue }
    }

    func fetchCurrentAuthToken() -> Single<String> {
        return Single.create { single in
            Task {
                do {
                    let token = try await self.repository.fetchCurrentAuthToken()
                    single(.success("Bearer " + token))
                } catch {
                    single(.error(DomainError.authError))
                }
            }
            return Disposables.create()
        }
    }

    func fetchUserInfo() -> Single<[AuthUserAttribute]> {
        return Single.create { single in
            Task {
                do {
                    guard let result = try await self.repository.fetchUserInfo() else {
                        throw DomainError.authError
                    }
                    single(.success(result))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    func isSignIn() -> Single<Bool> {
        return Single.create { single in
            Task {
                do {
                    let isSignIn = try await self.repository.isSignIn()
                    single(.success(isSignIn))
                } catch let error as AuthError {
                    print("Fetch session failed with error \(error)")
                    single(.error(DomainError.authError))
                } catch {
                    print("Unexpected error: \(error)")
                    single(.error(DomainError.authError))
                }
            }
            return Disposables.create()
        }
    }

    func socialSignIn(provider: AuthProvider) -> Single<Void> {
        return Single.create { single in
            Task {
                do {
                    let signInResult = try await self.repository.socialSignIn(provider: provider)
                    if signInResult.isSignedIn {
                        print("Sign in succeeded")
                        single(.success(()))
                    }
                    single(.error(DomainError.authError))
                } catch {
                    single(.error(DomainError.unKnownError))
                }
            }
            return Disposables.create()
        }
    }

    func signOut() -> Single<Void> {
        return Single.create { single in
            Task {
                do {
                    let result = await self.repository.signOut()
                    guard let signOutResult = result as? AWSCognitoSignOutResult else {
                        print("Signout failed")
                        throw DomainError.authError
                    }
                    switch signOutResult {
                    case .complete:
                        print("Signed out successfully")
                        single(.success(()))
                    case .partial:
                        single(.error(DomainError.authError))
                    case .failed(let error):
                        print("SignOut failed with \(error)")
                        single(.error(DomainError.authError))
                    }
                }
            }
            return Disposables.create()
        }
    }

    func loadLocalUser() -> Single<UserInfoAttribute> {
        repository.loadLocalUser()
            .map { user in
                if user.count != 1 {
                    throw DomainError.localDbError
                }
                guard let user = user.first else { throw DomainError.localDbError }
                return UserInfoAttribute(userId: user.userId, email: user.email)
            }
    }

    func insertLocalUser(userId: String, email: String) -> Single<Void> {
        repository.insertLocalUser(userId: userId, email: email)
    }

    func deleteLocalUser() -> Single<Void> {
        repository.deleteLocalUser()
    }
    
}
