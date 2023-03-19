//
//  AddTaskViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit
import RxSwift

class AddTaskViewController: BaseViewController {
    private var viewModel: AddTaskViewModel = AddTaskViewModelImpl()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModelEvent()
    }

    private func bindViewModelEvent() {
        viewModel.addTaskInfo
            .emit(onNext: { [unowned self] result in
                // この画面を閉じる
            })
            .disposed(by: disposeBag)
    }
}
