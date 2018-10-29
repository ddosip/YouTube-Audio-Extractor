import Telegrammer
import Foundation

// youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 https://www.youtube.com/watch\?v\=IWTvgZVWeB4

guard let token = try? getToken() else { exit(1) }

let bot = try! Bot(token: token)

let commandHandler = CommandHandler(commands: ["/hello"], callback: { (update, _) in
    guard let message = update.message, let user = message.from else { return }
    try! message.reply(text: "Hello \(user.firstName)", from: bot)
})

let dispatcher = Dispatcher(bot: bot)
dispatcher.add(handler: commandHandler)

_ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()

