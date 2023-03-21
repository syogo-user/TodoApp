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
    func updateComplete()
}

class UpdateTaskViewController: BaseViewController {

    @IBOutlet weak var completeCheckButton: CheckButton!
    @IBOutlet weak var scheduledDateButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    private let viewModel: UpdateTaskViewModel = UpdateTaskViewModelImpl()
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
        viewModel.updateTaskInfo
            .emit(onNext: { [unowned self] result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error) {
                        // TODO: エラーの場合ダイアログを表示し、OKなら画面を閉じる。修正するなら閉じない。
                    }
                }
                // 更新完了通知
                delegate?.updateComplete()
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
        scheduledDateButton.setTitle(selectedDate, for: .normal)

        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(putTask))
        self.navigationItem.leftBarButtonItems = [editBarButtonItem]
    }

    @objc private func putTask() {
        // TODO: 入力チェック(タイトルが空でないこと、日付が選択されていること)

        guard let task = self.updateTask, let title = titleTextField.text, let content = contentTextView.text, let selectedDate = self.selectedDate else { return }
        let isCompleted = completeCheckButton.isChecked
        let taskInfoItem = TaskInfoItem(taskId: task.taskId, title: title, content: content, scheduledDate: selectedDate, isCompleted: isCompleted, isFavorite: task.isFavorite, userId: task.taskId)
        viewModel.updateTask(taskInfoItem: taskInfoItem)
    }

    @IBAction private func complete(_ sender: Any) {

    }

    @IBAction private func selectDate(_ sender: Any) {
        // TODO: 日付

    }
    
}
