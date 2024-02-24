//
//  SettingView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct SettingView: View {
    @AppStorage("isSignIn") var isSignIn = false
    @StateObject private var viewModel = SettingViewModelImpl()
    @State private var email = ""
    @Binding var selection: Int
    @State private var isShowAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack {
                Image(R.image.person.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(.top, 16)
                
                Text(email)
                    .fontWeight(.semibold)
                
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.signOut()
                            isSignIn = false
                            isLoading = false
                            selection = 1
                        } catch let error {
                            errorMessage = errorMessage(error: error)
                            isShowAlert = true
                            isLoading = false
                        }
                    }
                } label: {
                    Text("サインアウト")
                        .fontWeight(.semibold)
                        .frame(width: 220, height: 45)
                        .foregroundColor(Color(.white))
                        .background(Color(.accent))
                        .cornerRadius(24)
                }
                .padding()
                Spacer()
            }
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            do {
                email = try viewModel.loadEmail()
            } catch let error {
                errorMessage = errorMessage(error: error)
                isShowAlert = true
            }
        }
        .alert(
            "エラー",
            isPresented: $isShowAlert
        ) {} message: {
            Text(errorMessage)
        }
    }
    
    private func errorMessage(error: Error) -> String {
        switch error {
        case DomainError.authError :
            return R.string.localizable.signOutErrorMessage()
        case DomainError.localDbError :
            return R.string.localizable.localUserDBErrorMessage()
        case DomainError.unKnownError :
            return R.string.localizable.unknownErrorMessage()
        default:
            return R.string.localizable.unknownErrorMessage()
        }
    }
}

#Preview {
    SettingView(selection: .constant(1))
}
