//
//  SignUpViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/11.
//


protocol SignUpViewModel {
    func signUp(userName: String, password: String, email: String)
}

class SignUpViewModelImpl: SignUpViewModel {
    private let usecase: UserUseCase = UserUseCaseImpl()

    func signUp(userName: String, password: String, email: String) {
        Task {
            await usecase.signUp(userName: userName, password: password, email: email)
        }
    }
}
