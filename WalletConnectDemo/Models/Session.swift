import Foundation

struct Session: Codable, Equatable {
    let topic: String
    let pairingTopic: String
    let expiryDate: Date

    init(topic: String, pairingTopic: String, expiryDate: Date) {
        self.topic = topic
        self.pairingTopic = pairingTopic
        self.expiryDate = expiryDate
    }
}
