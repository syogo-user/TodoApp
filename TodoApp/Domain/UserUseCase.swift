//
//  UserUseCase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Amplify
import AWSPluginsCore
import RxSwift

protocol UserUseCase {
    /// サインアップ
    func signUp(userName: String, password: String, email: String) async
    /// 認証コード確認
    func confirmSignUp(for username: String, with confirmationCode: String) async
    /// 現在のセッション情報を取得
    func fetchCurrentAuthSession() async
    /// ログイン中かどうか判定
    func isSignIn() async -> Bool
    /// ユーザ情報を取得
    func fetchUserInfo() async -> [AuthUserAttribute]?
    /// ユーザ情報取得
    func loadLocalUser() -> Single<UserInfoRecord>
    /// ユーザ情報を登録
    func insertLocalUser(userId: String, email: String)
    /// ユーザ情報を削除
    func deleteLocalUser(userId: String) 
}

class UserUseCaseImpl: UserUseCase {
    private var repository: UserRepository = UserRepositoryImpl()

    func signUp(userName: String, password: String, email: String) async {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: userName,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
            } else {
                print("SignUp Complete")
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    func confirmSignUp(for username: String, with confirmationCode: String) async {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: username,
                confirmationCode: confirmationCode
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    func fetchCurrentAuthSession() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            print("Is user signed in - \(session.isSignedIn)")
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                print("tokens:\(tokens.idToken)")
            }
        } catch let error as AuthError {
            print("Fetch session failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    func isSignIn() async -> Bool {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            print("Is user signed in - \(session.isSignedIn)")
            return session.isSignedIn
        } catch let error as AuthError {
            print("Fetch session failed with error \(error)")
            return false
        } catch {
            print("Unexpected error: \(error)")
            return false
        }
    }

    func fetchUserInfo() async -> [AuthUserAttribute]? {
        do {
            let user = try await Amplify.Auth.fetchUserAttributes()
            dump(user)
            return user
        } catch let error as AuthError {
            print("Fetch session failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
        return nil
    }

    func loadLocalUser() -> Single<UserInfoRecord> {
        repository.loadLocalUser()
    }

    func insertLocalUser(userId: String, email: String) {
        repository.insertLocalUser(userId: userId, email: email)
    }

    func deleteLocalUser(userId: String) {
        repository.deleteLocalUser(userId: userId)
    }
}
