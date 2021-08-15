//
//  EditViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/15.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    var task:Task?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLayout()
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(putTask))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]
    }
    
    // 画面レイアウト
    private func displayLayout() {
        guard let task = self.task else { return }
        self.titleTextField.text = task.title
        self.contentTextView.text = task.content
    }
    
    // 再投稿
    @objc private func putTask(){
        guard let task = self.task else { return }
        let putTask = Task(taskId: task.taskId, title: self.titleTextField.text! , content: self.contentTextView.text, uid: task.uid)
        API.shared.putTask(method: .put, type: Task.self, task: putTask) { _ in
            // 画面を戻る
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
