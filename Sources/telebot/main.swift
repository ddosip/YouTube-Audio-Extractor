import Telegrammer
import Foundation

// youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 https://www.youtube.com/watch\?v\=IWTvgZVWeB4

var token: Token = ""

do {
    token = try getToken()
} catch TBError.TokenPlistNotFound(let code, let text) {
    print(text)
    exit(Int32(code))
} catch TBError.TokenParse(let code, let text) {
    print(text)
    exit(Int32(code))
}

let bot = try! Bot(token: token)

let linkhandler = MessageHandler { (update, _) in
    guard let message = update.message, let user = message.from else { return }
    
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["pwd"]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
    print(output!)
    
    try! message.reply(text: "\(output!)", from: bot)
}

let dispatcher = Dispatcher(bot: bot)
dispatcher.add(handler: linkhandler)

_ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()

