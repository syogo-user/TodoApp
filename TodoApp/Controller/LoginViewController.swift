//
//  LoginViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/08.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        self.createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func login() {
        guard let address = mailAddressTextField.text, let password = passwordTextField.text else { return }
        // 入力チェック
        if validate(address: address, password: password) {
            return
        }
        // ローディング表示
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
            if error != nil {
                SVProgressHUD.showError(withStatus: Const.message8)
                return
            }
            SVProgressHUD.dismiss()
            // 画面を閉じる
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func createAccount() {
        // アカウント作成画面に遷移
        let accountCreateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AcountCreateViewController") as! AccountCreateViewController
        accountCreateViewController.mailAddress = self.mailAddressTextField.text ?? ""
        accountCreateViewController.password = self.passwordTextField.text ?? ""
        accountCreateViewController.modalPresentationStyle = .fullScreen
        self.present(accountCreateViewController, animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
        
    private func validate(address: String, password: String) -> Bool {
        let check = Check()
        // 空欄チェック
        if check.isEmpty(inputArray: address, password) {
            SVProgressHUD.showError(withStatus: Const.message5)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // メールアドレスチェック
        if check.mailAddressFormatCheck(address: address) {
            SVProgressHUD.showError(withStatus: Const.message2)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // パスワード文字数
        if check.charaMinCountCheck(str: password, minCount: 6) {
            SVProgressHUD.showError(withStatus: Const.message3)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // エラーがない場合 falseを返却
        return false
    }

}
