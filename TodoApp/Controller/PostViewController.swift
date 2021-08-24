//
//  PostViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//
import Firebase
import UIKit
import SVProgressHUD

class PostViewController: UIViewController ,UIGestureRecognizerDelegate {
    @IBOutlet weak var inputTitleTextField: UITextField!
    @IBOutlet weak var inputContentView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var inputStackView: UIStackView!
    var selectDate = Date().dateFormat()
    var maxOrderNo = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.postButton.addTarget(self, action: #selector(postTask), for: .touchUpInside)
        self.dateButton.addTarget(self, action: #selector(dateSelect), for: .touchUpInside)
        self.inputTitleTextField.delegate = self
        self.inputTitleTextField.borderStyle = .none
        self.inputContentView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        self.inputContentView.sizeToFit()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setDateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //テキストエリアにカーソルを設定しキーボードを起動
        self.inputTitleTextField.becomeFirstResponder()
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
        // 入力チェック
        if validate() {
            return
        }
        // ローディング表示
        SVProgressHUD.show()
        // ログインuserIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newTask = Task(taskId: "", title: self.inputTitleTextField.text! , content: self.inputContentView.text, uid: uid, date: self.selectDate, order: self.maxOrderNo + 1)
        API.shared.createTask(type: Task.self, task:newTask) { _ in
            SVProgressHUD.dismiss()
            // 登録/更新 完了後に画面を閉じる
            self.dissmiss()
        }
    }
    
    // 日付を選択
    @objc private func dateSelect() {
        // 画面遷移
        guard let dateSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "DateSelectViewController") as? DateSelectViewController else { return }
        self.present(dateSelectVC,animated: true, completion: nil)
    }
    
    // 画面を閉じる
    @objc private func dissmiss() {
        //前画面でタスクの一覧を取得
        guard let navVC =  self.presentingViewController as? UINavigationController else { return }
        guard let tabVC = navVC.topViewController as? TabBarController else { return }
        guard let listVC = tabVC.selectedViewController as? ListViewController  else { return }
        listVC.taskRequest()
        self.dismiss(animated: true, completion: nil)
    }
    
    // 入力チェック
    private func validate() -> Bool {
        let check = Check()
        if check.isEmpty(inputArray: self.inputTitleTextField.text!, self.inputContentView.text) {
            SVProgressHUD.showError(withStatus: Const.Message6)
            SVProgressHUD.dismiss(withDelay: 1)
            return true
        }
        // エラーがなければfalse
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false}
        // inputStackViewもしくはそのsubViewはgestureRecognizerを反応させない
        if (view.isDescendant(of: self.inputStackView)) {
            return false
        }
        return true
    }
     
    // 日付をボタンに設定
    func setDateButton() {
        self.dateButton.setTitle(selectDate.dateJpFormat(), for: .normal)
    }
}

extension PostViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
