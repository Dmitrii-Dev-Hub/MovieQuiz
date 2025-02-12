import UIKit


final class AlertPresenter {
    weak var delegate: UIViewController?
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "alert"
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        action.accessibilityIdentifier = "alertAction"
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
        
    }
}
