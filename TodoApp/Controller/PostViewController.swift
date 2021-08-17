//
//  PostViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//
import Firebase
import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var maxOrderNo = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postTask), for: .touchUpInside)
    }
    
    // タスクを登録する
    @objc private func postTask() {
        if (titleTextField.text == nil || contentTextView.text.isEmpty) {
            // TODO エラーのメッセージを出力
            return
        }
        // ログインuserIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let selectDate = Date().dateFormat()
        let newTask = Task(taskId: "", title: titleTextField.text! , content: contentTextView.text, uid: uid, date: selectDate, order: maxOrderNo + 1)
        API.shared.createTask(method: .post, type: Task.self, task:newTask) { _ in
            // 登録/更新 完了後に画面を閉じる
            self.dissmiss()
        }
    }
    
    // 画面を閉じる
    @objc private func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
