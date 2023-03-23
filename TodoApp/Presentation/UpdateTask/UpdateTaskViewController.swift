//
//  UpdateTaskViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit
import RxSwift

protocol UpdateTaskViewControllerDelegate: AnyObject {
    /// 更新したことを通知する
    func didUpdateTask()
}

class UpdateTaskViewController: BaseViewController {

    @IBOutlet weak var completeCheckButton: CheckButton!
    @IBOutlet weak var scheduledDatePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    private let viewModel: UpdateTaskViewModel = UpdateTaskViewModelImpl()
    private let validate: Validate = Validate()
    private let disposeBag = DisposeBag()
    private var selectedDate: String?
    weak var delegate: UpdateTaskViewControllerDelegate?
    var updateTask: TaskInfoItem?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModelEvent()
        self.setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }

    private func bindViewModelEvent() {
        viewModel.isLoading
            .drive(onNext: { [unowned self] isLoading in
                self.setIndicator(show: isLoading)
            })
            .disposed(by: disposeBag)

        viewModel.updateTaskInfo
            .emit(onNext: { [unowned self] result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error) {
                        
                    }
                    return
                }
                // 更新完了通知
                delegate?.didUpdateTask()
                // 成功時、画面を閉じる
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setUp() {
        guard let task = self.updateTask else { return }
        titleTextField.text = task.title
        contentTextView.text = task.content
        selectedDate = task.scheduledDate
        if let date = selectedDate {
            self.scheduledDatePicker.date = date.toDate() ?? Date()
        }
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(putTask))
        self.navigationItem.leftBarButtonItems = [editBarButtonItem]
    }

    @objc private func putTask() {
        guard let task = self.updateTask, let title = titleTextField.text, let content = contentTextView.text, let selectedDate = self.selectedDate else { return }

        if (validate.isEmpty(inputArray: title)) {
            emptyTitleDialog()
            return
        }
        if (validate.isWordLengthOver(word: title, wordLimit: Constants.titleWordLimit)) {
            overTitleLengthDialog()
            return
        }

        let isCompleted = completeCheckButton.isChecked
        let taskInfoItem = TaskInfoItem(taskId: task.taskId, title: title, content: content, scheduledDate: selectedDate, isCompleted: isCompleted, isFavorite: task.isFavorite, userId: task.taskId)
        viewModel.updateTask(taskInfoItem: taskInfoItem)
    }

    private func emptyTitleDialog(completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: R.string.localizable.emptyTitleDialogTitle(), message: R.string.localizable.emptyTitleDialogMessage(), preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { action in
            completion?()
        }))
        self.present(dialog,animated: true,completion: nil)
    }

    private func overTitleLengthDialog(completion: (() -> Void)? = nil) {
        let dialog = UIAlertController(title: R.string.localizable.overTitleLengthDialogTitle(), message: R.string.localizable.overTitleLengthDialogMessage(String(Constants.titleWordLimit)), preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { action in
            completion?()
        }))
        self.present(dialog,animated: true,completion: nil)
    }

    @IBAction private func complete(_ sender: Any) {

    }

    @IBAction func selectDate(_ sender: Any) {
        selectedDate = scheduledDatePicker.date.dateFormat()
    }
}
