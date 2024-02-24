//
//  TabBarView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct TabBarView: View {
    @AppStorage(R.string.localizable.isSignIn()) var isSignIn = false
    @State var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            TaskListView()
                .tabItem {
                    Label(R.string.localizable.tabItemListTitle(), systemImage: R.string.localizable.tabItemListImage())
                }
                .tag(1)

            AddTaskView(selection: $selection)
                .tabItem {
                    Label(R.string.localizable.tabItemPostTitle(), systemImage: R.string.localizable.tabItemPostImage())
                }
                .tag(2)

            SettingView(selection: $selection)
                .tabItem {
                    Label(R.string.localizable.tabItemSettingTitle(), systemImage: R.string.localizable.tabItemSettingImage())
                }
                .tag(3)
        }
        .accentColor(Color(.accent))
    }
}

#Preview {
    TabBarView()
}
