import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers: Int = .zero
    private var alertPresented = AlertPresenter()
    private var staticServise: StatisticServiceProtocol?
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresented.delegate = self
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        self.questionFactory = questionFactory
        questionFactory.loadData()
        staticServise = StatisticServiceImplementation()
        
        showIndicator()
        activityIndicator.hidesWhenStopped = true
        
        imageView.layer.cornerRadius = 20
        
        setupFonts()
        presenter.viewController = self
    }
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.yesButtonClicked(yesButton)
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.noButtonClicked(noButton)
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
        // showLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresented.showAlert(model: model)
    }
    
    func showAnswerResult(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(resource: .ypGreen).cgColor : UIColor(resource: .ypRed).cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        changeStateButton(isEnabled: false)
        showIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            changeStateButton(isEnabled: true)
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        hideIndicator()
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService = staticServise else {
                presenter.switchToNextQuestion()
                return
            }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов:  \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let viewModel = AlertModel(title: "Этот раунд окончен!",
                                       message: text,
                                       buttonText: "Сыграть еще раз") { [weak self]  in
                guard let self else { return }
                self.correctAnswers = 0
                self.presenter.resetQuestionIndex()
                showIndicator()
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresented.showAlert(model: viewModel)
        } else {
            showIndicator()
            presenter.switchToNextQuestion()
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
        activityIndicator.startAnimating()
    }
    
    func hideIndicator() {
        activityIndicator.stopAnimating()
    }
    
}
