//
//  SignInViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Amplify
import AWSCognitoAuthPlugin
import RxSwift
import RxCocoa

protocol SignInViewModel {
    var userInfo: Signal<VMResult<Void>?> { get }
    /// サインイン
    func signIn(userName: String, password: String)
    /// ソーシャルサインイン
    func socialSigIn(provider: AuthProvider)
    /// サインイン画面を経由したことを設定
    func setViaSignIn()
}

class SignInViewModelImpl: SignInViewModel {
    private var usecase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    /// ユーザの登録通知
    private let userInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var userInfo = userInfoRelay.asSignal(onErrorSignalWith: .empty())
    
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

    func socialSigIn(provider: AuthProvider) {
        self.usecase.socialSignInWithWebUI(provider: provider)
            .flatMap { () in
                self.usecase.fetchUserInfo()
            }
            .flatMap { userInfo in
                let subAttribute = userInfo.filter { $0.key == .sub }.first
                let emailAttribute = userInfo.filter { $0.key == .email }.first
                guard let userId = subAttribute?.value else {
                    throw DomainError.authError
                }
                guard let email = emailAttribute?.value else {
                    throw DomainError.authError
                }
                return self.usecase.insertLocalUser(userId: userId, email: email)
            }
            .map {
                return .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: userInfoRelay)
            .disposed(by: disposeBag)
    }

    func setViaSignIn() {
        usecase.isFromSignIn = true
    }

    private func validate() -> Bool {
        // TODO: バリデーション
        return true
    }



}
