import SwiftUI
import Combine

struct QRCodeView: View {
    let chatManager: ChatManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Попросите друга отсканировать QR-код")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let qrImage = chatManager.generateQRCode() {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()
                } else {
                    Text("Ошибка создания QR-кода")
                        .foregroundColor(.red)
                }
                
                Text("Ожидание подключения...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ProgressView()
                    .scaleEffect(1.5)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Мой QR-код")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        chatManager.stopHosting()
                        isPresented = false
                    }
                }
            }
        }
    }
}
