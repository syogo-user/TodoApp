//
//  LoginViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/08.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
    }
    
    @objc private func login(){
        guard let address = mailAddressTextField.text, let password = passwordTextField.text else{return}
        // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
        if address.isEmpty || password.isEmpty {
            //TODO メッセージ表示
            return
        }
        Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
            if error != nil {
                //TODO エラーメッセージ表示
                return
            }
            //画面を閉じる
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc private func createAccount(){
        //アカウント作成画面に遷移
        let accountCreateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcountCreateViewController") as! AccountCreateViewController

        accountCreateViewController.mailAddress = self.mailAddressTextField.text ?? ""
        accountCreateViewController.password = self.passwordTextField.text ?? ""
        accountCreateViewController.modalPresentationStyle = .fullScreen
        self.present(accountCreateViewController, animated: true, completion: nil)
    }
    
    
    

}
