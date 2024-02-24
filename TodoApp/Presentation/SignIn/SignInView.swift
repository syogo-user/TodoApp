//
//  SignInView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/12.
//

import SwiftUI
import Amplify

struct SignInView: View {
    @AppStorage(R.string.localizable.isSignIn()) var isSignIn = false
    @StateObject private var viewModel = SignInViewModelImpl()
    @State private var errorMessage = ""
    @State private var isShowAlert = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Spacer(minLength: Size.size200)
                Text(R.string.localizable.appName())
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.accentColor)
                    .padding(.bottom, Constraint.constraint48)
                
                Button {
                    socialSignIn(provider: .google)
                } label: {
                    Image(R.image.google.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                
                Button {
                    socialSignIn(provider: .apple)
                } label: {
                    Image(R.image.apple.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                
                Spacer()
            }
            .padding(.horizontal, Constraint.constraint48)
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
    
    private func socialSignIn(provider: AuthProvider) {
        Task {
            do {
                isLoading = true
                try await viewModel.socialSigIn(provider: provider)
                isSignIn = true
                isLoading = false
            } catch {
                errorMessage = errorMessage(error: error)
                isShowAlert = true
                isLoading = false
            }
        }
    }
    
    private func errorMessage(error: Error) -> String {
        switch error {
        case DomainError.authError :
            return R.string.localizable.signInErrorMessage()
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
    SignInView()
}
