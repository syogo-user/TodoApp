////
////  Request.swift
////  TodoApp
////
////  Created by 小野寺祥吾 on 2024/01/02.
////
//
//import Foundation
//
//// MARK: - RequestProtocol
//protocol RequestProtocol {
//    associatedtype Response: DataStructure
//    var method: HTTPMethod { get }
//    var baseURL: String { get }
//    var path: String { get }
//    var parameters: [String : Any]? { get set }
//}
//
//extension RequestProtocol {
//    var baseURL: String {
//        return "https://newsapi.org/v2/"
//    }
//}
//
//// MARK: - HTTPMethod
//enum HTTPMethod: String {
//    case POST = "POST"
//    case GET = "GET"
//}
//
//// MARK: - DataStructure
//protocol DataStructure: Encodable, Decodable {
//    var status: String { get }
//}
