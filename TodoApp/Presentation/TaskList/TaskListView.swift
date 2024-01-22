//
//  TaskListView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/02.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModelImpl()
    @State private var isShowAlert = false
    @State private var errorMessage = ""
    
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
                .navigationBarItems(trailing: HStack {
                    Menu("並び順") {
                        Button(R.string.localizable.rightBarButtonAscendingOrderDate(), action: {
                            selectedSortItem(sortOrder: SortOrder.ascendingOrderDate)
                        })
                          Button(R.string.localizable.rightBarButtonDescendingOrderDate(), action: {
                              selectedSortItem(sortOrder: SortOrder.descendingOrderDate)
                          })
                    }
                    Menu("フィルター") {
                        Button(R.string.localizable.rightBarButtonOnlyFavorite(), action: {
                            selectedFilterItem(filterCondition: FilterCondition.onlyFavorite)
                        })
                        Button(R.string.localizable.rightBarButtonIncludeCompleted(), action: {
                            selectedFilterItem(filterCondition: FilterCondition.includeCompleted)
                        })
                        Button(R.string.localizable.rightBarButtonNotIncludeCompleted(), action: {
                            selectedFilterItem(filterCondition: FilterCondition.notIncludeCompleted)
                        })
                    }
                })

            }
            .task {
                do {
                    try await viewModel.fetchTaskList()
                } catch {
                    
                }
            }
            .alert(
                "エラー",
                isPresented: $isShowAlert,
                presenting: errorMessage
            ) { errorMessage in
                Button(errorMessage, role: .destructive) {
                    
                }
            } message: { errorMessage in
                Text(errorMessage)
            }
//            .navigationBarHidden(true)
    }

    
    private func delete(offsets: IndexSet) {
        Task {
            do {
                if let index = offsets.first {
                    try await viewModel.deleteTask(index: index)
                } else {
                    throw DomainError.unKnownError
                }
            } catch {
                
            }
        }
    }
    
    private func selectedFilterItem(filterCondition: FilterCondition) {
        viewModel.setFilterCondition(filterCondition: filterCondition.rawValue)
        do {
            try loadLocalTaskList()
        } catch {
            errorMessage = R.string.localizable.localTaskDBErrorMessage()
            isShowAlert = true
        }
    }
    
    private func selectedSortItem(sortOrder: SortOrder) {
        viewModel.setSortOrder(sortOrder: sortOrder.rawValue)
        do {
            try loadLocalTaskList()
        } catch {
            errorMessage = R.string.localizable.localTaskDBErrorMessage()
            isShowAlert = true
        }
    }
    
    private func loadLocalTaskList() throws {
        try viewModel.loadLocalTaskList()
    }
}

#Preview {
    TaskListView()
}
