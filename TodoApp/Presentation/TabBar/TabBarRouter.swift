//
//  TabBarRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit

extension TabBarController {

    func toSignIn() {
        // サインインしていない場合
        guard let signInVC = R.storyboard.signIn.signInVC() else { return }
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
    }
}
