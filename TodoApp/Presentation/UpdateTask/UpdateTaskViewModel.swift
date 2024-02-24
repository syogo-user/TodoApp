//
//  UpdateTaskViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation

protocol UpdateTaskViewModel: ObservableObject {
    /// タスクの更新
    func updateTask(taskInfoItem: TaskInfoItem) async throws
}

@MainActor
class UpdateTaskViewModelImpl: UpdateTaskViewModel {
    private let taskUseCase: TaskUseCase = TaskUseCaseImpl()
    private let userUseCase: UserUseCase = UserUseCaseImpl()

    /// タスクの更新
    func updateTask(taskInfoItem: TaskInfoItem) async throws {
        let authorization = try await userUseCase.fetchCurrentAuthToken()
        let user = try userUseCase.loadLocalUser()
        let task = try await taskUseCase.updateTask(taskId: taskInfoItem.taskId,title: taskInfoItem.title, content: taskInfoItem.content, scheduledDate: taskInfoItem.scheduledDate.dateFormat(), isCompleted: taskInfoItem.isCompleted, isFavorite: taskInfoItem.isFavorite, userId: user.userId, authorization: authorization)
        
        if task.isCompleted {
            taskUseCase.removeNotification(taskId: task.taskId)
        } else {
            taskUseCase.registerNotification(notificationId: task.taskId, title: task.title, body: task.content, scheduledDate: task.scheduledDate)
        }
        
        let taskInfoRecord = TaskInfoRecord(taskId: task.taskId, title: task.title, content: task.content, scheduledDate: task.scheduledDate, isCompleted: task.isCompleted, isFavorite: task.isFavorite, userId: task.userId)
        try taskUseCase.updateLocalTask(taskInfo: taskInfoRecord)
    }
}
