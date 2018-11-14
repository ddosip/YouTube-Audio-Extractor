import Foundation

// MARK: Typealias
typealias Token = String

// MARK: Classes

// Telebot custom errors
enum TBError: Error {
    case TokenPlistNotFound(code: Int, text: String)
    case TokenParse(code: Int, text: String)
}

// MARK: Helper
class Helper {
    static func getToken() throws -> Token {
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
    
    @discardableResult
    static func shell(_ args: String...) -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: String.Encoding.utf8)
        
        return out
    }
    
    static func isValidYoutubeLinks(urls youtubeURLs: [String]) -> [(url: String, isValid: Bool)]? {
        guard !youtubeURLs.isEmpty else { return nil }
        var resultTuple: [(url: String, isValid: Bool)]?
        resultTuple = youtubeURLs.map { (url: $0, isValid: validate(url: $0)) }
        return resultTuple
    }
    
    fileprivate static func validate(url: String) -> Bool {
        let pattern = "(?:(?:.be/|embed/|v/|\\?v=|&v=|/videos/)|(?:[\\w+]+#\\w/\\w(?:/[\\w]+)?/\\w/))([\\w-_]+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        return regex?.firstMatch(in: url, options: [], range: NSMakeRange(0, url.count)) != nil
    }
}


// MARK: Functions




