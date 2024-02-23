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
    @State private var inputScheduledDate = Date()
    @Binding var selection: Int
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                TextField("タイトル", text: $inputTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 16)
                
                TextEditor(text: $inputContent)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 0.2))
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    DatePicker("日時", selection: $inputScheduledDate)
                        .labelsHidden()
                    Spacer()
                }
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.addTask(title: inputTitle, content: inputContent, scheduledDate: Date().dateFormat())
                            inputTitle = ""
                            inputContent = ""
                            selection = 1
                            isLoading = false
                        } catch {
                            isLoading = false
                            print("投稿エラー: \(error)")
                        }
                    }
                } label: {
                    Text("投稿")
                        .fontWeight(.bold)
                        .frame(width: 220, height: 45)
                        .foregroundColor(Color(.white))
                        .background(Color(.accent))
                        .cornerRadius(24)
                    
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            if isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    AddTaskView(selection: .constant(1))
}
