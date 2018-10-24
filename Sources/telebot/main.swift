import Telegrammer
import Foundation

// youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 https://www.youtube.com/watch\?v\=IWTvgZVWeB4

guard
    let path = Bundle.main.path(forResource: "Token", ofType: "plist"),
    let dict = NSDictionary(contentsOfFile: path),
    let TELEGRAM_BOT_TOKEN = dict["TELEGRAM_BOT_TOKEN"] as? String else { exit(1) }


let bot = try! Bot(token: TELEGRAM_BOT_TOKEN)


fileprivate func validateUrl(url: String) -> Bool {
    if let _ = URL(string: url) { return true } else { return false }
}

@discardableResult
func shell(_ args: String...) -> String {
    let task = Process()
    task.launchPath = "/bin/bash/"
    task.arguments = args
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output: String = String(data: data, encoding: .utf8) else { return "Что-то пошло не так" }
    return output
}


let youtubeLinkhandler = MessageHandler { (update, _) in
    guard let message = update.message, let videoURL = update.message?.text else { return }
    //guard validateUrl(url: videoURL) else { return }
    
    let shellResponce = shell(videoURL)
    
    try! message.reply(text: shellResponce, from: bot)
}

let dispatcher = Dispatcher(bot: bot)
dispatcher.add(handler: youtubeLinkhandler)

_ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()

