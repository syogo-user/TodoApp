//
//  TabBarView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct TabBarView: View {
    @State var selection = 1
    @AppStorage("isSignIn") var isSignIn = false
    
    var body: some View {
        TabView(selection: $selection) {
            TaskListView()
                .tabItem {
                    Label("Page1", systemImage: "1.circle")
                }
                .tag(1)

            TaskListView()
                .tabItem {
                    Label("Page2", systemImage: "2.circle")
                }
                .tag(2)

            SettingView()
                .tabItem {
                    Label("Page3", systemImage: "3.circle")
                }
                .tag(3)
        }
    }
}

#Preview {
    TabBarView()
}
