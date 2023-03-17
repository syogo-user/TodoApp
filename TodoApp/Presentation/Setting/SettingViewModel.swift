//
//  SettingViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import Amplify
import AWSCognitoAuthPlugin
import RxSwift
import RxCocoa
import Foundation

protocol SettingViewModel {
    /// サインアウト
    func signOutLocally() async throws
    /// トークン情報を取得
    func fetchCurrentAuthToken() async throws -> String
    /// ユーザ情報取得
    func loadUser() throws
    /// ユーザ情報削除
    func deleteLocalUser()
}

class SettingViewModelImpl: SettingViewModel {
    private var disposeBag = DisposeBag()
    private let usecase: UserUseCase = UserUseCaseImpl()

    func signOutLocally() async throws {
       try await usecase.signOut()
    }

    func fetchCurrentAuthToken() async throws -> String {
       try await usecase.fetchCurrentAuthToken()
    }

    func loadUser() throws {
       let userInfo = try usecase.loadLocalUser()
    }

    func deleteLocalUser() {
        usecase.deleteLocalUser()
    }
}
