//
//  SignInRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Foundation
import UIKit

extension SignInViewController {
    /// タブバー画面に遷移
    func toTabBar() {
        guard let tabBarVC = R.storyboard.main.tabBarVC() else { return }
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: false, completion: nil)
    }
}
