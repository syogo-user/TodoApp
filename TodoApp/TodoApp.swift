//
//  TodoApp.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/04.
//

import SwiftUI

@main
struct TodoApp: App {
    
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
//            ContentView() // 最初に表示される View
//            TaskListView()
            SignInView()
        }
    }
}

