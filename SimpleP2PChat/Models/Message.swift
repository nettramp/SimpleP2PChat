import Foundation

// Базавая модель сообщения
struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let isFromMe: Bool
    let timestamp: Date
    
    init(text: String, isFromMe: Bool) {
        self.id = UUID().uuidString
        self.text = text
        self.isFromMe = isFromMe
        self.timestamp = Date()
    }
}
