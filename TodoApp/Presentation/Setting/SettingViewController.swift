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
                    self.handlerError(error: error) {

                    }
                }
                self.emailLabel.text = result.data?.email
            })
            .disposed(by: disposeBag)

        viewModel.signOut
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error) {

                    }
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


    private func tokenErrorDialog(completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: R.string.localizable.tokenErrorDialogTitle(), message: R.string.localizable.tokenErrorDialogMessage(), preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { action in
            completion?()
        }))
        self.present(dialog,animated: true,completion: nil)
    }

    private func localDbErrorDialog(completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: R.string.localizable.localDBErrorDialogTitle(), message: R.string.localizable.localDBErrorDialogMessage(), preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { action in
            completion?()
        }))
        self.present(dialog,animated: true,completion: nil)
    }
}
