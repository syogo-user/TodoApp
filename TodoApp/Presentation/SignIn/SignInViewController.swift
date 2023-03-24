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
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let viewModel: SignInViewModel = SignInViewModelImpl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelValue()
    }
    
    @IBAction private func signIn(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.signIn(userName: email, password: password)
    }
    
    @IBAction private func createAccount(_ sender: Any) {
        self.toAccount()
    }
        
    @IBAction private func googleSignIn(_ sender: Any) {
        viewModel.socialSigIn(provider: .google)
    }
    
    @IBAction private func appleSignIn(_ sender: Any) {
        viewModel.socialSigIn(provider: .apple)
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

    private func localDbErrorDialog() {
        self.showDialog(
            title: R.string.localizable.localDbErrorTitle(),
            message: R.string.localizable.localUserDBErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }
}
