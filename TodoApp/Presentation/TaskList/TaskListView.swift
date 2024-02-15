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
                            TaskCellView(task: task, favoriteButtonClick: { isFavorite in
                                Task {
                                    do {
                                        // お気に入り更新
                                        try viewModel.changeFavorite(item: task, isFavorite: isFavorite)
                                        try await viewModel.updateTask(taskInfoItem: task)
                                        // 描画のためローカルからデータを取得する
                                        try self.loadLocalTaskList()
                                    } catch {
                                        print("!!!!!エラー!")
                                    }
                                }
                            })
                        }
                    }
                    .onDelete(perform: delete)
                }
                .navigationBarItems(trailing: HStack {
                    Menu {
                        Button(R.string.localizable.rightBarButtonAscendingOrderDate(), action: {
                            selectedSortItem(sortOrder: SortOrder.ascendingOrderDate)
                        })
                        Button(R.string.localizable.rightBarButtonDescendingOrderDate(), action: {
                            selectedSortItem(sortOrder: SortOrder.descendingOrderDate)
                        })
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                    }
                    
                    Menu {
                        Button(R.string.localizable.rightBarButtonOnlyFavorite(),
                               action: {
                            selectedFilterItem(filterCondition: FilterCondition.onlyFavorite)
                        })
                        Button(R.string.localizable.rightBarButtonIncludeCompleted(), action: {
                            selectedFilterItem(filterCondition: FilterCondition.includeCompleted)
                        })
                        Button(R.string.localizable.rightBarButtonNotIncludeCompleted(), action: {
                            selectedFilterItem(filterCondition: FilterCondition.notIncludeCompleted)
                        })

                    } label: {
                        Image(systemName: "ellipsis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)

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

struct RefreshChecker {
    init(task: TaskInfoItem) {
        print("refreshed!\(task.title),\(task.isFavorite)")
    }
}

struct TaskCellView: View {
    @ObservedObject var task: TaskInfoItem
    let favoriteButtonClick: (Bool) -> Void
    
    var body: some View {
        let checker = RefreshChecker(task: task)
        HStack(alignment: .center) {
            Toggle(isOn: $task.isCompleted) {
                
            }
            .toggleStyle(.checkBox)
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .fontWeight(.semibold)
                Text(task.content)
                    .lineLimit(1)
                Text(task.scheduledDate.dateFormat().dateJpFormat())
                    .foregroundColor(Color(.darkGray))
            }
            
            Spacer()

            Button {
                favoriteButtonClick(!task.isFavorite)
            } label: {
                let imageName = task.isFavorite ? "star_fill" : "star_frame"
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30, alignment: .trailing)
            }
            .buttonStyle(.plain)

        }

    }

}

#Preview {
    TaskListView()
}
