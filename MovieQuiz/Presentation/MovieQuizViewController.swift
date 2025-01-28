import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertPresented = AlertPresenter()
    private var staticServise: StatisticServiceProtocol?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresented.delegate = self
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        imageView.layer.cornerRadius = 20
        questionFactory.loadData()
        staticServise = StatisticServiceImplementation()
        showIndicator()
        setupFonts()
    }
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    private func setupFonts() {
       questionLabel.font = UIFont(name: "YSDisplay-Medium", size : 20)
       noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
       yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
       textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
       indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
    }
    
    private func showNetworkError(message: String) {
        //        showLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresented.showAlert(model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(resource: .ypGreen).cgColor : UIColor(resource: .ypRed).cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        changeStateButton(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            changeStateButton(isEnabled: true)
            showIndicator()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        indexLabel.text = step.questionNumber
        
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text , preferredStyle: .alert)
        let tryButton = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
        }
        alert.addAction(tryButton)
        alert.preferredAction = tryButton
        present(alert, animated: true)
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        hideIndicator()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // showAlert()
            guard let statisticService = staticServise else {
                return
            }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов:  \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let viewModel = AlertModel(title: "Этот раунд окончен",
                                       message: text,
                                       buttonText: "Сыграть еще раз") { [weak self]  in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                showIndicator()
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresented.showAlert(model: viewModel)
        } else {
            showIndicator()
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        hideIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
}
