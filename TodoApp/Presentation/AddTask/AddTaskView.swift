//
//  AddTaskView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/21.
//

import SwiftUI

struct AddTaskView: View {
    @StateObject private var viewModel = AddTaskViewModelImpl()
    @State private var inputTitle = ""
    @State private var inputContent = ""
    var body: some View {
        VStack {
            TextField("タイトル", text: $inputTitle)
            TextField("内容", text: $inputContent)
            
            Button {
                Task {
                    do {
                        try await viewModel.addTask(title: inputTitle, content: inputContent, scheduledDate: Date().dateFormat())
                        inputTitle = ""
                        inputContent = ""
                    } catch {
                        print("投稿エラー: \(error)")
                    }
                }
            } label: {
                Text("投稿")
            }
            Spacer()
        }
    }
}

#Preview {
    AddTaskView()
}
