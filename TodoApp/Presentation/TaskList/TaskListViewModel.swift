//
//  TaskListViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/18.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftUI

enum SortOrder: String, CaseIterable, Identifiable {
    /// 昇順
    case ascendingOrderDate
    /// 降順
    case descendingOrderDate
    
    var id: String { rawValue }
    
    func getTitle() -> String {
        switch self {
        case .ascendingOrderDate:
            return R.string.localizable.rightBarButtonAscendingOrderDate()
        case .descendingOrderDate:
            return R.string.localizable.rightBarButtonDescendingOrderDate()
        }
    }
}

enum FilterCondition: String, CaseIterable, Identifiable {
    /// ★(お気に入り)のみ表示
    case onlyFavorite
    /// ✔も表示
    case includeCompleted
    /// ✔は非表示
    case notIncludeCompleted
    
    var id: String { rawValue }
    
    func getTitle() -> String {
        switch self {
        case .onlyFavorite:
            return R.string.localizable.rightBarButtonOnlyFavorite()
        case .includeCompleted:
            return R.string.localizable.rightBarButtonIncludeCompleted()
        case .notIncludeCompleted:
            return R.string.localizable.rightBarButtonNotIncludeCompleted()
        }
    }
}

protocol TaskListViewModel: ObservableObject {
    func fetchTaskList() async throws
//    /// ローディング
//    var isLoading: Driver<Bool> { get }
//    /// タスクの取得(セル用の値)通知
//    var taskItems: Driver<[TaskInfoItem]> { get }
//    /// タスクの取得通知
//    var taskInfo: Signal<VMResult<Void>?> { get }
//    /// タスクの更新通知
//    var updateTaskInfo: Signal<VMResult<Void>?> { get }
//    /// タスクの削除通知
//    var deleteTaskInfo: Signal<VMResult<Void>?> { get }
//    /// タスクリストを取得
//    func fetchTaskList()
//    /// タスクを更新
//    func updateTask(index: Int)
//    /// タスクを削除
    func deleteTask(index: Int) async throws
    /// ローカルからタスクリストを取得
    func loadLocalTaskList() throws
//    /// サインイン画面を経由したか
//    func isFromSignIn() -> Bool
//    /// サインイン画面を経由したかを設定
//    func setFromSignIn()
//    /// 指定したインデックスのタスクを返却する
//    func selectItemAt(index: Int) -> TaskInfoItem
//    /// 完了状態を変更
//    func changeComplete(index: Int, isCompleted: Bool)
//    /// お気に入り状態を変更
//    func changeFavorite(index: Int, isFavorite: Bool)
//    /// 並び順を取得
//    func getSortOrder() -> String
//    /// 並び順を設定
//    func setSortOrder(sortOrder: String)
//    /// 抽出条件を取得
//    func getFilterCondition() -> String
//    /// 抽出条件を設定
//    func setFilterCondition(filterCondition: String)
}

@MainActor
class TaskListViewModelImpl: TaskListViewModel {
    private var taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private var userUseCase: UserUseCase = UserUseCaseImpl()
    @Published private(set) var taskInfoItems: [TaskInfoItem] = []
    
