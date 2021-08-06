//
//  Task.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//

import UIKit

class Task:NSObject{
    var id :String = ""
    var title:String = ""
    var content:String?
    var date:Date?
    
    init(id:String,title:String,content:String?,date:Date) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
    }
}
