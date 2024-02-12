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
    /// サインアウト
    func signOut() async throws
    /// メールアドレス取得
    func loadEmail() throws -> String
}

@MainActor
class SettingViewModelImpl: SettingViewModel {
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private var taskUseCase: TaskUseCase = TaskUseCaseImpl()

    /// サインアウトの通知
//    private let signOutRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
//    lazy var signOutResult = signOutRelay.asSignal(onErrorSignalWith: .empty())

    /// ユーザ情報の取得通知
//    private let userInfoRelay = BehaviorRelay<VMResult<UserInfoAttribute>?>(value: nil)
//    lazy var userInfo = userInfoRelay.asSignal(onErrorSignalWith: .empty())

//    private(set) lazy var isLoading: Driver<Bool> = {
//        Observable.merge(
//            signOutResult.map { VMResult(data: $0?.data != nil) }.asObservable(),
//            userInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
//        )
//        .map { [unowned self] _ in
//            (self.signOutRelay.value?.isLoading ?? false) ||
//            (self.userInfoRelay.value?.isLoading ?? false)
//        }
//        .asDriver(onErrorJustReturn: false)
//    }()

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

    /// メールアドレス取得
    nonisolated func loadEmail() throws -> String {
        let email = try userUseCase.loadLocalUser().email
        return email
    }
}
