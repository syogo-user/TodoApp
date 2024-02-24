//
//  AddTaskViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol AddTaskViewModel: ObservableObject {
    /// タスクを登録
    func addTask(title: String, content: String, scheduledDate: String) async throws
}

@MainActor
class AddTaskViewModelImpl: AddTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    
    /// タスクの追加
    func addTask(title: String, content: String, scheduledDate: String) async throws {
        let authorization = try await userUseCase.fetchCurrentAuthToken()
        let user = try userUseCase.loadLocalUser()
        
        let task = try await taskUseCase.addTask(title: title, content: content, scheduledDate: scheduledDate, isCompleted: false, isFavorite: false, userId: user.userId, authorization: authorization)
        taskUseCase.registerNotification(notificationId: task.taskId, title: task.title, body: task.content, scheduledDate: task.scheduledDate)
        
        let taskInfoRecord = TaskInfoRecord(taskId: task.taskId, title: task.title, content: task.content, scheduledDate: task.scheduledDate, isCompleted: task.isCompleted, isFavorite: task.isFavorite, userId: task.userId)
        try taskUseCase.insertLocalTask(taskInfo: taskInfoRecord)
    }
}
