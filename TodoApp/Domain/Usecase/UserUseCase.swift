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
    /// サインアップ
    func signUp(userName: String, password: String, email: String) async
    /// 認証コード確認
    func confirmSignUp(for username: String, with confirmationCode: String) async
    /// トークンを取得
    func fetchCurrentAuthToken() async throws -> String
    /// ログイン中かどうか判定
    func isSignIn() async -> Bool
    /// サインアウト
    func signOut() async throws
    /// ユーザ情報を取得
    func fetchUserInfo() async -> [AuthUserAttribute]?
    /// ユーザ情報取得
    func loadLocalUser() throws -> UserInfoAttribute
    /// ユーザ情報を登録
    func insertLocalUser(userId: String, email: String)
    /// ユーザ情報を削除
    func deleteLocalUser() 
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

    func fetchCurrentAuthToken() async throws -> String {
        guard let cognitoTokenProvider = try await Amplify.Auth.fetchAuthSession() as? AuthCognitoTokensProvider else {
            throw DomainError.authError
        }
        let token = try cognitoTokenProvider.getCognitoTokens().get()
        return token.idToken
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

    func signOut() async throws {
        let auth = Amplify.Auth
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            print("Signed out successfully")

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            throw DomainError.authError
        case .failed(let error):
            print("SignOut failed with \(error)")
            throw DomainError.authError
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

    func loadLocalUser() throws -> UserInfoAttribute {
        let user = try repository.loadLocalUser()
        return UserInfoAttribute(userId: user.userId, email: user.email)
    }

    func insertLocalUser(userId: String, email: String) {
        repository.insertLocalUser(userId: userId, email: email)
    }

    func deleteLocalUser() {
        repository.deleteLocalUser()
    }
    
}
