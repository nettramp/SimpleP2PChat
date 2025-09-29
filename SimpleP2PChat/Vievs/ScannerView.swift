import SwiftUI
import AVFoundation
import Combine

struct ScannerView: View {
    let chatManager: ChatManager
    @Binding var isPresented: Bool
    @State private var torchOn = false
    
    var body: some View {
        ZStack {
            // Камера будет здесь
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { torchOn.toggle() }) {
                        Image(systemName: torchOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Наведите на QR-код друга")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .stroke(Color.green, lineWidth: 4)
                        .frame(width: 200, height: 200)
                        .cornerRadius(12)
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Сканирование")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Отмена") {
                    chatManager.stopJoining()
                    isPresented = false
                }
                .foregroundColor(.white)
            }
        }
    }
}
