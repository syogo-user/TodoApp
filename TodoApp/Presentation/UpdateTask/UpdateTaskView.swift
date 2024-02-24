//
//  UpdateTaskView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/20.
//

import SwiftUI

struct UpdateTaskView: View {
    @StateObject private var viewModel = UpdateTaskViewModelImpl()
    @StateObject var updateTask: TaskInfoItem
    @SwiftUI.Environment(\.presentationMode) var presentation
    @State private var isShowAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    HStack {
                        Toggle(isOn: $updateTask.isCompleted) {
                        }
                        .toggleStyle(.checkBox)
                        .padding(8)
                        
                        Button {
                            updateTask.isFavorite.toggle()
                        } label: {
                            let imageName = updateTask.isFavorite ? "star_fill" : "star_frame"
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20, alignment: .trailing)
                            
                        }
                        Spacer()
                        DatePicker("日時", selection: $updateTask.scheduledDate)
                            .labelsHidden()
                    }
                    TextField("タイトル", text: $updateTask.title)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            
                        }
                    
                    TextEditor(text: $updateTask.content)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 0.2))
                        .textFieldStyle(.roundedBorder)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                if isLoading {
                    ProgressView()
                }
            }
            .navigationBarItems(trailing: HStack {
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.updateTask(taskInfoItem: updateTask)
                            self.presentation.wrappedValue.dismiss()
                            isLoading = false
                            print("更新: \(updateTask.content)")
                        } catch let error {
                            errorMessage = errorMessage(error: error)
                            isShowAlert = true
                            isLoading = false
                            print("エラー: \(error)")
                        }
                    }
                } label: {
                    Text("保存")
                }
            })
            .alert(
                "エラー",
                isPresented: $isShowAlert
            ) {} message: {
                Text(errorMessage)
            }
        }
    }
    private func errorMessage(error: Error) -> String {
        switch error {
        case DomainError.authError :
            return R.string.localizable.tokenErrorMessage()
        case DomainError.localDbError :
            return R.string.localizable.localTaskDBErrorMessage()
        case DomainError.onAPIUpdateError:
            return R.string.localizable.updateTaskErrorMessage()
        case DomainError.unKnownError :
            return R.string.localizable.unknownErrorMessage()
        default:
            return R.string.localizable.unknownErrorMessage()
        }
    }
}

#Preview {
    UpdateTaskView(updateTask: TaskInfoItem(taskId: "1", title: "タイトル", content: "内容", scheduledDate: Date(), isCompleted: false, isFavorite: true, userId: "012345"))
}
