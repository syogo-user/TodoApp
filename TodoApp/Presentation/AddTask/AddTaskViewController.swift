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
    /// タスクを追加したことを通知する
    func didAddTask()
}

class AddTaskViewController: BaseViewController {
    weak var delegate: AddTaskViewControllerDelegate?
    private let viewModel: AddTaskViewModel = AddTaskViewModelImpl()
    private let validate: Validate = Validate()
    private let disposeBag = DisposeBag()
    private var selectDate: String?
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var inputAreaStackView: UIStackView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var sendButton: UIButton!

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

    /// キーボードが表示されるとき
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
        selectDate = Date().dateFormat()
        view.backgroundColor = .clear
        titleTextField.delegate = self
        titleTextField.borderStyle = .none
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        contentTextView.sizeToFit()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // タイトルにカーソルを設定
        self.titleTextField.becomeFirstResponder()
    }

    private func bindViewModelEvent() {
        viewModel.isLoading
            .drive(onNext: { [unowned self] isLoading in
                self.setIndicator(show: isLoading)
            })
            .disposed(by: disposeBag)

        viewModel.addTaskInfo
            .emit(onNext: { [unowned self] result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(
                        error: error,
                        onAuthError: { self.tokenErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onAPIError: { self.addTaskErrorDialog() },
                        onParseError: { self.parseErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
                    sendButton.isEnabled = true
                    return
                }
                delegate?.didAddTask()
                self.dissmiss()
            })
            .disposed(by: disposeBag)
    }

    private func addTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.addTaskErrorTitle(),
            message:  R.string.localizable.addTaskErrorMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    override func localDbErrorDialog() {
        self.showDialog(
            title: R.string.localizable.localDbErrorTitle(),
            message: R.string.localizable.localTaskDBErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func emptyTitleDialog(completion: (() -> Void)? = nil) {
        self.showDialog(
            title: R.string.localizable.emptyTitleTitle(),
            message: R.string.localizable.emptyTitleMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func overTitleLengthDialog() {
        self.showDialog(
            title: R.string.localizable.overTitleLengthTitle(),
            message: R.string.localizable.overTitleLengthMessage(String(Constants.titleWordLimit)),
            buttonTitle: R.string.localizable.ok()
        )        
    }

    @IBAction private func selectDate(_ sender: Any) {
        self.selectDate = datePicker.date.dateFormat()
    }

    @IBAction private func send(_ sender: Any) {

        guard let title = self.titleTextField.text, let content = self.contentTextView.text, let scheduledDate = self.selectDate else { return }
        if (validate.isEmpty(inputArray: title)) {
            emptyTitleDialog()
            return
        }
        if (validate.isWordLengthOver(word: title, wordLimit: Constants.titleWordLimit)) {
            overTitleLengthDialog()
            return
        }
        self.isConnect() {
            sendButton.isEnabled = false
            viewModel.addTask(title: title, content: content, scheduledDate: scheduledDate)
        }
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
