//
//  TaskListViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa

enum Sort: String {
    case ascendingOrderDate = "ascendingOrderDate"
    case descendingOrderDate = "descendingOrderDate"
}

protocol TaskListViewModel {
    var isLoading: Driver<Bool> { get }
    var taskItems: Driver<[TaskInfoItem]> { get }
    var taskInfo: Signal<VMResult<Void>?> { get }
    var updateTaskInfo: Signal<VMResult<Void>?> { get }
    var deleteTaskInfo: Signal<VMResult<Void>?> { get }

    /// タスクリストを取得
    func fetchTaskList()
    /// タスクを削除
    func deleteTask(index: Int)
    /// タスクを更新
    func updateTask(index: Int)
    /// ローカルDBからタスクリストを取得
    func loadLocalTaskList()
    /// サインイン画面を経由したか
    func isFromSignIn() -> Bool
    /// サインイン画面を経由したかを設定
    func setFromSignIn()
    /// 指定したインデックスのタスクを返却する
    func selectItemAt(index: Int) -> TaskInfoItem
    /// 完了状態を変更
    func changeComplete(index: Int, isCompleted: Bool)
    /// お気に入り状態を変更
    func changeFavorite(index: Int, isFavorite: Bool)
    /// 並び順を設定
    func setSortOrder(sortOrder: String)
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

    /// タスクの更新通知
    private let updateTaskInfoRelay = BehaviorRelay<VMResult<Void>?>(value: nil)
    lazy var updateTaskInfo = updateTaskInfoRelay.asSignal(onErrorSignalWith: .empty())

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
        let sortOrder = getSortOrder()
        // ユーザIDとトークンを取得
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user: UserInfoAttribute, idToken: String) in
                // タスクをAPIから取得
                self.taskUseCase.fetchTask(userId: user.userId, authorization: idToken)
            }
            .flatMap { (list: [TaskInfo])  in
                return Single<Any>.zip({
                    // ローカルに登録
                    var taskList = list
                    self.sortTask(itemList: &taskList, sort: sortOrder)

                    let taskInfoList = taskList.map {
                        TaskInfoRecord(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                    }
                    return self.taskUseCase.insertLocalTaskList(taskInfoList: taskInfoList)
                }(), {
                    // APIとローカルそれぞれタスクのtaskIdを比較して不要なものを削除
                    let tablviewItems = Set(self.tableViewItems.map{ $0.taskId })
                    let taskList = Set(list.map{ $0.taskId })
                    /// ローカルから取得したタスクには存在するがにAPIから取得したタスクには存在しないものtaskIDを抽出
                    let result = tablviewItems.subtracting(taskList)
                    let deleteIdList = Array(result)
                    return self.taskUseCase.deleteLocalTaskList(taskIdList: deleteIdList)
                }())
            }
            .flatMap { _ in
                self.taskUseCase.loadLocalTaskList()
            }
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                    TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                self.sortTask(itemList: &self.tableViewItems, sort: sortOrder)
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .map { _ in
                return .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: taskInfoRelay)
            .disposed(by: disposeBag)
    }

    func deleteTask(index: Int) {
        let sortOrder = getSortOrder()
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
                self.sortTask(itemList: &self.tableViewItems, sort: sortOrder)
                self.taskItemsRelay.accept(self.tableViewItems)
            })
            .do(onSuccess: { taskId in
                self.taskUseCase.removeNotification(taskId: taskId)
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
        let sortOrder = getSortOrder()
        taskUseCase.loadLocalTaskList()
            .do(onSuccess: { taskList in
                self.tableViewItems = taskList.map {
                    TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
                }
                self.sortTask(itemList: &self.tableViewItems, sort: sortOrder)
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

    func changeComplete(index: Int, isCompleted: Bool) {
        let item = selectItemAt(index: index)
        tableViewItems[index] = TaskInfoItem(
            taskId: item.taskId,
            title: item.title,
            content: item.content,
            scheduledDate: item.scheduledDate,
            isCompleted: isCompleted,
            isFavorite: item.isFavorite,
            userId: item.userId
        )
    }

    func changeFavorite(index: Int, isFavorite: Bool) {
        let item = selectItemAt(index: index)
        tableViewItems[index] = TaskInfoItem(
            taskId: item.taskId,
            title: item.title,
            content: item.content,
            scheduledDate: item.scheduledDate,
            isCompleted: item.isCompleted,
            isFavorite: isFavorite,
            userId: item.userId
        )
    }

    func updateTask(index: Int) {
        let taskInfoItem = selectItemAt(index: index)
        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
            .flatMap { (user, idToken) in
                self.taskUseCase.updateTask(taskId: taskInfoItem.taskId,title: taskInfoItem.title, content: taskInfoItem.content, scheduledDate: taskInfoItem.scheduledDate.dateFormat(), isCompleted: taskInfoItem.isCompleted, isFavorite: taskInfoItem.isFavorite, userId: user.userId, authorization: idToken)
            }
            .flatMap { result in
                let taskInfoRecord = TaskInfoRecord(taskId: result.taskId, title: result.title, content: result.content, scheduledDate: result.scheduledDate, isCompleted: result.isCompleted, isFavorite: result.isFavorite, userId: result.userId)
                return self.taskUseCase.updateLocalTask(taskInfo: taskInfoRecord)
            }
            .map { _ in
                return .success(())
            }
            .asSignal(onErrorRecover: { .just(.failure($0))})
            .startWith(.loading())
            .emit(to: updateTaskInfoRelay)
            .disposed(by: disposeBag)
    }

    func setSortOrder(sortOrder: String) {
        userUseCase.sortOrder = sortOrder
    }

    private func getSortOrder() -> String {
        userUseCase.sortOrder ?? Sort.descendingOrderDate.rawValue
    }

    private func sortTask<T: SortProtocol>(itemList: inout [T], sort: String) {
        switch sort {
        case Sort.ascendingOrderDate.rawValue:
            itemList.sort{ (task1: T, task2: T) -> Bool in
                if task1.scheduledDate == task2.scheduledDate {
                    // 日付が同じ場合
                    return Int(task1.taskId) ?? 0  < Int(task2.taskId) ?? 0
                } else {
                    // 日付が異なる場合
                    return task1.scheduledDate < task2.scheduledDate
                }
            }
        case Sort.descendingOrderDate.rawValue:
            itemList.sort{ (task1: T, task2: T) -> Bool in
                if task1.scheduledDate == task2.scheduledDate {
                    // 日付が同じ場合
                    return Int(task1.taskId) ?? 0  < Int(task2.taskId) ?? 0
                } else {
                    // 日付が異なる場合
                    return task1.scheduledDate > task2.scheduledDate
                }
            }
        default:
            print("")
        }
    }

    /// インデックスからタスクIDを取得
    private func toTaskId(index: Int) -> String {
        selectItemAt(index: index).taskId
    }
}
