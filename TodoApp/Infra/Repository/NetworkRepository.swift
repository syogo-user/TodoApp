//
//  NetworkRepository.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/28.
//

import RxSwift

protocol NetworkRepository {
    /// ネットに接続しているか
    func isConnect() -> Bool
}
class NetworkRepositoryImpl: NetworkRepository {
    private let remoteStore: NetworkRemoteStore = NetworkRemoteStoreImpl()

    func isConnect() -> Bool {
        remoteStore.isConnect()
    }
}
