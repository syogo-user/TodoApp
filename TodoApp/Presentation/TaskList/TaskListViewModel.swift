//
//  TaskListViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

protocol TaskListViewModel {
    var taskInfo: Signal<VMResult<[TaskInfo]>?> { get }
    var taskItems: Driver<[TaskInfoItem]> { get }
    var deleteTaskInfo: Signal<VMResult<Void>?> { get }
    var insertLocalTaskInfo: Signal<VMResult<Void>?> { get }
    var deleteLocalTaskInfo: Signal<VMResult<Void>?> { get }
    /// タスクリストを取得
    func fetchTaskList()
    /// タスクを削除
    func deleteTask(index: Int)
    /// ローカルDBからタスクリストを取得
    func loadLocalTaskList() -> Single<[TaskInfoRecord]>
    /// タスクIDに変換
    func toTaskId(index: Int) -> String
}

class TaskListViewModelImpl: TaskListViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private var disposeBag = DisposeBag()
    private var tableViewItems: [TaskInfoItem] = []
    /// タスクの取得通知
    private let taskInfoRelay = PublishRelay<VMResult<[TaskInfo]>?>()
    lazy var taskInfo = taskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// タスクの取得(セル用の値)通知
    private let taskItemsRelay = BehaviorRelay<[TaskInfoItem]>(value: [])
    lazy var taskItems = taskItemsRelay.asDriver()

    /// タスクの削除通知
    private let deleteTaskInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var deleteTaskInfo = deleteTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの登録通知
    private let insertLocalTaskInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var insertLocalTaskInfo = insertLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの削除通知
    private let deleteLocalTaskInfoRelay = PublishRelay<VMResult<Void>?>()
    lazy var deleteLocalTaskInfo = deleteLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    // TODO: ログイン時のみAPIから取得する。それ以外はローカルDBから取得する
    func fetchTaskList() {
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user, idToken) in
                self.taskUseCase.fetchTask(userId: user.userId, authorization: idToken)
            }
            .do(onSuccess: { result in
                result.forEach { task in
                    let taskId = task.taskId
                    let title = task.title
                    let content = task.content
                    let scheduledDate = task.scheduledDate
                    let isCompleted = task.isCompleted
                    let isFavorite = task.isFavorite
                    let userId = task.userId
                    let taskInfoRecord = TaskInfoRecord(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId)
                    // ローカルDBに追加
                    self.insertLocalTask(taskInfo: taskInfoRecord)

                    let taskInfoItem = TaskInfoItem(taskId: taskId, title: title, content: content, scheduledDate: scheduledDate, isCompleted: isCompleted, isFavorite: isFavorite, userId: userId)
                    self.tableViewItems.insert(taskInfoItem, at: self.tableViewItems.count)

                }
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .map { result -> VMResult<[TaskInfo]> in
                return .success(result)
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: taskInfoRelay)
            .disposed(by: disposeBag)

    }

    func deleteTask(index: Int) {
        self.userUseCase.fetchCurrentAuthToken()
            .flatMap { idToken in
                let taskId = self.toTaskId(index: index)
                return self.taskUseCase.deleteTask(taskId: taskId, authorization: idToken)
            }
            .do(onSuccess: { taskId in
                // ローカルタスク削除
                self.deleteLocalTask(taskId: taskId)

                // tableViewItemsからデータを削除
                self.tableViewItems.removeAll { task in
                    task.taskId == taskId
                }
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .map { taskId -> VMResult<Void> in
                    .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: deleteTaskInfoRelay)
            .disposed(by: disposeBag)
    }

    // ローカルからタスク取得
    func loadLocalTaskList() -> Single<[TaskInfoRecord]> {
        taskUseCase.loadLocalTaskList()
    }

    /// indexからタスクIDを取得
    func toTaskId(index: Int) -> String {
        tableViewItems[index].taskId
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

    /// ローカルDBのタスクを削除
    private func deleteLocalTask(taskId: String) {
        taskUseCase.deleteLocalTask(taskId: taskId)
            .map { result -> VMResult<Void> in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: deleteLocalTaskInfoRelay)
            .disposed(by: disposeBag)
    }
}

