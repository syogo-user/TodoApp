//
//  SettingViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation

class SettingViewController: BaseViewController {

    @IBOutlet weak var emailLabel: UILabel!
    private let disposeBag = DisposeBag()
    private let viewModel: SettingViewModel = SettingViewModelImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadUser()
        bindViewModelValue()
    }

    private func bindViewModelValue() {
        viewModel.isLoading
            .drive(onNext: { [unowned self] isLoading in
                self.setIndicator(show: isLoading)
            })
            .disposed(by: disposeBag)

        viewModel.userInfo
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onLocalDbError: { self.localDbErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
                self.emailLabel.text = result.data?.email
            })
            .disposed(by: disposeBag)

        viewModel.signOut
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.signOutErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    return
                }
                // 左タブを選択
                self.tabBarController?.selectedIndex = 0
                self.toSignIn()
            })
            .disposed(by: disposeBag)
    }

    @IBAction func signOut(_ sender: Any) {
        viewModel.signOutLocally()
    }


    private func signOutErrorDialog() {
        self.showDialog(
            title: R.string.localizable.signOutErrorTitle(),
            message: R.string.localizable.signOutErrorMessage(),
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
