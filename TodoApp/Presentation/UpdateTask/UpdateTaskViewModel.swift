//
//  UpdateTaskViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol UpdateTaskViewModel {
    var updateTaskInfo: Signal<VMResult<TaskInfo>?> { get }
    var updateLocalTaskInfo: Signal<VMResult<Void>?> { get }

    func updateTask(taskInfoItem: TaskInfoItem)
}

class UpdateTaskViewModelImpl: UpdateTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private var disposeBag = DisposeBag()

    // タスクの更新通知
    private let updateTaskInfoRelay = PublishRelay<VMResult<TaskInfo>?>()
    lazy var updateTaskInfo = updateTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの更新通知
    private let updateLocalTaskInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var updateLocalTaskInfo = updateLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())
    
    func updateTask(taskInfoItem: TaskInfoItem) {
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user, idToken) in
                self.taskUseCase.updateTask(taskId: taskInfoItem.taskId,title: taskInfoItem.title, content: taskInfoItem.content, scheduledDate: taskInfoItem.scheduledDate, isCompleted: taskInfoItem.isCompleted, isFavorite: taskInfoItem.isFavorite, userId: user.userId, authorization: idToken)
            }
            .do(onSuccess: { result in
                // ローカルDBを更新
                let taskInfoRecord = TaskInfoRecord(taskId: result.taskId, title: result.title, content: result.content, scheduledDate: result.scheduledDate, isCompleted: result.isCompleted, isFavorite: result.isFavorite, userId: result.userId)
                self.updateLocalTask(taskInfo: taskInfoRecord)
            })
                .map { result -> VMResult<TaskInfo> in
                    return .success(result)
                }
                .asSignal(onErrorRecover: { .just(.failure($0))})
                .startWith(.loading())
                .emit(to: updateTaskInfoRelay)
                .disposed(by: disposeBag)
    }

    /// ローカルDBにタスクを更新
    private func updateLocalTask(taskInfo: TaskInfoRecord) {
        taskUseCase.insertLocalTask(taskInfo: taskInfo)
            .map { result -> VMResult<Void> in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: updateLocalTaskInfoRelay)
            .disposed(by: disposeBag)
    }
}
