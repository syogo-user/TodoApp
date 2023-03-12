//
//  TabBarViewModel.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/12.
//

import Foundation

protocol TabBarViewModel {

    func isSignIn() async -> Bool
}

class TabBarViewModelImpl: TabBarViewModel {
    private let usecase: UserUseCase = UserUseCaseImpl()

    func isSignIn() async -> Bool {
        let isSignIn = await usecase.isSignIn()
        print("isSignIn:\(isSignIn)")
        return isSignIn
    }
}

