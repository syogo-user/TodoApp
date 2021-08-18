//
//  PostViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//
import Firebase
import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var inputTitleTextField: UITextField!
    @IBOutlet weak var inputContentView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    var maxOrderNo = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTitleTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        postButton.addTarget(self, action: #selector(postTask), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTitleTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // キーボードが表示されるとき
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    // キーボードが隠れるとき
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
        
    // タスクを登録する
    @objc private func postTask() {
        if (inputTitleTextField.text == nil || inputContentView.text.isEmpty) {
            // TODO エラーのメッセージを出力
            return
        }
        // ログインuserIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let selectDate = Date().dateFormat()
        let newTask = Task(taskId: "", title: inputTitleTextField.text! , content: inputContentView.text, uid: uid, date: selectDate, order: maxOrderNo + 1)
        API.shared.createTask(method: .post, type: Task.self, task:newTask) { _ in
            // 登録/更新 完了後に画面を閉じる
            self.dissmiss()
        }
    }
    
    // 画面を閉じる
    @objc private func dissmiss() {
        self.dismiss(animated: true){
            // 閉じた後
            // TODO　デリゲートを呼びタスク一覧を取得
        }
    }
}

extension PostViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
