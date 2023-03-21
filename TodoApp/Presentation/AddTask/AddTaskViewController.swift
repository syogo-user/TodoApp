//
//  AddTaskViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit
import RxSwift

protocol AddTaskViewControllerDelegate: AnyObject {
    /// 送信したことを通知する
    func didTapSend()
}

class AddTaskViewController: BaseViewController {

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet weak var inputAreaStackView: UIStackView!

    private var viewModel: AddTaskViewModel = AddTaskViewModelImpl()
    private let disposeBag = DisposeBag()
    weak var delegate: AddTaskViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.bindViewModelEvent()
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

    /// キーボードが隠れるとき
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    /// 画面を閉じる
    @objc private func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }

    private func setUp() {
        self.titleTextField.delegate = self
        self.titleTextField.borderStyle = .none
        self.contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        self.contentTextView.sizeToFit()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func bindViewModelEvent() {
        viewModel.addTaskInfo
            .emit(onNext: { [unowned self] result in

                
                delegate?.didTapSend()
                self.dissmiss()
            })
            .disposed(by: disposeBag)
    }

    @IBAction private func selectDate(_ sender: Any) {

    }

    @IBAction private func send(_ sender: Any) {
        guard let title = self.titleTextField.text, let content = self.contentTextView.text else { return }
        let date = Date()
        viewModel.addTask(title: title, content: content, scheduledDate: date.description)
    }
}


extension AddTaskViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


extension AddTaskViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false}
        // inputAreaStackViewもしくはそのsubViewはgestureRecognizerを反応させない
        if (view.isDescendant(of: self.inputAreaStackView)) {
            return false
        }
        return true
    }
}
