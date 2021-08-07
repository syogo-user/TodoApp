//
//  PostViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var maxId = 0//現在のタスクIDの最大値
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postTask), for: .touchUpInside)
    }
    //タスクを登録する
    @objc private func postTask(){
        if (titleTextField.text == nil || contentTextView.text.isEmpty){
            //TODO エラーのメッセージを出力
            return
        }
        let task = Task(taskId: maxId + 1, title:titleTextField.text! , content: contentTextView.text)
        API.shared.patchRequest(task:task, type: Task.self) {
            //登録後画面を閉じる
            self.dissmiss()
        }
    }
    
    //画面を閉じる
    @objc private func dissmiss(){
        self.dismiss(animated: true, completion: nil)
    }
}
