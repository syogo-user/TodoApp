//
//  SettingView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModelImpl()
    @AppStorage("isSignIn") var isSignIn = false
    
    var body: some View {
        Button {
            Task {
                do {
                    try await viewModel.signOut()
                    isSignIn = false                    
                } catch {
                    print("エラー: \(error)")
                }
            }
        } label: {
            Text("サインアウト")
        }

//        VStack{
//            Image()
//            Text()
//            Button()
//        }
    }
}

#Preview {
    SettingView()
}
