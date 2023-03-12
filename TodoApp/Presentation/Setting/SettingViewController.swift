//
//  SettingViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var emailLabel: UILabel!

    private let viewModel: SettingViewModel = SettingViewModelImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signOut(_ sender: Any) {
        Task {
            await viewModel.signOutLocally()
        }
    }

    // TODO: 後で削除
    @IBAction private func currentToken(_ sender: Any) {
        Task {
            await viewModel.fetchCurrentAuthSession()
        }
    }
}
