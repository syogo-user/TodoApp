//
//  EditViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/15.
//

import UIKit
import SVProgressHUD

class EditViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateButton: UIButton!
    var task: Task?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateButton.addTarget(self, action: #selector(dateSelect), for: .touchUpInside)
        self.contentTextView.layer.borderColor = UIColor.darkGray.cgColor
        self.contentTextView.layer.borderWidth = 0.2
        self.contentTextView.layer.cornerRadius = 5
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(putTask))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]
        displayLayout()
    }
    
    // 画面レイアウト
    func displayLayout() {
        guard let task = self.task else { return }
        self.titleTextField.text = task.title
        self.contentTextView.text = task.content
        self.dateButton.setTitle(task.date.dateJpFormat(), for: .normal)
    }    
    
    // 再投稿
    @objc private func putTask() {
        // 入力チェック
        if validate() {
            return
        }
        guard let task = self.task else { return }
        let putTask = Task(taskId: task.taskId, title: self.titleTextField.text! , content: self.contentTextView.text, uid: task.uid, date: task.date, order: task.order)
        SVProgressHUD.show()
        API.shared.putTask(type: Task.self, task: putTask) { _ in
            SVProgressHUD.dismiss()
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
    
    // 入力チェック
    private func validate() -> Bool {
        if self.titleTextField.text!.isEmpty || self.contentTextView.text.isEmpty {
            SVProgressHUD.showError(withStatus: Const.Message6)
            return true
        } else {
            return false
        }
    }
}
