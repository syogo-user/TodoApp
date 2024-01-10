////
////  APIClient.swift
////  TodoApp
////
////  Created by 小野寺祥吾 on 2024/01/02.
////
//
//import Foundation
//
//protocol APIClientProtocol: AnyObject {
//    func send<T: RequestProtocol>(_ request: T) async throws -> T.Response
//}
//
//final class APIClient: APIClientProtocol {
//    private init() {}
//    public static let shared = APIClient()
//    
//    public func send<T: RequestProtocol>(_ request: T) async throws -> T.Response {
//        guard let url = URL(string: request.baseURL)?.appendingPathComponent(request.path) else {
//            throw APIError.failedToCreateURL
//        }
//        
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            throw APIError.failedToCreateComponents(url)
//        }
//        
//        components.queryItems = request.parameters?.compactMap {
//            .init(name: $0.key, value: "\($0.value)")
//        }
//        
//        guard var urlRequest = components.url.map({ URLRequest(url: $0) }) else {
//            throw APIError.failedToCreateURL
//        }
//        
//        urlRequest.httpMethod = request.method.rawValue
//        
//        urlRequest.allHTTPHeaderFields = [
//            "Content-Type": "application/json"
//        ]
//        
//        do {
//            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
//            // responseのチェック
//            guard let urlResponse = urlResponse as? HTTPURLResponse else {
//                throw APIError.noResponse
//            }
//            
//            // HTTPステータスコードのチェック
//            guard 200 ..< 300 ~= urlResponse.statusCode else {
//                throw APIError.unacceptableStatusCode(
//                    urlResponse.statusCode
//                )
//            }
//            
//            let decodedData = try JSONDecoder().decode(T.Response.self, from: data)
//            // Responseデータのstatus項目が正常値であることをチェック
//            guard decodedData.status == "ok" else {
//                throw APIError.responseStatusError
//            }
//            return decodedData
//        } catch {
//            if let error = error as? DecodingError {
//                // Decodeエラーのハンドリング
//                throw APIError.parserError(error.localizedDescription)
//            } else if let error = error as? APIError {
//                // 上流のPublisherでエラーが発生していればここで返す
//                throw error
//            } else {
//                throw APIError.unknown(error.localizedDescription)
//            }
//        }
//    }
//}
//
//enum APIError: Error {
//    case parserError(_ code: String)
//    case responseStatusError
//    case unknown(_ code: String)
//    case noResponse
//    case unacceptableStatusCode(_ code: Int)
//    case failedToCreateURL
//    case failedToCreateComponents(_ url: URL)
//}
