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

protocol SettingViewModel: ObservableObject {
    /// ローディング
    var isLoading: Driver<Bool> { get }
    /// ユーザ情報取得通知
    var userInfo: Signal<VMResult<UserInfoAttribute>?> { get }
    /// サインアウト通知
    var signOutResult: Signal<VMResult<Void>?> { get }
    /// サインアウト
    func signOut() async throws
    /// ユーザ情報取得
    func loadUser()
}

@MainActor
class SettingViewModelImpl: SettingViewModel {
    private let disposeBag = DisposeBag()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private var taskUseCase: TaskUseCase = TaskUseCaseImpl()

    /// サインアウトの通知
    private let signOutRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var signOutResult = signOutRelay.asSignal(onErrorSignalWith: .empty())

    /// ユーザ情報の取得通知
    private let userInfoRelay = BehaviorRelay<VMResult<UserInfoAttribute>?>(value: nil)
    lazy var userInfo = userInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {
        Observable.merge(
            signOutResult.map { VMResult(data: $0?.data != nil) }.asObservable(),
            userInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        )
        .map { [unowned self] _ in
            (self.signOutRelay.value?.isLoading ?? false) ||
            (self.userInfoRelay.value?.isLoading ?? false)
        }
        .asDriver(onErrorJustReturn: false)
    }()

    /// サインアウト
    func signOut() async throws {
        try await userUseCase.signOut()
        try taskUseCase.deleteLocalTaskAll()
        try userUseCase.deleteLocalUser()
        taskUseCase.sortOrder = nil
        taskUseCase.filterCondition = nil
//            .flatMap {
//                self.taskUseCase.deleteLocalTaskAll()
//            }
//            .flatMap {
//                self.userUseCase.deleteLocalUser()
//            }
//            .do(onSuccess: { _ in
//                self.taskUseCase.sortOrder = nil
//                self.taskUseCase.filterCondition = nil
//            })
//            .map { result -> VMResult<Void> in
//                .success(result)
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: signOutRelay)
//            .disposed(by: disposeBag)
    }

    /// ローカルユーザ情報の取得
    func loadUser() {
//       userUseCase.loadLocalUser()
//            .map { result -> VMResult<UserInfoAttribute> in
//                return .success(result)
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: userInfoRelay)
//            .disposed(by: disposeBag)
    }
}
