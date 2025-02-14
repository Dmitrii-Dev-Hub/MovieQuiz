import XCTest
@testable import MovieQuiz

class ArreyTest: XCTestCase {
    func testGetValueInRange() throws {
        
        // Givet
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
    }
    
    func testGetValueOutOfRange2() throws {
        
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}

