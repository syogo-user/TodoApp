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
    var isLoading: Driver<Bool> { get }
    var userInfo: Signal<VMResult<UserInfoAttribute>?> { get }
    var signOut: Signal<VMResult<Void>?> { get }
    /// サインアウト
    func signOutLocally()
    /// ユーザ情報取得
    func loadUser()
}

class SettingViewModelImpl: SettingViewModel {
    private let disposeBag = DisposeBag()
    private var userUseCase: UserUseCase = UserUseCaseImpl()
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()

    /// サインアウトの通知
    private let signOutRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var signOut = signOutRelay.asSignal(onErrorSignalWith: .empty())
    /// ユーザ情報の取得通知
    private let userInfoRelay = BehaviorRelay<VMResult<UserInfoAttribute>?>(value: nil)
    lazy var userInfo = userInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {
        Observable.merge(
            signOut.map { VMResult(data: $0?.data != nil) }.asObservable(),
            userInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        )
        .map { [unowned self] _ in
            (self.signOutRelay.value?.isLoading ?? false) ||
            (self.userInfoRelay.value?.isLoading ?? false)
        }
        .asDriver(onErrorJustReturn: false)
    }()

    func signOutLocally() {
        userUseCase.signOut()
            .flatMap {
                self.taskUseCase.deleteLocalTaskAll()
            }
            .flatMap {
                self.userUseCase.deleteLocalUser()
            }
            .do(onSuccess: { _ in
                self.userUseCase.sortOrder = nil
            })
            .map { result -> VMResult<Void> in
                .success(result)
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: signOutRelay)
            .disposed(by: disposeBag)

    }

    func loadUser() {
       userUseCase.loadLocalUser()
            .map { result -> VMResult<UserInfoAttribute> in
                return .success(result)
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: userInfoRelay)
            .disposed(by: disposeBag)
    }
}
