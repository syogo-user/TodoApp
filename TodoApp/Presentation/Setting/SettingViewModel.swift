//
//  SettingViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import Amplify
import AWSCognitoAuthPlugin
import RxSwift
import RxCocoa
import Foundation

protocol SettingViewModel {
    /// Eメール
    var userEmail: Signal<VMResult<UserInfoAttribute>?> { get }
    /// サインアウト
    func signOutLocally() async
    /// セッション情報を取得
    func fetchCurrentAuthSession() async
    /// ユーザ情報取得
    func loadUser()
    /// ユーザ情報削除
    func deleteLocalUser(userId: String)
}

class SettingViewModelImpl: SettingViewModel {
    private var disposeBag = DisposeBag()
    private let usecase: UserUseCase = UserUseCaseImpl()
    private let userInfoRelay = BehaviorRelay<VMResult<UserInfoAttribute>?>(value: nil)
    lazy var userEmail = userInfoRelay.asSignal(onErrorSignalWith: .empty())

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

    func fetchCurrentAuthSession() async {
        await usecase.fetchCurrentAuthSession()
    }

    func loadUser() {
        usecase.loadLocalUser()
            .map { result -> VMResult<UserInfoAttribute> in
                let userInfo = UserInfoAttribute(userId: result.userId, email: result.email)
                return VMResult(data: userInfo)
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: userInfoRelay)
            .disposed(by: disposeBag)
    }

    func deleteLocalUser(userId: String) {
        usecase.deleteLocalUser(userId: userId)
    }
}