    func fetchTaskList() async throws {
        let sortOrder = getSortOrder()
        let filterCondition = getFilterCondition()
        
        let authorization = try await userUseCase.fetchCurrentAuthToken()
        let user = try userUseCase.loadLocalUser()
        print("!!!user:\(user.userId)")
        let tasks = try await taskUseCase.fetchTask(userId: user.userId, authorization: authorization)
        var taskList = tasks
        self.taskUseCase.sortTask(itemList: &taskList, sort: sortOrder)
        
        let taskInfoList = taskList.map {
            TaskInfoRecord(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
        }
        try taskUseCase.insertLocalTaskList(taskInfoList: taskInfoList)

        
        // --- 以下確認した方がいい
        
        // APIとローカルそれぞれタスクのtaskIdを比較して不要なものを削除
        let taskItems = Set(self.taskInfoItems.map { $0.taskId })
        let taskIdList = Set(taskList.map { $0.taskId })
        /// ローカルから取得したタスクには存在するがにAPIから取得したタスクには存在しないものtaskIDを抽出
        let result = taskItems.subtracting(taskIdList)
        let deleteIdList = Array(result)
        try taskUseCase.deleteLocalTaskList(taskIdList: deleteIdList)
        
        let loadTasks = try taskUseCase.loadLocalTaskList()
        self.taskInfoItems = loadTasks.map {
            TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
        }
        self.taskUseCase.sortTask(itemList: &self.taskInfoItems, sort: sortOrder)
        self.taskUseCase.filterTask(itemList: &self.taskInfoItems, condition: filterCondition)
        print("tasks:\(taskInfoItems)")

        // エラーについてはVC側でdo catchしてエラーメッセージを出す。
        
    }
    
    //    /// タスクリストを取得
//        func fetchTaskListOld() {
//            let sortOrder = getSortOrder()
//            let filterCondition = getFilterCondition()
             //ユーザIDとトークンを取得
//            Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
//                .flatMap { (user: UserInfoAttribute, idToken: String) in
//                    self.taskUseCase.fetchTask(userId: user.userId, authorization: idToken)
//                }
//                .flatMap { (list: [TaskInfo])  in
//                    return Single<Any>.zip({
//                        // ローカルに登録
////                        var taskList = list
////                        taskUseCase.sortTask(itemList: taskList, sort: sortOrder)

//                        let taskInfoList = taskList.map {
//                            TaskInfoRecord(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
//                        }
//                        return self.taskUseCase.insertLocalTaskList(taskInfoList: taskInfoList)
//                    }(), {
//                        // APIとローカルそれぞれタスクのtaskIdを比較して不要なものを削除
//                        let tableViewItems = Set(self.tableViewItems.map { $0.taskId })
//                        let taskList = Set(list.map { $0.taskId })
//                        /// ローカルから取得したタスクには存在するがにAPIから取得したタスクには存在しないものtaskIDを抽出
//                        let result = tableViewItems.subtracting(taskList)
//                        let deleteIdList = Array(result)
//                        return self.taskUseCase.deleteLocalTaskList(taskIdList: deleteIdList)
//                    }())
//                }
//                .flatMap { _ in
////                    self.taskUseCase.loadLocalTaskList()
//                }
//                .do(onSuccess: { taskList in
//                    self.tableViewItems = taskList.map {
//                        TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
//                    }
//                    self.taskUseCase.sortTask(itemList: &self.tableViewItems, sort: sortOrder)
//                    self.taskUseCase.filterTask(itemList: &self.tableViewItems, condition: filterCondition)
//                    self.taskItemsRelay.accept(self.tableViewItems)
//                })
//                .map { _ in
//                    return .success(())
//                }
//                .asSignal(onErrorRecover: { .just(.failure($0))})
//                .startWith(.loading())
//                .emit(to: taskInfoRelay)
//                .disposed(by: disposeBag)
//        }
    
    
    
    
    
    
    

//
//    private(set) lazy var isLoading: Driver<Bool> = {
//        Observable.merge(
//            taskInfo.map { VMResult(data: $0?.data != nil) }.asObservable(),
//            deleteTaskInfo.map { VMResult(data: $0?.data != nil) }.asObservable()
//        )
//        .map { [unowned self] _ in
//            (self.taskInfoRelay.value?.isLoading ?? false) ||
//            (self.deleteTaskInfoRelay.value?.isLoading ?? false)
//        }
//        .asDriver(onErrorJustReturn: false)
//    }()
//
//
//    /// タスクを更新
//    func updateTask(index: Int) {
//        let taskInfoItem = selectItemAt(index: index)
//        Single.zip(self.userUseCase.loadLocalUser(), self.userUseCase.fetchCurrentAuthToken())
//            .flatMap { (user, idToken) in
//                self.taskUseCase.updateTask(taskId: taskInfoItem.taskId,title: taskInfoItem.title, content: taskInfoItem.content, scheduledDate: taskInfoItem.scheduledDate.dateFormat(), isCompleted: taskInfoItem.isCompleted, isFavorite: taskInfoItem.isFavorite, userId: user.userId, authorization: idToken)
//            }
//            .do(onSuccess: { task in
//                // isCompletedがtrueなら通知を削除する。falseの場合は更新する
//                if task.isCompleted {
//                    self.taskUseCase.removeNotification(taskId: task.taskId)
//                } else {
//                    self.taskUseCase.registerNotification(notificationId: task.taskId, title: task.title, body: task.content, scheduledDate: task.scheduledDate)
//                }
//            })
//            .flatMap { result in
//                let taskInfoRecord = TaskInfoRecord(taskId: result.taskId, title: result.title, content: result.content, scheduledDate: result.scheduledDate, isCompleted: result.isCompleted, isFavorite: result.isFavorite, userId: result.userId)
//                return self.taskUseCase.updateLocalTask(taskInfo: taskInfoRecord)
//            }
//            .map { _ in
//                return .success(())
//            }
//            .asSignal(onErrorRecover: { .just(.failure($0))})
//            .startWith(.loading())
//            .emit(to: updateTaskInfoRelay)
//            .disposed(by: disposeBag)
//    }
//
    /// タスクを削除
    func deleteTask(index: Int) async throws {
        let sortOrder = getSortOrder()
        let authorization = try await userUseCase.fetchCurrentAuthToken()
        let taskId = toTaskId(index: index)
        _ = try await taskUseCase.deleteTask(taskId: taskId, authorization: authorization)
        
        // taskInfoItemsからデータを削除
        taskInfoItems.removeAll { task in
            task.taskId == taskId
        }
        
        taskUseCase.sortTask(itemList: &self.taskInfoItems, sort: sortOrder)
        
        taskUseCase.removeNotification(taskId: taskId)
        
        try taskUseCase.deleteLocalTask(taskId: taskId)
    }
//
    /// ローカルからタスクリストを取得
    func loadLocalTaskList() throws {
        let sortOrder = getSortOrder()
        let filterCondition = getFilterCondition()
        
        let taskList = try taskUseCase.loadLocalTaskList()
        
        self.taskInfoItems = taskList.map {
            TaskInfoItem(taskId: $0.taskId, title: $0.title, content: $0.content, scheduledDate: $0.scheduledDate, isCompleted: $0.isCompleted, isFavorite: $0.isFavorite, userId: $0.userId)
        }
        
        taskUseCase.sortTask(itemList: &self.taskInfoItems, sort: sortOrder)
        taskUseCase.filterTask(itemList: &self.taskInfoItems, condition: filterCondition)
    }
//
//    /// サインイン画面を経由したか
//    func isFromSignIn() -> Bool {
//        userUseCase.isFromSignIn
//    }
//
//    /// サインイン画面を経由したかを設定
//    func setFromSignIn() {
//        userUseCase.isFromSignIn = false
//    }
//
    /// 指定したインデックスのタスクを返却する
    func selectItemAt(index: Int) -> TaskInfoItem {
        taskInfoItems[index]
    }
//
//    /// 完了状態を変更
//    func changeComplete(index: Int, isCompleted: Bool) {
//        let item = selectItemAt(index: index)
//        tableViewItems[index] = TaskInfoItem(
//            taskId: item.taskId,
//            title: item.title,
//            content: item.content,
//            scheduledDate: item.scheduledDate,
//            isCompleted: isCompleted,
//            isFavorite: item.isFavorite,
//            userId: item.userId
//        )
//    }
//    /// お気に入り状態を変更
//    func changeFavorite(index: Int, isFavorite: Bool) {
//        let item = selectItemAt(index: index)
//        tableViewItems[index] = TaskInfoItem(
//            taskId: item.taskId,
//            title: item.title,
//            content: item.content,
//            scheduledDate: item.scheduledDate,
//            isCompleted: item.isCompleted,
//            isFavorite: isFavorite,
//            userId: item.userId
//        )
//    }
//
    /// 並び順を取得
    func getSortOrder() -> String {
        taskUseCase.sortOrder ?? SortOrder.descendingOrderDate.rawValue
    }
//
    /// 並び順を設定
    func setSortOrder(sortOrder: String) {
        taskUseCase.sortOrder = sortOrder
    }
//
    /// 抽出条件を取得
    func getFilterCondition() -> String {
        taskUseCase.filterCondition ?? FilterCondition.notIncludeCompleted.rawValue
    }
//
    /// 抽出条件を設定
    func setFilterCondition(filterCondition: String) {
        taskUseCase.filterCondition = filterCondition
    }
//
    /// インデックスからタスクIDを取得
    private func toTaskId(index: Int) -> String {
        selectItemAt(index: index).taskId
    }
}
