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

protocol SignInViewModel: ObservableObject {
    /// ローディング
    var isLoading: Driver<Bool> { get }
    /// ユーザ情報通知
    var userInfo: Signal<VMResult<Void>?> { get }
    /// ソーシャルサインイン
    func socialSigIn(provider: AuthProvider) async throws
    /// サインイン画面を経由したことを設定
    func setViaSignIn()
}

@MainActor
class SignInViewModelImpl: SignInViewModel {
    private var useCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    /// ユーザ情報通知
    private let userInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var userInfo = userInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {
        userInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        .map { [unowned self] _ in
            self.userInfoRelay.value?.isLoading ?? false
        }
        .asDriver(onErrorJustReturn: false)
    }()

    func socialSigIn(provider: AuthProvider) async throws {
        try await useCase.socialSignIn(provider: provider)
        let userInfo = try await useCase.fetchUserInfo()
        let subAttribute = userInfo.filter { $0.key == .sub }.first
        let emailAttribute = userInfo.filter { $0.key == .email }.first
        guard let userId = subAttribute?.value else {
            throw DomainError.authError
        }
        guard let email = emailAttribute?.value else {
            throw DomainError.authError
        }
        try useCase.insertLocalUser(userId: userId, email: email)
//            .flatMap { () in
//                self.useCase.fetchUserInfo()
//            }
//            .flatMap { userInfo in
//                let subAttribute = userInfo.filter { $0.key == .sub }.first
//                let emailAttribute = userInfo.filter { $0.key == .email }.first
//                guard let userId = subAttribute?.value else {
//                    throw DomainError.authError
//                }
//                guard let email = emailAttribute?.value else {
//                    throw DomainError.authError
//                }
//                return self.useCase.insertLocalUser(userId: userId, email: email)
//            }
//            .map {
//                return .success(())
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: userInfoRelay)
//            .disposed(by: disposeBag)
    }

    func setViaSignIn() {
        useCase.isFromSignIn = true
    }
}
