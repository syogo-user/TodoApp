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
    var isLoading: Driver<Bool> { get }
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
    private let addTaskInfoRelay = BehaviorRelay<VMResult<TaskInfo>?>(value: nil)
    lazy var addTaskInfo: Signal<VMResult<TaskInfo>?> = addTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの登録通知
    private let insertLocalTaskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var insertLocalTaskInfo = insertLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {
        Observable.merge(
            addTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable(),
            insertLocalTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        )
        .map { [unowned self] _ in
            (self.addTaskInfoRelay.value?.isLoading ?? false) ||
            (self.insertLocalTaskInfoRelay.value?.isLoading ?? false)
        }
        .asDriver(onErrorJustReturn: false)
    }()


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
