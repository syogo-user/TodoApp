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
    /// サインアウト
    func signOutLocally() async
    /// セッション情報を取得
    func fetchCurrentAuthSession() async
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
    
    private func validate() -> Bool {
        // TODO: バリデーション
        return true
    }
        
    func fetchCurrentAuthSession() async {
        await usecase.fetchCurrentAuthSession()
    }
    
    func signOutLocally() async {
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
            
            if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))")
            }

            if let globalSignOutError = globalSignOutError {
                print("GlobalSignOut error  \(String(describing: globalSignOutError))")
            }

            if let revokeTokenError = revokeTokenError {
                print("Revoke token error  \(String(describing: revokeTokenError))")
            }

        case .failed(let error):
            print("SignOut failed with \(error)")
        }
    }
}
