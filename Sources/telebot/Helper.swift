import Foundation

// MARK: Typealias
typealias Token = String

// MARK: Classes

// Telebot custom errors
enum TBError: Error {
    case TokenPlistNotFound(code: Int, text: String)
    case TokenParse(code: Int, text: String)
}


// MARK: Functions

func getToken() throws -> Token {
    guard
        let path = Bundle.main.path(forResource: "Token", ofType: "plist")
        else {
            throw TBError.TokenPlistNotFound(code: 1, text: "Token.plist not found")
    }
    guard
        let dict = NSDictionary(contentsOfFile: path),
        let token = dict["TELEGRAM_BOT_TOKEN"] as? String else { throw TBError.TokenParse(code: 2, text: "Invalid Token.plist") }
    
    return token
    
}
