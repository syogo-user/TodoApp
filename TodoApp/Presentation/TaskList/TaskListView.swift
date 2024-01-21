//
//  TaskListView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/02.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModelImpl()
    
    var body: some View {
            NavigationStack {
                // Todo: データが取得してもなかった場合に、データがありませんになるように修正
//                if viewModel.lifeInfoList.isEmpty {
//                    ProgressView() // ローディング
//                    Text("取得中")
//                } else {
                List {
                    ForEach(viewModel.taskInfoItems, id: \.taskId) { task in
                        NavigationLink(destination: UpdateTaskView(updateTask: task)) {
                            // セルのカスタムView
                            VStack {
                                Text("\(task.taskId)")
                                Text("\(task.content)")
                            }
                        }
                    }
                    //                    }
                    .onDelete(perform: delete)
                }
            }
            .task {
                do {
                    try await viewModel.fetchTaskList()
                } catch {
                    
                }
            }
            .navigationBarHidden(true)
    }

    
    func delete(offsets: IndexSet) {
        Task {
            do {
                print("★：\(offsets.first)")
                if let index = offsets.first {
                    try await viewModel.deleteTask(index: index)
                } else {
                    throw DomainError.unKnownError
                }
            } catch {
                
            }
        }
    }
}

#Preview {
    TaskListView()
}
