//
//  PorosityTypingScreen.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//

import SwiftUI

struct PorosityTypingScreen: View {
    @StateObject private var viewModel = PorosityTypingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let userId = "current-user-id"
    
    var body: some View {
        ZStack {
            Color.pink80.ignoresSafeArea()
            
            if let result = viewModel.result {
                TypingResultView(
                    resultTitle: result.resultName,
                    themeColor: .brightPink,
                    onSave: { Task { await viewModel.saveResult(userId: userId) } },
                    onSkip: { dismiss() }
                )
            } else {
                VStack(spacing: 20) {
                    Text("Тест на пористость")
                        .font(.title2.bold())
                        .foregroundStyle(Color.purpleGrey40)
                    
                    TypingProgressBar(
                        current: viewModel.currentQuestionId,
                        total: viewModel.questions.count,
                        color: .brightPink
                    )
                    
                    VStack(spacing: 30) {
                        Text(viewModel.currentQuestion.topic)
                            .font(.title3.bold())
                            .foregroundStyle(Color.purpleGrey40)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.currentQuestion.answers.enumerated()), id: \.offset) { index, answer in
                                Button {
                                    viewModel.selectAnswer(at: index)
                                } label: {
                                    Text(answer.text)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.lightBeige)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(answer.isSelected ? Color.brightPink : Color.purpleGrey40)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .background(Color.lightBeige)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    HStack {
                        Button("Предыдущий") {
                            if viewModel.currentQuestionId > 0 { viewModel.currentQuestionId -= 1 }
                        }
                        .foregroundStyle(viewModel.currentQuestionId == 0 ? .clear : .purpleGrey40)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.currentQuestionId == 0 ? .clear : .purpleGrey40, lineWidth: 2)
                        )
                        .disabled(viewModel.currentQuestionId == 0)
                        
                        Spacer()
                        
                        Button(viewModel.currentQuestionId + 1 == viewModel.questions.count ? "К результату" : "Следующий") {
                            viewModel.nextQuestion()
                        }
                        .padding()
                        .foregroundStyle(Color.lightBeige)
                        .background(Color.purpleGrey40)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.isSavedSuccess { dismiss() }
            }
        }
    }
}
