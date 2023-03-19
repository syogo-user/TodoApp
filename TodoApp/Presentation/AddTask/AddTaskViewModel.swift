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
    var addTaskInfo: Signal<VMResult<TaskInfo>?> { get }
    var insertLocalTaskInfo: Signal<VMResult<Void>?> { get }
    /// タスクを登録
    func addTask(title: String, content: String, scheduledDate: String)
}

class AddTaskViewModelImpl: AddTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    // タスクの登録通知
    private let addTaskInfoRelay = PublishRelay<VMResult<TaskInfo>?>()
    lazy var addTaskInfo: Signal<VMResult<TaskInfo>?> = addTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの登録通知
    private let insertLocalTaskInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var insertLocalTaskInfo = insertLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    func addTask(title: String, content: String, scheduledDate: String) {
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
                .flatMap { (user, idToken) in
                    self.taskUseCase.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: false, isFavorite: false, userId: user.userId, authorization: idToken)
                }
                .do(onSuccess: { result in
                    // ローカルDBに追加
                    let taskInfoRecord = TaskInfoRecord(taskId: result.taskId, title: result.title, content: result.content, scheduledDate: result.scheduledDate, isCompleted: result.isCompleted, isFavorite: result.isFavorite, userId: result.userId)
                    self.insertLocalTask(taskInfo: taskInfoRecord)
                })
                .map { result -> VMResult<TaskInfo> in
                    return .success(result)
                }
                .asSignal(onErrorRecover: { .just(.failure($0))})
                .startWith(.loading())
                .emit(to: addTaskInfoRelay)
                .disposed(by: disposeBag)
    }

    /// ローカルDBにタスクを追加
    private func insertLocalTask(taskInfo: TaskInfoRecord) {
        taskUseCase.insertLocalTask(taskInfo: taskInfo)
            .map { result -> VMResult<Void> in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: insertLocalTaskInfoRelay)
            .disposed(by: disposeBag)
    }
}
