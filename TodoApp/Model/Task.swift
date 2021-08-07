//
//  Task.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//

import UIKit

struct Task:Decodable{
    let taskId :Int
    let title:String
    let content:String
}
