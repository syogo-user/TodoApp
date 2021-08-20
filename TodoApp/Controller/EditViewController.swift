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
    @IBOutlet weak var dateButton: UIButton!
    var task: Task?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLayout()
        dateButton.addTarget(self, action: #selector(dateSelect), for: .touchUpInside)
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(putTask))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]
    }
    
    // 画面レイアウト
   func displayLayout() {
        guard let task = self.task else { return }
        self.titleTextField.text = task.title
        self.contentTextView.text = task.content
        dateButton.setTitle(task.date, for: UIControl.State.normal)
    }    
    
    // 再投稿
    @objc private func putTask() {
        guard let task = self.task else { return }
        let putTask = Task(taskId: task.taskId, title: self.titleTextField.text! , content: self.contentTextView.text, uid: task.uid, date: task.date, order: task.order)
        API.shared.putTask(method: .put, type: Task.self, task: putTask) { _ in
            // 画面を戻る
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 日付選択
    @objc private func dateSelect() {
        // 画面遷移
        guard let dateSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "DateSelectViewController") as? DateSelectViewController else { return }
        guard let task = self.task else { return }
        dateSelectVC.task = Task(taskId: task.taskId, title: self.titleTextField.text!, content: self.contentTextView.text, uid: task.uid, date: task.date, order: task.order)
        self.present(dateSelectVC,animated: true, completion: nil)
    }
}
