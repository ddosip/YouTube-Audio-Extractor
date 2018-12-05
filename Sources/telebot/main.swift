import Foundation
import Telegrammer

// s
class YouTubeAudioExtractor {
    
    // MARK: Typealias
    typealias Token = String
    
    // MARK: Properties
    private let bot: Bot
    
    // MARK: Init
    init?() {
        guard
            let path = Bundle.main.path(forResource: "Token", ofType: "plist") else { return nil }
        guard
            let dict = NSDictionary(contentsOfFile: path),
            let token = dict["TELEGRAM_BOT_TOKEN"] as? String else { return nil }
        
        self.bot = try! Bot(token: token)
    }
    
    // MARK: Private functions
    @discardableResult
    fileprivate func executeShell(_ args: String..., completion: () -> () ) -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: String.Encoding.utf8)
        completion()
        return out
    }
    
    fileprivate func validateYoutubeLinks(urls youtubeURLs: [String]) -> [(url: String, isValid: Bool)]? {
        guard !youtubeURLs.isEmpty else { return nil }
        var resultTuple: [(url: String, isValid: Bool)]?
        resultTuple = youtubeURLs.map { (url: $0, isValid: validate(url: $0)) }
        return resultTuple
    }
    
    fileprivate func validate(url: String) -> Bool {
        let pattern = "(?:(?:.be/|embed/|v/|\\?v=|&v=|/videos/)|(?:[\\w+]+#\\w/\\w(?:/[\\w]+)?/\\w/))([\\w-_]+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        return regex?.firstMatch(in: url, options: [], range: NSMakeRange(0, url.count)) != nil
    }
    
    fileprivate func createDirectoriesIfNeeded(for userName: String) -> URL? {
        let fileManager = FileManager.default
        if #available(OSX 10.12, *) {
            let rootPath = fileManager.homeDirectoryForCurrentUser
            let youtubeDirectoryPath = rootPath.appendingPathComponent("YouTubeFiles")
            try? fileManager.createDirectory(atPath: youtubeDirectoryPath.path, withIntermediateDirectories: true, attributes: nil)
            guard fileManager.fileExists(atPath: youtubeDirectoryPath.path) else { return nil }
            
            let endpointUrl = youtubeDirectoryPath.appendingPathComponent(userName)
            try? fileManager.createDirectory(at: endpointUrl, withIntermediateDirectories: true, attributes: nil)
            guard fileManager.fileExists(atPath: endpointUrl.path) else { return nil }
            
            if let files = try? fileManager.contentsOfDirectory(atPath: endpointUrl.path) {
                for file in files {
                    try? fileManager.removeItem(atPath: endpointUrl.appendingPathComponent(file).path)
                }
            }
            return endpointUrl
        } else {
            return nil
        }
    }
    
    // MARK: Start
    func start() {
        let linkHandler = MessageHandler { [unowned self] (update, _) in
            guard let message = update.message, let messageText = update.message?.text, let username = message.from?.username else { return }
            
            let results = self.validateYoutubeLinks(urls: [messageText])
            guard let youtubeLink = results?.first, youtubeLink.isValid else {
                try! message.reply(text: "Кажеться, ты прислал мне не ссылку на YouTube.", from: self.bot)
                return
            }
            
            guard let endpointUrl = self.createDirectoriesIfNeeded(for: username) else {
                try! message.reply(text: "Не удалось выделить для тебя место :(", from: self.bot)
                return
            }
            
            self.executeShell(
                "/usr/local/bin/youtube-dl",
                "-i",
                "--extract-audio",
                "--audio-format", "mp3",
                "--audio-quality", "0",
                "-o", "/root/YouTubeFiles/\(username)/%(title)s-%(id)s.%(ext)s", youtubeLink.url,
                completion: { [unowned self] in
                    let fileManager = FileManager.default
                    guard
                        let files = try? fileManager.contentsOfDirectory(atPath: endpointUrl.path),
                        let needFilePath = files.first
                        else {
                            try! message.reply(text: "Не удалось найти сконвертированный файл :(", from: self.bot)
                            return
                    }

                    let needFileUrl = URL(fileURLWithPath: endpointUrl.appendingPathComponent(needFilePath).path)
                    var fileSize: String? = nil
                    if let fileAttributes = try? fileManager.attributesOfItem(atPath: needFileUrl.path),
                        let size = fileAttributes[.size] as? NSNumber,
                        let sizeInt64 = Int64(exactly: size) {
                        let byteCountFormatter = ByteCountFormatter()
                        byteCountFormatter.allowedUnits = [.useMB]
                        byteCountFormatter.countStyle = .file
                        fileSize = "\(byteCountFormatter.string(fromByteCount: sizeInt64))"
                    }
                    
                    
                    if let data = try? Data(contentsOf: needFileUrl) {
                        let audioParams =
                            Bot.SendAudioParams(
                                chatId: ChatId.chat(message.chat.id),
                                audio: FileInfo.file(InputFile(data: data, filename: needFilePath)),
                                caption: fileSize)
                        try! self.bot.sendAudio(params: audioParams)
                    } else {
                        try! message.reply(text: "Что-то пошло не так((", from: self.bot)
                    }
                }
            )
        }
        
        let dispatcher = Dispatcher(bot: bot)
        dispatcher.add(handler: linkHandler)
        
        _ = try! Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    }
}

guard let audioExtractor = YouTubeAudioExtractor() else { exit(1) }
audioExtractor.start()
