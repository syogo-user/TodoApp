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

    var body: some View {
        NavigationStack {
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
            .navigationBarItems(trailing: HStack {
                Button {
                    Task {
                        do {
                            try await viewModel.updateTask(taskInfoItem: updateTask)
                            self.presentation.wrappedValue.dismiss()
                            print("更新: \(updateTask.content)")
                        } catch {
                            print("エラー: \(error)")
                        }
                    }
                } label: {
                    Text("保存")
                }
            })
        }
    }
}

#Preview {
    UpdateTaskView(updateTask: TaskInfoItem(taskId: "1", title: "タイトル", content: "内容", scheduledDate: Date(), isCompleted: false, isFavorite: true, userId: "012345"))
}
