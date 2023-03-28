//
//  NetworkUseCase.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/28.
//

import RxSwift

protocol NetworkUseCase {
    /// ネットに接続しているか
    func isConnect() -> Bool
}

class NetworkUseCaseImpl: NetworkUseCase {
    private let repository: NetworkRepository = NetworkRepositoryImpl()

    func isConnect() -> Bool {
        repository.isConnect()
    }
}

