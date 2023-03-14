//
//  SignInViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Amplify
import AWSCognitoAuthPlugin

protocol SignInViewModel {
    /// サインイン
    func signIn(userName: String, password: String)
    // ユーザ情報(ユーザID,ユーザ名)をローカルDBに設定
    func setUserInfo()
}

class SignInViewModelImpl: SignInViewModel {
    private let usecase: UserUseCase = UserUseCaseImpl()
        
    func signIn(userName: String, password: String) {
        Task {
            do {
                let signInResult = try await Amplify.Auth.signIn(
                    username: userName,
                    password: password
                )
                if signInResult.isSignedIn {
                    print("Sign in succeeded")
                }
            } catch let error as AuthError {
                print("Sign in failed \(error)")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }

    func setUserInfo() {
        Task {
            let userInfo = await usecase.fetchUserInfo()
            let subAttribute = userInfo?.filter { $0.key == .sub }.first
            let emailAttribute = userInfo?.filter { $0.key == .email }.first
            guard let userId = subAttribute?.value else { return }
            guard let email = emailAttribute?.value else { return }
            usecase.insertLocalUser(userId: userId, email: email)
        }
    }

    private func validate() -> Bool {
        // TODO: バリデーション
        return true
    }

}
