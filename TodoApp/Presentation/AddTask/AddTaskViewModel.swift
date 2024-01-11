//
//  AddTaskViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol AddTaskViewModel {
    /// ローディング
    var isLoading: Driver<Bool> { get }
    /// タスクの追加通知
    var addTaskInfo: Signal<VMResult<Void>?> { get }
    /// タスクを登録
    func addTask(title: String, content: String, scheduledDate: String)
}

class AddTaskViewModelImpl: AddTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    /// タスクの追加通知
    private let addTaskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var addTaskInfo = addTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {

        addTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        .map { [unowned self] _ in
            self.addTaskInfoRelay.value?.isLoading ?? false
        }
        .asDriver(onErrorJustReturn: false)
    }()

    /// タスクの追加
    func addTask(title: String, content: String, scheduledDate: String) {
//        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
//                .flatMap { (user, idToken) in
//                    self.taskUseCase.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: false, isFavorite: false, userId: user.userId, authorization: idToken)
//                }
//                .do(onSuccess: { task in
//                    self.taskUseCase.registerNotification(notificationId: task.taskId, title: task.title, body: task.content, scheduledDate: task.scheduledDate)
//                })
//                .flatMap { result in
//                    // ローカルDBに追加
//                    let taskInfoRecord = TaskInfoRecord(taskId: result.taskId, title: result.title, content: result.content, scheduledDate: result.scheduledDate, isCompleted: result.isCompleted, isFavorite: result.isFavorite, userId: result.userId)
//                    return self.taskUseCase.insertLocalTask(taskInfo: taskInfoRecord)
//                }
//                .map { _ in
//                    return .success(())
//                }
//                .asSignal(onErrorRecover: { .just(.failure($0))})
//                .startWith(.loading())
//                .emit(to: addTaskInfoRelay)
//                .disposed(by: disposeBag)
    }
}
