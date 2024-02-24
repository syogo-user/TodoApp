//
//  SettingViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation

protocol SettingViewModel: ObservableObject {
    /// サインアウト
    func signOut() async throws
    /// メールアドレス取得
    func loadEmail() throws -> String
}

@MainActor
class SettingViewModelImpl: SettingViewModel {
    private let userUseCase: UserUseCase = UserUseCaseImpl()
    private var taskUseCase: TaskUseCase = TaskUseCaseImpl()

    /// サインアウト
    func signOut() async throws {
        try await userUseCase.signOut()
        try taskUseCase.deleteLocalTaskAll()
        try userUseCase.deleteLocalUser()
        taskUseCase.sortOrder = nil
        taskUseCase.filterCondition = nil
    }

    /// メールアドレス取得
    nonisolated func loadEmail() throws -> String {
        let email = try userUseCase.loadLocalUser().email
        return email
    }
}
