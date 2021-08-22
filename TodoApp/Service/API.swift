//
//  API.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/07.
//

import Foundation
import Alamofire

class API {
    static let shared = API()
    private let baseUrl = "https://todoapp-7f440-default-rtdb.firebaseio.com/"
    // タスク一覧を取得
    func getTasks<T: Decodable>(uid: String, type: T.Type, completion: @escaping (T?) -> Void) {
        let url = baseUrl + "tasks.json"
        let parameters = [
            "orderBy": #""uid""#,
            "equalTo": #""\#(uid)""#
        ]
        let method = HTTPMethod.get
        let encoding: ParameterEncoding = URLEncoding(destination:.queryString)
        request(url: url, method: method, parameter: parameters, encoding: encoding, type: type, completion: completion)
    }
    
    // タスクの作成
    func createTask<T: Decodable>(type: T.Type, task:Task, completion: @escaping (T?) -> Void) {
        let url = baseUrl + "tasks.json"
        let parameters: [String:Any] = [
            "title": task.title,
            "content": task.content,
            "uid": task.uid,
            "date": task.date,
            "order": task.order
        ]
        let method = HTTPMethod.post
        let encoding: ParameterEncoding = JSONEncoding.default
        request(url: url, method: method, parameter: parameters, encoding: encoding, type: type, completion: completion)
    }
    
    // タスクの削除
    func deleteTask<T: Decodable>(deleteTaskId: String, type: T.Type, completion: @escaping (T?) -> Void) {
        let url = baseUrl + "tasks/" + deleteTaskId + ".json"
        let encoding: ParameterEncoding = JSONEncoding.default
        let method = HTTPMethod.delete
        request(url:url, method: method, parameter: nil, encoding: encoding, type: type, completion: completion)
    }
    
    // タスクの再投稿
    func putTask<T: Decodable>(type: T.Type, task:Task, completion: @escaping (T?) -> Void) {
        let url = baseUrl + "tasks/" + task.taskId + ".json"
        let parameters: [String:Any] = [
            "title": task.title,
            "content": task.content,
            "uid": task.uid,
            "date": task.date,
            "order": task.order
        ]
        let method = HTTPMethod.put
        let encoding: ParameterEncoding = JSONEncoding.default
        request(url: url, method: method, parameter: parameters, encoding: encoding, type: type, completion: completion)
    }
    
    private func request<T: Decodable>(url: String, method: HTTPMethod, parameter: [String:Any]?, encoding: ParameterEncoding, type: T.Type, completion: @escaping (T?) -> Void) {
        let request = AF.request(url, method: method, parameters: parameter, encoding: encoding)
        print("url:", url)
        request.responseJSON { response in
            guard let statusCode = response.response?.statusCode else { return }
            var value: T?
            if statusCode / 100 == 2 {
                // リクエストコードが200番台(リクエスト成功)
                if method == .get {
                    do {
                        guard let data = response.data else { return }
                        let decorder = JSONDecoder()
                        value = try decorder.decode(T.self, from: data)
                    } catch {
                        print("Jsonの変換に失敗しました:", error)
                    }
                }
            }
            // コールバック
            completion(value)
        }
    }
}
