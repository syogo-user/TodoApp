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
    /// サインインの判定通知
    var isSignInResult: Signal<VMResult<Bool>?> { get }
    /// セットアップ
    func setUp()
    /// サインインの判定
    func isSignIn()
}

class LaunchViewModelImpl: LaunchViewModel {
    private let disposeBag = DisposeBag()
    private var usecase: UserUseCase = UserUseCaseImpl()

    /// サインインの判定通知
    private let isSignInRelay = BehaviorRelay<VMResult<Bool>?>(value: nil)
    lazy var isSignInResult = isSignInRelay.asSignal(onErrorSignalWith: .empty())

    /// セットアップ
    func setUp() {
        usecase.isFromSignIn = false
    }
    
    /// サインインの判定
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
