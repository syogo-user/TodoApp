//
//  TabBarViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/15.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO ログアウト機能を別で設ける
        // ログアウトする
//        try! Auth.auth().signOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
