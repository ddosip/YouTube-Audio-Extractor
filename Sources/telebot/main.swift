import Foundation
import Telegrammer

//youtube-dl -i --extract-audio --audio-format mp3 --audio-quality 0 -o "~/YouTubeFiles/%(title)s-%(id)s.%(ext)s" https://www.youtube.com/watch?v=IWTvgZVWeB4

class YouTubeBot {
    static func start() {
        var token: Token = ""
        
        do {
            token = try Helper.getToken()
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
            
            // 1. Проверить что messageText валидная ссылка на YouTube
            let results = Helper.isValidYoutubeLinks(urls: [messageText])
            guard let result = results?.first, !result.isValid else {
                try! message.reply(text: "Кажеться, ты прислал мне не ссылку на YouTube.", from: bot)
                return
            }

            try! message.reply(text: "Это ссылка на YouTube", from: bot)
            
            // 2. В папке /root/YouTubeFiles/ создать подпапку с именем пользователя
            
            
            // 3. Удалить все файлы в папке шага 3
            // 4. Запустить shell
            // 5. Конвертировать полученный файл в data
            // 6. Послать сообщение с файлом
            
            
//            var youTubePath = FileManager.default.homeDirectory(forUser: "root")!
//            youTubePath.appendPathComponent("YouTubeFiles/")
//
//            let fileList = try! FileManager.default.contentsOfDirectory(atPath: youTubePath.path)
//            for file in fileList {
//                try! FileManager.default.removeItem(atPath: youTubePath.appendingPathComponent(file).path)
//            }
//
//            let _ = Helper.shell("/usr/local/bin/youtube-dl", "-i", "--extract-audio", "--audio-format", "mp3", "--audio-quality", "0", "-o", "/root/YouTubeFiles/%(title)s-%(id)s.%(ext)s", validURL.absoluteString)
//
//
//            let needFileUrl = youTubePath.appendingPathComponent(fileList.first!)
//            if let data = try? Data(contentsOf: needFileUrl) {
//                let audioParams = Bot.SendAudioParams(chatId: ChatId.chat(message.chat.id), audio: FileInfo.file(InputFile(data: data, filename: fileList.first!)) )
//                try! bot.sendAudio(params: audioParams)
//            } else {
//                try! message.reply(text: "Что-то пошло не так((", from: bot)
//            }
        }
        
        let dispatcher = Dispatcher(bot: bot)
        dispatcher.add(handler: linkhandler)
        
        _ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    }
}

YouTubeBot.start()

let testLinks = ["http://www.youtube.com/watch?v=iwGFalTRHDA",
                 "http://www.youtube.com/watch?v=iwGFalTRHDA&feature=related",
                 "http://youtu.be/iwGFalTRHDA",
                 "http://youtu.be/n17B_uFF4cA",
                 "http://www.youtube.com/embed/watch?feature=player_embedded&v=r5nB9u4jjy4",
                 "http://www.youtube.com/watch?v=t-ZRX8984sc",
                 "http://youtu.be/t-ZRX8984sc",
                 "https://www.youtube.com/watch?v=DDgekKQ8nLc",
                 "https://www.youtube.com/watch?v=GurkREc-q4I",
                 "https://www.youtube.com/watch?v=j-qQ_brIsfY",
                 "https://www.youtube.com/watch?v=03X0B6u-AxM",
                 "https://www.youtube.com/watch?v=4ZqWLIQaKM4",
                 "https://www.youtube.com/watch?v=D3sg1sDhX0U",
                 "https://www.youtube.com/watch?v=zfTz83yQ8hU",
                 "https://www.youtube.com/watch?v=azeh1ZbxWwI",
                 "https://www.youtube.com/watch?v=DMjIYp-FwQA",
                 "хуй",
                 "https://github.com/rg3/youtube-dl"]
