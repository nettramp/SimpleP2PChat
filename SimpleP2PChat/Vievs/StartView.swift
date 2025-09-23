import SwiftUI
import Combine

struct StartView: View {
    @StateObject private var chatManager = ChatManager()
    @State private var showingQRCode = false
    @State private var showingScanner = false
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: "message.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Simple P2P Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Общайтесь напрямую между устройствами")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Кнопка "Создать чат" (показать QR-код)
                    Button(action: {
                        chatManager.startHosting()
                        showingQRCode = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Создать чат")
                        }
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    
                    // Кнопка "Присоединиться" (сканировать QR-код)
                    Button(action: {
                        chatManager.startJoining()
                        showingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Присоединиться к чату")
                        }
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingQRCode) {
                QRCodeView(chatManager: chatManager, isPresented: $showingQRCode)
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(chatManager: chatManager, isPresented: $showingScanner)
            }
            .fullScreenCover(isPresented: $showingChat) {
                ChatView(chatManager: chatManager)
            }
            .onChange(of: chatManager.isConnected) { connected in
                if connected {
                    showingChat = true
                    showingQRCode = false
                    showingScanner = false
                }
            }
        }
    }
}
