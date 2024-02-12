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
                    Label("一覧", systemImage: "list.bullet")
                }
                .tag(1)

            AddTaskView()
                .tabItem {
                    Label("投稿", systemImage: "plus")
                }
                .tag(2)

            SettingView()
                .tabItem {
                    Label("アカウント", systemImage: "person")
                }
                .tag(3)
        }
        .accentColor(Color(.accent))
    }
}

#Preview {
    TabBarView()
}
