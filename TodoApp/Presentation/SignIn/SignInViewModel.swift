//
//  SignInViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//

import Amplify
import AWSCognitoAuthPlugin
import RxSwift
import RxCocoa

protocol SignInViewModel: ObservableObject {
    /// ソーシャルサインイン
    func socialSigIn(provider: AuthProvider) async throws
}

@MainActor
class SignInViewModelImpl: SignInViewModel {
    private var useCase: UserUseCase = UserUseCaseImpl()

    func socialSigIn(provider: AuthProvider) async throws {
        try await useCase.socialSignIn(provider: provider)
        let userInfo = try await useCase.fetchUserInfo()
        let subAttribute = userInfo.filter { $0.key == .sub }.first
        let emailAttribute = userInfo.filter { $0.key == .email }.first
        guard let userId = subAttribute?.value else {
            throw DomainError.authError
        }
        guard let email = emailAttribute?.value else {
            throw DomainError.authError
        }
        try useCase.insertLocalUser(userId: userId, email: email)
    }
}
