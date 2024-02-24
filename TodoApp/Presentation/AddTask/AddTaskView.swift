//
//  AddTaskView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/21.
//

import SwiftUI

struct AddTaskView: View {
    @StateObject private var viewModel = AddTaskViewModelImpl()
    @State private var errorMessage = ""
    @State private var isShowAlert = false
    @State private var isLoading = false
    @State private var inputTitle = ""
    @State private var inputContent = ""
    @State private var inputScheduledDate = Date()
    @Binding var selection: Int
    private let validate: Validate = Validate()
    
    var body: some View {
        ZStack {
            VStack(spacing: Constraint.constraint16) {
                TextField(R.string.localizable.textFieldTitle(), text: $inputTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, Constraint.constraint16)
                
                TextEditor(text: $inputContent)
                    .frame(height: Size.size100)
                    .overlay(RoundedRectangle(cornerRadius: CornerRadius.radius8).stroke(.gray, lineWidth: Line.thinness02))
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    DatePicker(R.string.localizable.datePickerTitle(), selection: $inputScheduledDate)
                        .labelsHidden()
                    Spacer()
                }
                
                Button {
                    Task {
                        do {
                            if (validate.isEmpty(inputArray: inputTitle)) {
                                errorMessage = R.string.localizable.emptyTitleMessage()
                                isShowAlert = true
                                return
                            }
                            if (validate.isWordLengthOver(word: inputTitle, wordLimit: Constants.titleWordLimit)) {
                                errorMessage = R.string.localizable.overTitleLengthMessage(String(Constants.titleWordLimit))
                                isShowAlert = true
                                return
                            }
                            isLoading = true
                            try await viewModel.addTask(title: inputTitle, content: inputContent, scheduledDate: Date().dateFormat())
                            inputTitle = ""
                            inputContent = ""
                            selection = 1
                            isLoading = false
                        } catch let error {
                            errorMessage = errorMessage(error: error)
                            isShowAlert = true
                            isLoading = false
                        }
                    }
                } label: {
                    Text(R.string.localizable.addTaskButtonName())
                        .fontWeight(.bold)
                        .frame(width: Size.size220, height: Size.size50)
                        .foregroundColor(Color(.white))
                        .background(Color(.accent))
                        .cornerRadius(CornerRadius.radius24)
                    
                }
                Spacer()
            }
            .padding(.horizontal, Constraint.constraint16)
            if isLoading {
                ProgressView()
            }
        }
        .alert(
            R.string.localizable.errorTitle(),
            isPresented: $isShowAlert
        ) {} message: {
            Text(errorMessage)
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
    AddTaskView(selection: .constant(1))
}
