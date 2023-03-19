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
    var deleteTaskInfo: Signal<VMResult<Void>> { get }
    var loadLocalTaskInfo: Signal<VMResult<Void>> { get }
    var insertLocalTaskInfo: Signal<VMResult<Void>> { get }
    var deleteLocalTaskInfo: Signal<VMResult<Void>> { get }
    /// タスクリストを取得
    func fetchTaskList()
    /// タスクを削除
    func deleteTask(index: Int)
    /// ローカルDBからタスクリストを取得
    func loadLocalTaskList()
    /// タスクIDに変換
    func toTaskId(index: Int) -> String
    /// サインイン画面を経由したか
    func isFromSignIn() -> Bool
    /// サインイン画面を経由したかを設定
    func setFromSignIn()
}

class TaskListViewModelImpl: TaskListViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private var userUseCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()
    private var tableViewItems: [TaskInfoItem] = []
    /// タスクの取得通知
    private let taskInfoRelay = PublishRelay<VMResult<[TaskInfo]>?>()
    lazy var taskInfo = taskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// タスクの取得(セル用の値)通知
    private let taskItemsRelay = BehaviorRelay<[TaskInfoItem]>(value: [])
    lazy var taskItems = taskItemsRelay.asDriver()

    /// タスクの削除通知
    private let deleteTaskInfoRelay = PublishRelay<VMResult<Void>>()
    lazy var deleteTaskInfo = deleteTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルのタスクリストの取得通知
    private let loadLocalTaskInfoRelay = PublishRelay<VMResult<Void>>()
    lazy var loadLocalTaskInfo = loadLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの登録通知
    private let insertLocalTaskInfoRelay = PublishRelay<VMResult<Void>>()
    lazy var insertLocalTaskInfo = insertLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// ローカルタスクの削除通知
    private let deleteLocalTaskInfoRelay = PublishRelay<VMResult<Void>>()
    lazy var deleteLocalTaskInfo = deleteLocalTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    // TODO: ログイン時のみAPIから取得する。それ以外はローカルDBから取得する
    func fetchTaskList() {
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user, idToken) in
                self.taskUseCase.fetchTask(userId: user.userId, authorization: idToken)
            }
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                    let taskInfoRecord = TaskInfoRecord(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                    self.insertLocalTask(taskInfo: taskInfoRecord)
                    return TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
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
    func loadLocalTaskList() {
        taskUseCase.loadLocalTaskList()
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                    TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .map { taskList -> VMResult<Void> in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: loadLocalTaskInfoRelay)
            .disposed(by: disposeBag)
    }

    /// indexからタスクIDを取得
    func toTaskId(index: Int) -> String {
        tableViewItems[index].taskId
    }

    func isFromSignIn() -> Bool {
        userUseCase.isFromSignIn
    }

    func setFromSignIn() {
        userUseCase.isFromSignIn = false
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

