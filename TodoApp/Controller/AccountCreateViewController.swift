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
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
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
                SVProgressHUD.showError(withStatus: Const.message9)
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
                        SVProgressHUD.showError(withStatus: Const.message10)
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
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // 入力チェック
    private func validate(address: String, password: String, passwordCheck: String, displayName: String) -> Bool {
        let check = Check()
        // 空欄チェック
        if check.isEmpty(inputArray: address, password, passwordCheck, displayName) {
            SVProgressHUD.showError(withStatus: Const.message1)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        //メールアドレスチェック
        if check.mailAddressFormatCheck(address: address) {
            SVProgressHUD.showError(withStatus: Const.message2)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // パスワード文字数
        if check.charaMinCountCheck(str: password, minCount: 6) || check.charaMinCountCheck(str: passwordCheck, minCount: 6) {
            SVProgressHUD.showError(withStatus: Const.message3)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // パスワードの一致
        if check.isNotEqual(str1: password, str2: passwordCheck) {
            SVProgressHUD.showError(withStatus: Const.message4)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // エラーがない場合 falseを返却
        return false
    }
}
