//
//  LaunchViewContoller.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LaunchViewContoller: BaseViewController {
    private let viewModel: LaunchViewModel = LaunchViewModelImpl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setUp()
        bindViewModelValue()
        viewModel.isSignIn()
    }

    private func bindViewModelValue() {
        viewModel.isSignInResult
            .emit { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
//                    self.handlerError(
//                        error: error,
//                        onAuthError: { self.sessionErrorDialog() },
//                        onUnKnowError: { self.unKnowErrorDialog() }
//                    )
                    return
                }
                guard let isSignIn = result.data else { return }
//                if isSignIn {
//                    self.toTabBar()
//                } else {
//                    self.toSignIn()
//                }
            }
            .disposed(by: disposeBag)
    }
}
