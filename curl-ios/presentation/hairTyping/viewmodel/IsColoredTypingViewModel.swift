//
//  IsColoredTypingViewModel.swift
//  curl-ios
//
//  Created by Nabineenik on 19.10.2026.
//

import SwiftUI

@MainActor
final class IsColoredTypingViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            topic: "У вас окрашенные волосы? :)",
            answers: [
                Answer(result: ColoredTypes.colored.rawValue, text: "Да", isSelected: true),
                Answer(result: ColoredTypes.notColored.rawValue, text: "Нет", isSelected: false)
            ]
        )
    ]
    
    @Published var currentQuestionId: Int = 0
    @Published var result: String? = nil
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSavedSuccess = false
    
    var currentQuestion: Question { questions[currentQuestionId] }
    
    func selectAnswer(at index: Int) {
        for i in 0..<currentQuestion.answers.count {
            questions[currentQuestionId].answers[i].isSelected = (i == index)
        }
    }
    
    func calculateResult() {
        // Логика из Android (считаем количество вхождений символов)
        let resultString = questions.compactMap { $0.answers.first(where: { $0.isSelected })?.result }.joined()
        let coloredCount = resultString.filter { $0 == Character(ColoredTypes.colored.rawValue) }.count
        let notColoredCount = resultString.filter { $0 == Character(ColoredTypes.notColored.rawValue) }.count
        
        result = coloredCount >= notColoredCount ? ColoredTypes.colored.resultName : ColoredTypes.notColored.resultName
    }
    
    func saveResult(userId: String) async {
        // TODO: Заменить на реальный вызов API (hairTypesRepository.updateHairType)
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация сети
            // Пример того, что вы отправите:
            // let isColored = result == ColoredTypes.colored.resultName
            // let request = HairTypeRequest(userId: userId, isColored: isColored)
            
            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка, не удалось сохранить"
        }
        showAlert = true
    }
}
