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
    private var userInfo: UserInfoAttribute? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try viewModel.loadUser()
        } catch {
            self.handlerError(error: error) {
                // ダイアログ表示

            }
        }
    }

    @IBAction func signOut(_ sender: Any) {
        Task {
            do {
                try await viewModel.signOutLocally()
                viewModel.deleteLocalUser()
                // 左タブを選択
                self.tabBarController?.selectedIndex = 0
                toSignIn()
            } catch {
                self.handlerError(error: error) {

                }
            }
        }
    }

    private func signOut() {
        Task {
            do {
                // サインアウト
                try await viewModel.signOutLocally()
                viewModel.deleteLocalUser()
                toSignIn()
            } catch {
                self.handlerError(error: DomainError.localDBError) {
                    localDbErrorDialog()
                }
            }
        }
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
