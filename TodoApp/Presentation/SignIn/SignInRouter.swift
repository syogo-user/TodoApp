//
//  SignInRouter.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Foundation
import UIKit

extension SignInViewController {
    func toAccount() {
        guard let signUpVC = R.storyboard.signIn.signUpVC() else { return }
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true, completion: nil)
    }
}
