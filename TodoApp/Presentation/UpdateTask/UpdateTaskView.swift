//
//  UpdateTaskView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/20.
//

import SwiftUI

struct UpdateTaskView: View {
    @StateObject private var viewModel = UpdateTaskViewModelImpl()
    @StateObject var updateTask: TaskInfoItem // TODO: ここの実装はStateObjectが適切か
    
    var body: some View {
        VStack {
            TextField("タイトル", text: $updateTask.title)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {

                }
            TextField("内容", text: $updateTask.content)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {

                }
            Button {
                print("更新: \(updateTask.content)")
            } label: {
                Text("保存")
            }
            Spacer()
        }
    }
}

#Preview {
    UpdateTaskView(updateTask: TaskInfoItem(taskId: "1", title: "タイトル", content: "内容", scheduledDate: Date(), isCompleted: false, isFavorite: true, userId: "012345"))
}
