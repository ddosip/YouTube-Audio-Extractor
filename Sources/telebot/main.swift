import Foundation
import Telegrammer

//youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 -o "~/YouTubeFiles/%(title)s-%(id)s.%(ext)s" https://www.youtube.com/watch?v=IWTvgZVWeB4

class YouTubeBot {
    static func start() {
        var token: Token = ""
        
        do {
            token = try getToken()
        } catch TBError.TokenPlistNotFound(let code, let text) {
            print(text)
            exit(Int32(code))
        } catch TBError.TokenParse(let code, let text) {
            print(text)
            exit(Int32(code))
        } catch {
            exit(Int32(1))
        }
        
        let bot = try! Bot(token: token)
        
        let linkhandler = MessageHandler { (update, _) in
            guard let message = update.message, let messageText = update.message?.text else { return }
            
            guard let validURL = URL(string: messageText) else { try! message.reply(text: "Кажеться, ты прислал мне не ссылку на YouTube!", from: bot); return }
            
            shell("/usr/local/bin/youtube-dl", "-i", "--extract-audio", "--audio-format", "mp3", "--audio-quality", "0", "-o", "\"~/YouTubeFiles/%(title)s-%(id)s.%(ext)s\"", "https://www.youtube.com/watch?v=IWTvgZVWeB4")
            
        }
        
        let dispatcher = Dispatcher(bot: bot)
        dispatcher.add(handler: linkhandler)
        
        _ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    }
}


YouTubeBot.start()
