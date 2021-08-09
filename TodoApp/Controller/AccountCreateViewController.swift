//
//  AccountCreateViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/09.
//

import UIKit
import Firebase
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
        newAccountCreateButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancell), for: .touchUpInside)
        //画面遷移時メールアドレスが入力されていたら
        if mailAddress != ""{
            self.mailAddressTextField.text = mailAddress
        }
        //画面遷移時パスワードが入力されていたら
        if password != "" {
            self.passwordTextField.text = password
        }
        
    }
    //アカウント作成
    @objc private func createAccount(){
        guard let address = mailAddressTextField.text, let password = passwordTextField.text, let passwordCheck = passwordCheckTextField.text,let displayName = nickNameTextField.text else {return}
            
        Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
            if error != nil {
                //TODO エラーメッセージ
                return
            }
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                //名前の前後の空白を削除
                let trimDisplayName = displayName.trimmingCharacters(in: .whitespaces)
                changeRequest.displayName = trimDisplayName
                changeRequest.commitChanges { error in
                    if error != nil {
                        // プロフィールの更新でエラーが発生
                        //TODO
                        return
                    }
                    // 画面を閉じて画面に戻る
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
              
    }
    //キャンセル
    @objc private func cancell(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
