import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func changeButtonState(isEnabled: Bool)
    
    func showAnswerResult(isCorrect: Bool)
    func changeStateButton(isEnabled: Bool)
    
    func showIndicator()
    func defaultImage()
    
    func hideIndicator()
}

