import Foundation
import TwitchIRC

struct Stat: Codable, Sendable {
	let timestamp: Date
	let channel: String
	let userID: String
	let displayName: String
	let displayColor: String?
}

extension Stat {
	init(privateMessage: PrivateMessage) {
		self.init(
			timestamp: .now,
			channel: privateMessage.channel,
			userID: privateMessage.userId,
			displayName: privateMessage.displayName,
			displayColor: privateMessage.color
		)
	}
}

extension Stat: CustomStringConvertible {
	var description: String {
		#"Stat { "timestamp": "\#(timestamp.ISO8601Format())", "channel": "\#(channel)", "userID": "\#(userID)", "displayName": "\#(displayName)", "displayColor": "\#(displayColor ?? "none")" }"#
	}
}
