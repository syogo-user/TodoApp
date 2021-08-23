//
//  AccountCreateViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/09.
//

import UIKit
import Firebase
import SVProgressHUD

class AccountCreateViewController: UIViewController {
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var newAccountCreateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var mailAddress = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newAccountCreateButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        setDisplay()
    }
    
    private func setDisplay() {
        if !self.mailAddress.isEmpty {
            // 画面遷移時メールアドレスが入力されている場合
            self.mailAddressTextField.text = mailAddress
        }
        if !self.password.isEmpty {
            // 画面遷移時パスワードが入力されている場合
            self.passwordTextField.text = password
        }
    }
    
    // アカウント作成
    @objc private func createAccount() {
        guard let address = mailAddressTextField.text, let password = passwordTextField.text,
              let passwordCheck = passwordCheckTextField.text, let displayName = nickNameTextField.text else { return }
        // 入力チェック
        if validate(address: address, password: password, passwordCheck: passwordCheck, displayName: displayName) {
            return
        }
        // ローディング表示
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
            if error != nil {
                SVProgressHUD.showError(withStatus: Const.Message9)
                return
            }            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                // 名前の前後の空白を削除
                let trimDisplayName = displayName.trimmingCharacters(in: .whitespaces)
                changeRequest.displayName = trimDisplayName
                changeRequest.commitChanges { error in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: Const.Message10)
                        return
                    }
                    SVProgressHUD.dismiss()
                    // 画面を閉じて画面に戻る
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    // キャンセル
    @objc private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 入力チェック
    private func validate(address: String, password: String, passwordCheck: String, displayName: String) -> Bool {
        // 空欄チェック
        if address.isEmpty || password.isEmpty || passwordCheck.isEmpty || displayName.isEmpty {
            SVProgressHUD.showError(withStatus: Const.Message1)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        //メールアドレスチェック
        if !address.mailAddressFormatCheck() {
            SVProgressHUD.showError(withStatus: Const.Message2)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // パスワード文字数
        if password.count < 6 || passwordCheck.count < 6 {
            SVProgressHUD.showError(withStatus: Const.Message3)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // パスワードの一致
        if password != passwordCheck {
            SVProgressHUD.showError(withStatus: Const.Message4)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }                        
        // エラーがない場合 falseを返却
        return false
    }
}
