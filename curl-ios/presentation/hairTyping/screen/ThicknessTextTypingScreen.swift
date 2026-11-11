import SwiftUI

struct ThicknessTextTypingScreen: View {
    let onBackToHome: () -> Void

    @StateObject private var viewModel = ThicknessTypingViewModel()

    var body: some View {
        ZStack {
            Color(hex: "F8F4ED").ignoresSafeArea()

            if viewModel.result == nil {
                questionView
            } else {
                TypingResultView(
                    resultTitle: viewModel.result?.resultName ?? "",
                    onSave: { Task { await viewModel.saveResult() } },
                    onSkip: { onBackToHome() }
                )
            }
        }
        .navigationTitle("Типизация волос")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Результат", isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.isSavedSuccess { onBackToHome() }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "EDE9E1"))
                            .frame(height: 4)

                        Capsule()
                            .fill(Color(hex: "728C6A"))
                            .frame(width: geo.size.width * viewModel.progress, height: 4)
                            .animation(.easeInOut, value: viewModel.progress)
                    }
                }
                .frame(height: 4)

                Text("\(viewModel.currentQuestionId + 1)/\(viewModel.questions.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48"))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            if viewModel.currentQuestionId < viewModel.questions.count {
                let question = viewModel.questions[viewModel.currentQuestionId]

                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(viewModel.currentQuestionId + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "728C6A"))
                            .frame(width: 28, height: 28)
                            .background(Color(hex: "F8F4ED"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hex: "728C6A").opacity(0.3), lineWidth: 1))

                        Text(question.topic)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "4A5B48"))
                            .lineSpacing(4)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(24)

                    VStack(spacing: 10) {
                        ForEach(question.answers.indices, id: \.self) { index in
                            let answer = question.answers[index]
                            let isSelected = question.selectedIndex == index

                            Button {
                                viewModel.selectAnswer(at: index)
                            } label: {
                                HStack(spacing: 16) {
                                    Circle()
                                        .stroke(isSelected ? Color(hex: "728C6A") : Color(hex: "4A5B48").opacity(0.2), lineWidth: 1)
                                        .background(Circle().fill(isSelected ? Color(hex: "728C6A") : Color.clear))
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle().fill(Color.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0)
                                        )

                                    Text(answer.text)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(hex: "4A5B48"))
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(20)
                                .background(isSelected ? Color(hex: "F8F4ED") : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? Color(hex: "728C6A").opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button("Назад") {
                            viewModel.previousQuestion()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(viewModel.currentQuestionId == 0)
                        .opacity(viewModel.currentQuestionId == 0 ? 0.5 : 1)

                        Button(viewModel.currentQuestionId + 1 == viewModel.questions.count ? "Результат" : "Далее") {
                            viewModel.nextQuestion()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(question.selectedIndex == nil)
                        .opacity(question.selectedIndex == nil ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
