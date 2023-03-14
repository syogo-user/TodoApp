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
        viewModel.loadUser()
        bindViewModelEvent()
    }

    @IBAction func signOut(_ sender: Any) {
        Task {
            await viewModel.signOutLocally()
            guard let userId = userInfo?.userId else { return }
            viewModel.deleteLocalUser(userId: userId)
        }
    }

    // TODO: 後で削除
    @IBAction private func currentToken(_ sender: Any) {
        Task {
            await viewModel.fetchCurrentAuthSession()
        }
    }

    private func bindViewModelEvent() {
        viewModel.userEmail
            .emit(onNext: { [unowned self] result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error)
                }
                if let userInfo = result.data {
                    self.userInfo = userInfo
                    print("userId:\(self.userInfo?.userId),email:\(self.userInfo?.email)")
                }
            })
            .disposed(by: disposeBag)
    }
}
