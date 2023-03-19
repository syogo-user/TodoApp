//
//  LaunchViewContoller.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit

class LaunchViewContoller: BaseViewController {
    private let viewModel: LaunchViewModel = LaunchViewModelImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setUp()
        Task {
            if await !viewModel.isSignIn() {
                self.toSignIn()
            } else {
                self.toTabBar()
            }
        }
    }
}
