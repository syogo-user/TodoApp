//
//  API.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/07.
//

import Foundation
import Alamofire
class API{
    static let shared = API()
    private let baseUrl = "https://todoapp-7f440-default-rtdb.firebaseio.com/users/"
    //タスク一覧の取得
    func request<T:Decodable>(uid:String,type:T.Type,completion:@escaping (T)->Void){
        let url = baseUrl + uid + "/tasks.json"
        let request = AF.request(url,method: .get,parameters: nil)
        print("url:",url)
        request.responseJSON { (response) in
            guard let statusCode = response.response?.statusCode else{return}
            if statusCode <= 300{
                //リクエストが成功した場合
                do{
                    guard let data = response.data else{return}
                    let decorder = JSONDecoder()
                    let value = try decorder.decode(T.self, from: data)
                    //コールバック
                    completion(value)
                }catch{
                    print("Jsonの変換に失敗しました:",error)
                }
            }
        }
    }
    //タスクの追加
    func patchRequest<T:Decodable>(uid:String,task:Task,type:T.Type,completion:@escaping ()->Void){
        let url = baseUrl + uid + "/tasks.json"
        let parameters = [
            "\(task.taskId)":[
                "taskId": task.taskId,
                "title": task.title,
                "content":task.content
                ]
            ]
        let request = AF.request(url,method: .patch,parameters: parameters,encoding: JSONEncoding.default)
        print("url:",url)
        request.responseJSON { (response) in
            //コールバック
            completion()
            //TODO タスクの追加が成功したかどうかの判定
            
//            guard let statusCode = response.response?.statusCode else{return}
//            if statusCode <= 300{
//                //リクエストが成功した場合
//                do{
//                    guard let data = response.data else{return}
//                    let decorder = JSONDecoder()
//                    let value = try decorder.decode(T.self, from: data)
//
//                }catch{
//                    print("Jsonの変換に失敗しました:",error)
//                }
//            }
        }
    }

    
}
