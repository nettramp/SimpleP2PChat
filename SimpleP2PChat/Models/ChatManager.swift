import Foundation
import MultipeerConnectivity
import SwiftUI
import Combine

class ChatManager: NSObject, ObservableObject {
    private let serviceType = "simplechat"
    private var myPeerId: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    @Published var messages: [Message] = []
    @Published var isConnected = false
    @Published var connectedPeerName = ""
    
    override init() {
        // Используем имя устройства как идентификатор
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    // Старт ожидания подключения (показ QR-кода)
    func startHosting() {
        advertiser.startAdvertisingPeer()
        print("Ожидаем подключения...")
    }
    
    // Остановка ожидания
    func stopHosting() {
        advertiser.stopAdvertisingPeer()
    }
    
    // Поиск устройств для подключения
    func startJoining() {
        browser.startBrowsingForPeers()
        print("Ищем устройства...")
    }
    
    // Остановка поиска
    func stopJoining() {
        browser.stopBrowsingForPeers()
    }
    
    // Отправка сообщения
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Создаем сообщение для себя
        let myMessage = Message(text: text, isFromMe: true)
        messages.append(myMessage)
        
        // Отправляем другому устройству
        if let data = text.data(using: .utf8), !session.connectedPeers.isEmpty {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Ошибка отправки: \(error)")
            }
        }
    }
    
    // Генерация QR-кода с именем устройства
    func generateQRCode() -> UIImage? {
        let qrString = "simplechat:\(myPeerId.displayName)"
        
        guard let data = qrString.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        // Увеличиваем размер QR-кода
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - MCSessionDelegate
extension ChatManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectedPeerName = peerID.displayName
                print("Подключено к: \(peerID.displayName)")
            case .notConnected:
                self.isConnected = false
                self.connectedPeerName = ""
                print("Отключено от: \(peerID.displayName)")
            case .connecting:
                print("Подключаемся к: \(peerID.displayName)")
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                // Добавляем сообщение от друга
                let friendMessage = Message(text: text, isFromMe: false)
                self.messages.append(friendMessage)
            }
        }
    }
    
    // Эти методы не используем, но они обязательны
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}


extension ChatManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Автоматически принимаем приглашение
        invitationHandler(true, session)
    }
}


extension ChatManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Автоматически подключаемся к найденному устройству
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Устройство потеряно: \(peerID.displayName)")
    }
}
