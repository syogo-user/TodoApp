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
    @AppStorage("isSignIn") var isSignIn = false
    
    var body: some Scene {
        WindowGroup {
            if isSignIn {
                TabBarView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .edgesIgnoringSafeArea(.all)
            } else {
                SignInView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        
    }
}

