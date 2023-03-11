//
//  ViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/07.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // TODO: 一時的に直接サインイン画面に遷移する
        // ログインしていないときの処理
        let signInStoryboard =  UIStoryboard(name: "SignIn", bundle: nil)
        guard let signinVC = signInStoryboard.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController else { return }
        signinVC.modalPresentationStyle = .fullScreen
        self.present(signinVC, animated: true, completion: nil)
    }


}

