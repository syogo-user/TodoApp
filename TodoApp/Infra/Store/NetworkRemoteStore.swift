//
//  NetworkRemoteStore.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/28.
//

import RxSwift
import Reachability
import Network

protocol NetworkRemoteStore {
    /// ネットに接続しているか
    func isConnect() -> Bool
}
class NetworkRemoteStoreImpl: NetworkRemoteStore {

    func isConnect() -> Bool {
        do {
            let reachability = try Reachability()
            switch reachability.connection {
            case .wifi, .cellular:
                return true
            case .unavailable, .none:
                return false
            }
        } catch {
            return false
        }
    }
}
