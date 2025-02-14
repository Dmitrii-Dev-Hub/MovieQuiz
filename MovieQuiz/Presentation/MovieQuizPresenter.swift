import Foundation
import UIKit

final class MovieQuizPresenter {
    
    // MARK: Private Properties
    
    var alertPresented = AlertPresenter()
    var questionFactory: QuestionFactory?
    let questionsAmount: Int = 10
    var correctAnswers: Int = .zero
    var currentQuestion: QuizQuestion?
    var staticServise: StatisticServiceProtocol?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
           self.viewController = viewController
           self.staticServise = StatisticServiceImplementation()
           self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
           self.questionFactory?.loadData()
           viewController.showIndicator()
       }
    // MARK: Public Method
    
    func yesButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
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
    
    func someFunc(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: isCorrect)
        viewController?.changeStateButton(isEnabled: false)
        viewController?.showIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.changeStateButton(isEnabled: true)
            viewController?.defaultImage()
            showNextQuestionOrResults()
        }
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
    
    // MARK: Private Functions
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        someFunc(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNetworkError(message: String) {
        // showLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            resetQuestionIndex()
            correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
            
        }
        alertPresented.showAlert(model: model)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideIndicator()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
