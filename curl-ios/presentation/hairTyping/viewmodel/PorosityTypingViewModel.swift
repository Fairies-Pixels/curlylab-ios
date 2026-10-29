//
//  PorosityTypingViewModel.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//

import SwiftUI

@MainActor
final class PorosityTypingViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(topic: "Проведите пальцами по волоску от кончика к коже головы.", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Чувствую сопротивление", isSelected: true),
            Answer(result: "\(PorosityTypes.semiPorous.rawValue)\(PorosityTypes.nonPorous.rawValue)", text: "Не чувствую сопротивление", isSelected: false)
        ]),
        Question(topic: "Какие Ваши волосы наощупь и на вид?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Скользкие и гладкие, на вид –– блестящие, буквально отражающие свет", isSelected: true),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Гладкие и блестящие", isSelected: false),
            Answer(result: PorosityTypes.porous.rawValue, text: "На ощупь шершавые, визуально матовые, не блестят", isSelected: false)
        ]),
        Question(topic: "Хорошо ли Ваши волосы держат завиток?", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Да", isSelected: true),
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Нет", isSelected: false)
        ]),
        Question(topic: "Пушаться ли Ваши волосы?", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Да", isSelected: true),
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Нет", isSelected: false)
        ]),
        Question(topic: "Насколько хорошо Ваши волосы держат кудри и прикорневой объем?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Плохо, без дополнительных фиксирующих средств совсем не держат", isSelected: true),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Укладка может держаться несколько дней", isSelected: false),
            Answer(result: PorosityTypes.porous.rawValue, text: "Отлично держат форму, хороший прикорневой объем", isSelected: false)
        ]),
        Question(topic: "Как ведут себя Ваши волосы после мытья?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Во влажном состоянии могут виться, но после высыхания распрямляются", isSelected: true),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Пушаться и лохматяться", isSelected: false),
            Answer(result: PorosityTypes.porous.rawValue, text: "Если лечь спать с влажными волосами, на утро будет колтун и валенок", isSelected: false)
        ])
    ]
    
    @Published var currentQuestionId: Int = 0
    @Published var result: PorosityTypes? = nil
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSavedSuccess = false
    
    var currentQuestion: Question { questions[currentQuestionId] }
    
    func selectAnswer(at index: Int) {
        for i in 0..<currentQuestion.answers.count {
            questions[currentQuestionId].answers[i].isSelected = (i == index)
        }
    }
    
    func nextQuestion() {
        if currentQuestionId + 1 < questions.count {
            currentQuestionId += 1
        } else {
            calculateResult()
        }
    }
    
    func calculateResult() {
        let resultString = questions.compactMap { $0.answers.first(where: { $0.isSelected })?.result }.joined()
        
        let porous = resultString.filter { $0 == Character(PorosityTypes.porous.rawValue) }.count
        let semiPorous = resultString.filter { $0 == Character(PorosityTypes.semiPorous.rawValue) }.count
        let nonPorous = resultString.filter { $0 == Character(PorosityTypes.nonPorous.rawValue) }.count
        
        let maxVal = max(porous, semiPorous, nonPorous)
        
        if maxVal == porous {
            result = .porous
        } else if maxVal == semiPorous {
            result = .semiPorous
        } else {
            result = .nonPorous
        }
    }
    
    func saveResult(userId: String) async {
        // TODO: Заменить на реальный вызов API (hairTypesRepository.updateHairType)
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            // Пример: let request = HairTypeRequest(userId: userId, porosity: result?.dbCode)
            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка, не удалось сохранить"
        }
        showAlert = true
    }
}
