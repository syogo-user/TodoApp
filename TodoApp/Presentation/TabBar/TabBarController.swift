//
//  TabBarController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit

class TabBarController: UITabBarController {
    private let viewModel: TabBarViewModel = TabBarViewModelImpl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            if await !viewModel.isSignIn() {
                self.toSignIn()
            }
        }
    }
}
