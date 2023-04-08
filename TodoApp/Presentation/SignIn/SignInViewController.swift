//
//  SignInViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/09.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin
import RxSwift

class SignInViewController: BaseViewController {
    private let viewModel: SignInViewModel = SignInViewModelImpl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelValue()
    }
    
    private func bindViewModelValue() {
        viewModel.isLoading
            .drive(onNext: { [unowned self] isLoading in
                self.setIndicator(show: isLoading)
            })
            .disposed(by: disposeBag)

        viewModel.userInfo
            .emit { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.signInErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
                self.viewModel.setViaSignIn()
                self.toTabBar()
            }
            .disposed(by: disposeBag)
    }

    private func signInErrorDialog() {
        self.showDialog(
            title: R.string.localizable.signInErrorTitle(),
            message: R.string.localizable.signInErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    @IBAction private func googleSignIn(_ sender: Any) {
        self.isConnect() {
            viewModel.socialSigIn(provider: .google)
        }
    }

    @IBAction private func appleSignIn(_ sender: Any) {
        self.isConnect() {
            viewModel.socialSigIn(provider: .apple)
        }
    }
}
