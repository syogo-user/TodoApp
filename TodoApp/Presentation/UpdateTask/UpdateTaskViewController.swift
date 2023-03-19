//
//  UpdateTaskViewController.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import UIKit
import RxSwift

class UpdateTaskViewController: BaseViewController {
    private var viewModel: UpdateTaskViewModel = UpdateTaskViewModelImpl()
    private let disposeBag = DisposeBag()
    var updateTask: TaskInfoItem?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModelEvent()

    }

    private func bindViewModelEvent() {
        viewModel.updateTaskInfo
            .emit(onNext: { [unowned self] result in

            })
            .disposed(by: disposeBag)
    }

}
