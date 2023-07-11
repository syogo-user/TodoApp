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
    weak var delegate: UpdateTaskViewControllerDelegate?
    private let viewModel: UpdateTaskViewModel = UpdateTaskViewModelImpl()
    private let validate: Validate = Validate()
    private let disposeBag = DisposeBag()
    private var updateTask: TaskInfoItem?
    private var selectedDate: Date?

    @IBOutlet private weak var completeCheckButton: CheckButton!
    @IBOutlet private weak var favoriteButton: FavoriteButton!
    @IBOutlet private weak var scheduledButton: UIButton!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModelEvent()
        self.setUp()
    }
    
    func getSelectDate() -> Date? {
        self.selectedDate
    }

    func setUpdateTask(task: TaskInfoItem) {
        self.updateTask = task
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
                    self.handlerError(
                        error: error,
                        onAuthError: { self.tokenErrorDialog() },
                        onLocalDbError: { self.localDbErrorDialog() },
                        onAPIError: { self.updateTaskErrorDialog() },
                        onParseError: { self.parseErrorDialog() },
                        onUnKnowError: { self.unKnowErrorDialog() }
                    )
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
        completeCheckButton.isChecked = task.isCompleted
        favoriteButton.isFavorite = task.isFavorite
        titleTextField.text = task.title
        contentTextView.text = task.content
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        contentTextView.layer.borderWidth = 0.5
        selectedDate = task.scheduledDate
        scheduledButton.setTitle(task.scheduledDate.dateFormat().dateJpFormat(), for: .normal)

        let editBarButtonItem = UIBarButtonItem(title: R.string.localizable.updateNavigationButtonName(), style: .plain, target: self, action: #selector(putTask))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]

        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)

        navigationItem.title = R.string.localizable.updateNavigationTitle()
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
        let isFavorite = favoriteButton.isFavorite
        let taskInfoItem = TaskInfoItem(taskId: task.taskId, title: title, content: content, scheduledDate: selectedDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: task.taskId)
        self.isConnect() {
            viewModel.updateTask(taskInfoItem: taskInfoItem)
        }
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    private func updateTaskErrorDialog() {
        self.showDialog(
            title: R.string.localizable.updateTaskErrorTitle(),
            message: R.string.localizable.updateTaskErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }
    
    override func localDbErrorDialog() {
        self.showDialog(
            title: R.string.localizable.localDbErrorTitle(),
            message: R.string.localizable.localTaskDBErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func dateParseErrorDialog() {
        self.showDialog(
            title: R.string.localizable.dateParseErrorTitle(),
            message: R.string.localizable.dateParseErrorMessage(),
            buttonTitle: R.string.localizable.ok()
        )
    }

    private func emptyTitleDialog() {
        self.showDialog(
            title: R.string.localizable.emptyTitleTitle(),
            message: R.string.localizable.emptyTitleMessage(),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    private func overTitleLengthDialog() {
        self.showDialog(
            title: R.string.localizable.overTitleLengthTitle(),
            message: R.string.localizable.overTitleLengthMessage(String(Constants.titleWordLimit)),
            buttonTitle:  R.string.localizable.ok()
        )
    }

    @IBAction private func selectDate(_ sender: Any) {
        self.toSelectDate()
    }
}

extension UpdateTaskViewController: SelectDateViewControllerDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        scheduledButton.setTitle(date.dateFormat().dateJpFormat(), for: .normal)
    }
}
