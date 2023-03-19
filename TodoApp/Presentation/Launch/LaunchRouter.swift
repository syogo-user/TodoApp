//
//  LaunchRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit

extension LaunchViewContoller {

    func toSignIn() {
        // サインインしていない場合
        guard let signInVC = R.storyboard.signIn.signInVC() else { return }
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
    }

    func toTabBar() {
        guard let tabBarVC = R.storyboard.main.tabBarVC() else { return }
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: false, completion: nil)
    }
}
