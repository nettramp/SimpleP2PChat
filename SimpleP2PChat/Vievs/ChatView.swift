import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var chatManager: ChatManager
    @State private var messageText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Шапка с информацией о подключении
            HStack {
                VStack(alignment: .leading) {
                    Text("Чат с \(chatManager.connectedPeerName)")
                        .font(.headline)
                    Text(chatManager.isConnected ? "Подключено" : "Не подключено")
                        .font(.caption)
                        .foregroundColor(chatManager.isConnected ? .green : .red)
                }
                
                Spacer()
                
                Button("Выйти") {
                    chatManager.stopHosting()
                    chatManager.stopJoining()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Список сообщений
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(chatManager.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Панель ввода
            HStack {
                TextField("Введите сообщение...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                        .font(.title2)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        chatManager.sendMessage(messageText)
        messageText = ""
    }
}

// Пузырек сообщения
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
                messageContent
            } else {
                messageContent
                Spacer()
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 5) {
            Text(message.text)
                .padding()
                .background(message.isFromMe ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isFromMe ? .white : .primary)
                .cornerRadius(15)
            
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}
