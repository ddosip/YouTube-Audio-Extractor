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
            
            let _ = shell("/usr/local/bin/youtube-dl", "-i", "--extract-audio", "--audio-format", "mp3", "--audio-quality", "0", "-o", "/root/YouTubeFiles/%(title)s-%(id)s.%(ext)s", validURL.absoluteString)
            
            var youTubePath = FileManager.default.homeDirectory(forUser: "root")!
            youTubePath.appendPathComponent("YouTubeFiles/")
            
            let fileList = try! FileManager.default.contentsOfDirectory(atPath: youTubePath.path)
            
            for file in fileList {
                try! FileManager.default.removeItem(atPath: file)
            }
            
            let needFileUrl = youTubePath.appendingPathComponent(fileList.first!)
            let data = try! Data(contentsOf: needFileUrl)
            let audioParams = Bot.SendAudioParams(chatId: ChatId.chat(message.chat.id), audio: FileInfo.file(InputFile(data: data, filename: fileList.first!)) )
            try! bot.sendAudio(params: audioParams)
        }
        
        let dispatcher = Dispatcher(bot: bot)
        dispatcher.add(handler: linkhandler)
        
        _ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    }
}

YouTubeBot.start()
