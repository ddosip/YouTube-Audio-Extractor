import Foundation

// MARK: Typealias
typealias Token = String

// MARK: Classes

// Telebot custom errors
enum TBError: String, Error {
    case TokenPlistNotFound = "Token.plist notw found"
    case TokenParse = "Invalid Token.plist"
}


// MARK: Functions

func getToken() throws -> Token {
    guard
        let path = Bundle.main.path(forResource: "Token", ofType: "plist") else { throw TBError.TokenPlistNotFound }
    guard
        let dict = NSDictionary(contentsOfFile: path),
        let token = dict["TELEGRAM_BOT_TOKEN"] as? String else { throw TBError.TokenParse }
    
    return token
    
}
