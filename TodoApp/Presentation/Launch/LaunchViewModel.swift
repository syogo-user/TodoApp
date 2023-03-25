//
//  LaunchViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol LaunchViewModel {
    var isSignInResult: Signal<VMResult<Bool>?> { get }
    func setUp()
    func isSignIn()
}

class LaunchViewModelImpl: LaunchViewModel {
    private var usecase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    /// サインインの判定通知
    private let isSignInRelay = BehaviorRelay<VMResult<Bool>?>(value: nil)
    lazy var isSignInResult = isSignInRelay.asSignal(onErrorSignalWith: .empty())

    func setUp() {
        usecase.isFromSignIn = false
    }

    func isSignIn() {
        usecase.isSignIn()
            .map { signInResult in
                 VMResult.success((signInResult))
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: isSignInRelay)
            .disposed(by: disposeBag)
    }
}
