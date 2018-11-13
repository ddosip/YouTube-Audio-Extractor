import Telegrammer
import Foundation

// youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 -o "~/YouTubeFiles/%(title)s-%(id)s.%(ext)s" https://www.youtube.com/watch\?v\=IWTvgZVWeB4

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
    guard let message = update.message, let messageText = update.message?.text else { return }
    
    guard let validURL = URL(string: messageText) else { try! message.reply(text: "Кажеться, ты прислал мне не ссылку на YouTube!", from: bot); return }
    
    let youtubedlCommand = "youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 -o \"~/YouTubeFiles/%(title)s-%(id)s.%(ext)s\" \(validURL)"
    
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = [youtubedlCommand]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
    try! message.reply(text: "\(output!)", from: bot)
}

let dispatcher = Dispatcher(bot: bot)
dispatcher.add(handler: linkhandler)

_ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()

