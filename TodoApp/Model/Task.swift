//
//  Task.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2021/08/06.
//


import UIKit

struct TaskList {    
    var tasks : [Task] = []
}

struct Task: Decodable {
    var taskId: String = ""
    var title: String
    var content: String
    
    init(taskId: String, title: String, content: String) {
        self.taskId = taskId
        self.title = title
        self.content = content
    }
    
    init(title: String, content: String) {
        self.init(taskId: "", title: title, content: content)
    }
    
}

extension TaskList: Decodable {
    private struct CustomCodingKey: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) { return nil }

        static let title = CustomCodingKey(stringValue: "title")!
        static let content = CustomCodingKey(stringValue: "content")!
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKey.self)
        
        for key in container.allKeys {
            print(key)
            let tasksContainer = try container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: CustomCodingKey(stringValue: key.stringValue)!)
            let title = try tasksContainer.decode(String.self, forKey: .title)
            let content = try tasksContainer.decode(String.self, forKey: .content)
            self.tasks.append(Task(taskId: key.stringValue, title: title, content: content))
        }
    }
}
