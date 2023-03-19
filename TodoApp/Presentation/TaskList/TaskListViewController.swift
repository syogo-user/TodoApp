//
//  TaskListViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import UIKit
import RxSwift

class TaskListViewController: BaseViewController {
    private var viewModel: TaskListViewModel = TaskListViewModelImpl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchTaskList()
        viewModel.loadLocalTaskList()
            .subscribe { taskList in

            }
        bindViewModelValue()
    }

    private func bindViewModelValue() {
        viewModel.taskInfo
            .emit(onNext: { result in
                guard let result = result, result.isCompleted else { return }
                if let error = result.error {
                    self.handlerError(error: error) {

                    }
                }
            })
            .disposed(by: disposeBag)

    }
}
