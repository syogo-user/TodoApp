//
//  SettingView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/16.
//

import SwiftUI

struct SettingView: View {
    @AppStorage(R.string.localizable.isSignIn()) var isSignIn = false
    @StateObject private var viewModel = SettingViewModelImpl()
    @State private var errorMessage = ""
    @State private var isShowAlert = false
    @State private var isLoading = false
    @State private var email = ""
    @Binding var selection: Int
    
    var body: some View {
        ZStack {
            VStack {
                Image(R.image.person.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.size100, height: Size.size100, alignment: .center)
                    .padding(.top, Constraint.constraint16)
                
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
                    Text(R.string.localizable.settingSignOutButtonName())
                        .fontWeight(.semibold)
                        .frame(width: Size.size220, height: Size.size50)
                        .foregroundColor(Color(.white))
                        .background(Color(.accent))
                        .cornerRadius(CornerRadius.radius24)
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
            R.string.localizable.errorTitle(),
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
