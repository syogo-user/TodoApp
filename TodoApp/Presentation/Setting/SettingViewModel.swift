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
    /// ユーザ情報取得
    func loadUser() throws
    /// ユーザ情報削除
    func deleteLocalUser()
}

class SettingViewModelImpl: SettingViewModel {
    private let disposeBag = DisposeBag()
    private let usecase: UserUseCase = UserUseCaseImpl()

    func signOutLocally() async throws {
       try await usecase.signOut()
    }

    func loadUser() throws {
       let userInfo = try usecase.loadLocalUser()
    }

    func deleteLocalUser() {
        usecase.deleteLocalUser()
    }
}
