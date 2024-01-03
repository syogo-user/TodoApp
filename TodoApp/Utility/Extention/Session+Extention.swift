//
//  Session+Extention.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2023/03/17.
//

import Foundation
import APIKit
import RxSwift

extension Session {

    private static let privateShared: Session = {
        let configuration = URLSessionConfiguration.noCache
        let adapter = URLSessionAdapter(configuration: configuration)
        return Session(adapter: adapter)
    }()

    class var shared: Session {
        privateShared
    }

    func rx_send<T: Request>(_ request: T) -> Single<T.Response> {
        Single.create { observer in
            let task = self.send(request) { result in
                switch result {
                case .success(let value):
                    print("success: \(value)")
                    observer(.success(value))
                case .failure(let error):
                    print("error: \(error)")
                    observer(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    func async_send<T: Request>(_ request: T) async throws -> T.Response {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.send(request) { result in
                switch result {
                case .success(let value):
                    print("success: \(value)")
                    continuation.resume(returning: value)
                case .failure(let error):
                    print("error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            continuation.onCancelled {
                task?.cancel()
            }
        }
    }

    class func async_send<T: Request>(_ request: T) async throws -> T.Response {
        shared.async_send(request)
    }
    
    class func rx_send<T: APIKit.Request>(_ request: T) -> Single<T.Response> {
        shared.rx_send(request)
    }

}
