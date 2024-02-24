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
    @State private var isLoading = false
    @AppStorage(R.string.localizable.isSignIn()) var isSignIn = false
    
    var body: some View {
        NavigationStack {
            // TODO: データ取得時0件の場合に、データがありませんになるように修正
            ZStack {
                List {
                    ForEach(viewModel.taskInfoItems, id: \.taskId) { task in
                        NavigationLink(destination: UpdateTaskView(updateTask: task).onDisappear {
                            // NOTE: 更新画面から戻ったときに値が変わってしまう事象は一旦onDisappearで対応にする
                            do {
                                isLoading = true
                                try self.loadLocalTaskList()
                                isLoading = false
                            } catch let error {
                                errorMessage = errorMessage(error: error)
                                isShowAlert = true
                                isLoading = false
                            }
                        }) {
                            TaskCellView(
                                task: task,
                                favoriteButtonClick: { isFavorite in
                                    Task {
                                        do {
                                            isLoading = true
                                            // お気に入り更新
                                            try viewModel.changeFavorite(item: task, isFavorite: isFavorite)
                                            try await viewModel.updateTask(taskInfoItem: task)
                                            isLoading = false
                                        } catch let error {
                                            errorMessage = errorMessage(error: error)
                                            isLoading = false
                                            isShowAlert = true
                                        }
                                    }
                                }, completeButtonClick: { isCompleted in
                                    Task {
                                        do {
                                            isLoading = true
                                            try viewModel.changeComplete(item: task, isCompleted: isCompleted)
                                            try await viewModel.updateTask(taskInfoItem: task)
                                            isLoading = false
                                        } catch let error {
                                            errorMessage = errorMessage(error: error)
                                            isLoading = false
                                            isShowAlert = true
                                        }
                                    }
                                } )
                        }
                    }
                    .onDelete(perform: delete)
                }
                .refreshable {
                    do {
                        isLoading = true
                        try await viewModel.fetchTaskList()
                        isLoading = false
                    } catch let error {
                        errorMessage = errorMessage(error: error)
                        isLoading = false
                        isShowAlert = true
                    }
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
                        Image(systemName: R.string.localizable.taskListViewOrderButtonImageName())
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
                        Image(systemName: R.string.localizable.taskListViewFilterButtonImageName())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                        
                    }
                })
                if isLoading {
                    ProgressView()
                }
            }
        }
        .task {
//            if !isSignIn {
//                return
//            }
            do {
                isLoading = true
                try await viewModel.fetchTaskList()
                isLoading = false
            } catch let error {
                errorMessage = errorMessage(error: error)
                isLoading = false
                isShowAlert = true
            }
        }
        .alert(
            R.string.localizable.errorTitle(),
            isPresented: $isShowAlert
        ) {} message: {
            Text(errorMessage)
        }
    }

    
    private func delete(offsets: IndexSet) {
        Task {
            do {
                isLoading = true
                if let index = offsets.first {
                    try await viewModel.deleteTask(index: index)
                } else {
                    throw DomainError.unKnownError
                }
                isLoading = false
            } catch let error {
                errorMessage = errorMessage(error: error)
                isLoading = false
                isShowAlert = true
            }
        }
    }
    
    private func errorMessage(error: Error) -> String {
        switch error {
        case DomainError.authError :
            return R.string.localizable.tokenErrorMessage()
        case DomainError.localDbError :
            return R.string.localizable.localTaskDBErrorMessage()
        case DomainError.onAPIFetchError:
            return R.string.localizable.fetchTaskErrorMessage()
        case DomainError.onAPIUpdateError:
            return R.string.localizable.updateTaskErrorMessage()
        case DomainError.unKnownError :
            return R.string.localizable.unknownErrorMessage()
        default:
            return R.string.localizable.unknownErrorMessage()
        }
    }
    
    private func selectedFilterItem(filterCondition: FilterCondition) {
        isLoading = true
        viewModel.setFilterCondition(filterCondition: filterCondition.rawValue)
        do {
            try loadLocalTaskList()
            isLoading = false
        } catch let error {
            errorMessage = errorMessage(error: error)
            isShowAlert = true
            isLoading = false
        }
    }
    
    private func selectedSortItem(sortOrder: SortOrder) {
        isLoading = true
        viewModel.setSortOrder(sortOrder: sortOrder.rawValue)
        do {
            try loadLocalTaskList()
            isLoading = false
        } catch let error {
            errorMessage = errorMessage(error: error)
            isShowAlert = true
            isLoading = false
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
    let completeButtonClick: (Bool) -> Void
    
    var body: some View {
        let checker = RefreshChecker(task: task)
        HStack(alignment: .center) {
            Toggle(isOn: $task.isCompleted) {}
            .onChange(of: task.isCompleted) { newValue in
                completeButtonClick(newValue)
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
                let imageName = task.isFavorite ?  R.image.star_fill.name : R.image.star_frame.name
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
