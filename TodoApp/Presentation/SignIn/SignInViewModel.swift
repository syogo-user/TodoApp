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
    // ユーザ情報(ユーザID,ユーザ名)をローカルDBに設定
    func setUserInfo()
}

class SignInViewModelImpl: SignInViewModel {
    private let usecase: UserUseCase = UserUseCaseImpl()
    private var disposeBag = DisposeBag()

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

    func setUserInfo() {
        usecase.fetchUserInfo()
            .do(onSuccess: { userInfo in
                let subAttribute = userInfo.filter { $0.key == .sub }.first
                let emailAttribute = userInfo.filter { $0.key == .email }.first
                guard let userId = subAttribute?.value else { return }
                guard let email = emailAttribute?.value else { return }
                self.usecase.insertLocalUser(userId: userId, email: email)
            })
            .map { result -> VMResult<Void> in
                return .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: userInfoRelay)
            .disposed(by: disposeBag)
    }

    private func validate() -> Bool {
        // TODO: バリデーション
        return true
    }

}
