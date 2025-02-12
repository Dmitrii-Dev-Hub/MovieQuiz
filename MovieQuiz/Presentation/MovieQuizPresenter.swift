import Foundation
import UIKit

final class MovieQuizPresenter {
    
    
    var alertPresented = AlertPresenter()
    var questionFactory: QuestionFactory?
    let questionsAmount: Int = 10
    var correctAnswers: Int = .zero
    var currentQuestion: QuizQuestion?
    var staticServise: StatisticServiceProtocol?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
    
    
    func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        viewController?.show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.hideIndicator()
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let statisticService = staticServise else {
                self.switchToNextQuestion()
                return
            }
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\nКоличество сыгранных квизов:  \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let viewModel = AlertModel(title: "Этот раунд окончен!",
                                       message: text,
                                       buttonText: "Сыграть еще раз") { [weak self]  in
                guard let self else { return }
                self.correctAnswers = 0
                self.resetQuestionIndex()
                viewController?.showIndicator()
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresented.showAlert(model: viewModel)
        } else {
            viewController?.showIndicator()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
    }
    
    
    // ...
}

