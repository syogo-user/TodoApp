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
    var isLoading: Driver<Bool> { get }
    var taskItems: Driver<[TaskInfoItem]> { get }
    var taskInfo: Signal<VMResult<Void>?> { get }
    var deleteTaskInfo: Signal<VMResult<Void>?> { get }

    /// タスクリストを取得
    func fetchTaskList()
    /// タスクを削除
    func deleteTask(index: Int)
    /// ローカルDBからタスクリストを取得
    func loadLocalTaskList()
    /// サインイン画面を経由したか
    func isFromSignIn() -> Bool
    /// サインイン画面を経由したかを設定
    func setFromSignIn()
    /// 指定したインデックスのタスクを返却する
    func selectItemAt(index: Int) -> TaskInfoItem
}

class TaskListViewModelImpl: TaskListViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private var userUseCase: UserUseCase = UserUseCaseImpl()
    private let disposeBag = DisposeBag()
    private var tableViewItems: [TaskInfoItem] = []

    /// タスクの取得(セル用の値)通知
    private let taskItemsRelay = BehaviorRelay<[TaskInfoItem]>(value: [])
    lazy var taskItems = taskItemsRelay.asDriver()

    /// タスクの取得通知
    private let taskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var taskInfo = taskInfoRelay.asSignal(onErrorSignalWith: .empty())

    /// タスクの削除通知
    private let deleteTaskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var deleteTaskInfo = deleteTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

    private(set) lazy var isLoading: Driver<Bool> = {
        Observable.merge(
            taskInfo.map { VMResult(data: $0?.data != nil) }.asObservable(),
            deleteTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
        )
        .map { [unowned self] _ in
            (self.taskInfoRelay.value?.isLoading ?? false) ||
            (self.deleteTaskInfoRelay.value?.isLoading ?? false)
        }
        .asDriver(onErrorJustReturn: false)
    }()

    func fetchTaskList() {
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user, idToken) in
                self.taskUseCase.fetchTask(userId: user.userId, authorization: idToken)
            }
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                     TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                self.sortTask()
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .flatMap { _ in
                let taskInfoList = self.tableViewItems.map {
                    TaskInfoRecord(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                return self.taskUseCase.insertLocalTaskList(taskInfoList: taskInfoList)
            }
            .map { _ in
                return .success(())
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
                // tableViewItemsからデータを削除
                self.tableViewItems.removeAll { task in
                    task.taskId == taskId
                }
                self.sortTask()
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .flatMap { taskId in
                self.taskUseCase.deleteLocalTask(taskId: taskId)
            }
            .map { _ in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: deleteTaskInfoRelay)
            .disposed(by: disposeBag)
    }

    /// ローカルからタスク取得
    func loadLocalTaskList() {
        taskUseCase.loadLocalTaskList()
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                    TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                self.sortTask()
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .map { taskList -> VMResult<Void> in
                .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: taskInfoRelay)
            .disposed(by: disposeBag)
    }

    func isFromSignIn() -> Bool {
        userUseCase.isFromSignIn
    }

    func setFromSignIn() {
        userUseCase.isFromSignIn = false
    }

    func selectItemAt(index: Int) -> TaskInfoItem {
        tableViewItems[index]
    }

    /// インデックスからタスクIDを取得
    private func toTaskId(index: Int) -> String {
        selectItemAt(index: index).taskId
    }

    private func sortTask() {
        self.tableViewItems.sort{ (task1: TaskInfoItem, task2: TaskInfoItem) -> Bool in
            if task1.scheduledDate == task2.scheduledDate {
                // 日付が同じ場合
                return Int(task1.taskId) ?? 0  < Int(task2.taskId) ?? 0
            } else {
                // 日付が異なる場合
                return task1.scheduledDate < task2.scheduledDate
            }
        }
    }

//    /// ローカルDBのタスクを削除
//    private func deleteLocalTask(taskId: String) {
//        taskUseCase.deleteLocalTask(taskId: taskId)
//            .map { result -> VMResult<Void> in
//                .success(())
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: deleteLocalTaskInfoRelay)
//            .disposed(by: disposeBag)
//    }
}

