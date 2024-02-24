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
    private let validate: Validate = Validate()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: Constraint.constraint16) {
                    HStack {
                        Toggle(isOn: $updateTask.isCompleted) {
                        }
                        .toggleStyle(.checkBox)
                        .padding(Constraint.constraint8)
                        
                        Button {
                            updateTask.isFavorite.toggle()
                        } label: {
                            let imageName = updateTask.isFavorite ? R.image.star_fill.name : R.image.star_frame.name
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Size.size20, height: Size.size20, alignment: .trailing)
                            
                        }
                        Spacer()
                        DatePicker(R.string.localizable.datePickerTitle(), selection: $updateTask.scheduledDate)
                            .labelsHidden()
                    }
                    TextField(R.string.localizable.textFieldTitle(), text: $updateTask.title)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            
                        }
                    
                    TextEditor(text: $updateTask.content)
                        .frame(height: Size.size100)
                        .overlay(RoundedRectangle(cornerRadius: CornerRadius.radius8).stroke(.gray, lineWidth: Line.thinness02))
                        .textFieldStyle(.roundedBorder)
                    
                    Spacer()
                }
                .padding(.horizontal, Constraint.constraint16)
                if isLoading {
                    ProgressView()
                }
            }
            .navigationBarItems(trailing: HStack {
                Button {
                    Task {
                        do {
                            if (validate.isEmpty(inputArray: updateTask.title)) {
                                errorMessage = R.string.localizable.emptyTitleMessage()
                                isShowAlert = true
                                return
                            }
                            if (validate.isWordLengthOver(word: updateTask.title, wordLimit: Constants.titleWordLimit)) {
                                errorMessage = R.string.localizable.overTitleLengthMessage(String(Constants.titleWordLimit))
                                isShowAlert = true
                                return
                            }

                            isLoading = true
                            try await viewModel.updateTask(taskInfoItem: updateTask)
                            self.presentation.wrappedValue.dismiss()
                            isLoading = false
                        } catch let error {
                            errorMessage = errorMessage(error: error)
                            isShowAlert = true
                            isLoading = false
                        }
                    }
                } label: {
                    Text(R.string.localizable.updateTaskViewSaveButtonText())
                }
            })
            .alert(
                R.string.localizable.errorTitle(),
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
