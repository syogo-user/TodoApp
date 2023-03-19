//
//  LaunchViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/19.
//

import Foundation
protocol LaunchViewModel {
    func setUp()
    func isSignIn() async -> Bool
}

class LaunchViewModelImpl: LaunchViewModel {
    private var usecase: UserUseCase = UserUseCaseImpl()

    func setUp() {
        usecase.isFromSignIn = false
    }

    func isSignIn() async -> Bool {
        let isSignIn = await usecase.isSignIn()
        return isSignIn
    }
}
