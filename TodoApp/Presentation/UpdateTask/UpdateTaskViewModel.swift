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
    /// ローディング
    var isLoading: Driver<Bool> { get }
    /// タスクの更新通知
    var updateTaskInfo: Signal<VMResult<Void>?> { get }
    /// タスクの更新
    func updateTask(taskInfoItem: TaskInfoItem)
}

class UpdateTaskViewModelImpl: UpdateTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()

    /// タスクの更新通知
    private let updateTaskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var updateTaskInfo = updateTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {

        updateTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        .map { [unowned self] _ in
            self.updateTaskInfoRelay.value?.isLoading ?? false
        }
        .asDriver(onErrorJustReturn: false)
    }()

    /// タスクの更新
    func updateTask(taskInfoItem: TaskInfoItem) {
//        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
//            .flatMap { (user, idToken) in
//                self.taskUseCase.updateTask(taskId: taskInfoItem.taskId,title: taskInfoItem.title, content: taskInfoItem.content, scheduledDate: taskInfoItem.scheduledDate.dateFormat(), isCompleted: taskInfoItem.isCompleted, isFavorite: taskInfoItem.isFavorite, userId: user.userId, authorization: idToken)
//            }
//            .do(onSuccess: { task in
//                // isCompletedがtrueなら削除する。falseの場合は更新する
//                if task.isCompleted {
//                    self.taskUseCase.removeNotification(taskId: task.taskId)
//                } else {
//                    self.taskUseCase.registerNotification(notificationId: task.taskId, title: task.title, body: task.content, scheduledDate: task.scheduledDate)
//                }
//            })
//            .flatMap { task in
//                let taskInfoRecord = TaskInfoRecord(taskId: task.taskId, title: task.title, content: task.content, scheduledDate: task.scheduledDate, isCompleted: task.isCompleted, isFavorite: task.isFavorite, userId: task.userId)
//                return self.taskUseCase.updateLocalTask(taskInfo: taskInfoRecord)
//            }
//            .map { _ in
//                return .success(())
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: updateTaskInfoRelay)
//            .disposed(by: disposeBag)
    }
}
