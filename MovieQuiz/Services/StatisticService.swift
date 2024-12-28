import Foundation
//
//final class StatisticService: StatisticServiceProtocol {
//    
//    private let storage: UserDefaults = .standard
//
//    private enum Keys: String {
//        case correct
//        case total
//        case date
//        case gamesCount
//        case bestGame
//    }
//    
//    var correct: Int {
//         get {
//             storage.integer(forKey: Keys.correct.rawValue)
//         }
//         set {
//             storage.set(newValue, forKey: Keys.correct.rawValue)
//         }
//     }
//
//    var bestGame: GameResult {
//        get {
//            let correct = storage.integer(forKey: Keys.correct.rawValue)
//            let total = storage.integer(forKey: Keys.total.rawValue)
//            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
//            return GameResult(correct: correct, total: total, date: date)
//        }
//        set {
//            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
//            storage.set(newValue.total, forKey: Keys.total.rawValue)
//            storage.set(newValue.date, forKey: Keys.date.rawValue)
//        }
//    }
//
//    var totalAccuracy: Int {
////        let correct = storage.integer(forKey: Keys.correct.rawValue)
////        let total = storage.integer(forKey: Keys.total.rawValue)
////        return total > 0 ? (Double(correct) / Double(total)) * 100 : 0
//        get {
//            storage.integer(forKey: Keys.total.rawValue)
//        }
//        set {
//            storage.set(newValue, forKey: Keys.total.rawValue)
//        }
//
//    }
//
//    var gamesCount: Int {
//        get {
//            storage.integer(forKey: Keys.gamesCount.rawValue)
//        }
//        set {
//            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
//        }
//    }
//
//    func store(correct count: Int, total amount: Int) {
////        // Обновляем общее количество правильных ответов и вопросов
////        let currentCorrect = storage.integer(forKey: Keys.correct.rawValue)
////        let currentTotal = storage.integer(forKey: Keys.total.rawValue)
////        storage.set(currentCorrect + count, forKey: Keys.correct.rawValue)
////        storage.set(currentTotal + amount, forKey: Keys.total.rawValue)
////
////        // Увеличиваем количество сыгранных игр
////        let currentGamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
////        storage.set(currentGamesCount + 1, forKey: Keys.gamesCount.rawValue)
////
////        // Проверяем, является ли текущий результат лучшим
////        let currentBestGame = bestGame
////        if count > currentBestGame.correct || (count == currentBestGame.correct && amount < currentBestGame.total) {
////            bestGame = GameResult(correct: count, total: amount, date: Date())
////        }
//        
//        
//        let newResult = GameResult(correct: count, total: amount, date: Date())
//             
//             gamesCount += 1
//             correct += count
//        totalAccuracy += amount
//        
////        private enum Keys: String {
////            case correct
////            case total
////            case date
////            case gamesCount
////            case bestGame
////        }
//             
//        let correct = storage.integer(forKey: Keys.correct.rawValue)
//        let total = storage.integer(forKey: Keys.total.rawValue)
//        let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
//             
//             let record = GameResult(correct: correct, total: total, date: date)
//             
//             if !record.isBetterThan(newResult) {
//                 bestGame = newResult
//             }
//    }
//}

private enum Keys: String {
    case correct
    case total
    case totalAccuracy
    case bestGame
    case bestGameCorrect
    case bestGameTotal
    case bestGameDate
    case gamesCount
}

final class StatisticServiceImplementation: StatisticServiceProtocol {
    
    
    let storage: UserDefaults = .standard
    
    var correct: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
var total: Int {
        get {
            storage.integer(forKey: Keys.total.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var totalAccuracy: Double {
          get {
              let total = Double(storage.integer(forKey: Keys.total.rawValue))
              let correct = Double(storage.integer(forKey: Keys.correct.rawValue))
              return total > 0 ? (correct/total) * 100 : 0
          }
      }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newResult = GameResult(correct: count, total: amount, date: Date())
        
        gamesCount += 1
        correct += count
        total += amount
        
        let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
        let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
        let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
        
        let record = GameResult(correct: correct, total: total, date: date)
        
        if !record.isBetterThan(newResult) {
            bestGame = newResult
        }
    }
    
}
