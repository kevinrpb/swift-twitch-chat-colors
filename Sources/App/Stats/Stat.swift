import FluentKit
import Foundation
import TwitchIRC

final class Stat: Model, @unchecked Sendable {
	static let schema = "stats"

	@ID(key: .id)
	var id: UUID?
	@Timestamp(key: "timestamp", on: .create)
	var timestamp: Date?
	@Field(key: "channel")
	var channel: String?
	@Field(key: "userID")
	var userID: String?
	@Field(key: "displayName")
	var displayName: String?
	@Field(key: "displayColor")
	var displayColor: String?

	init() {}

	init(
		id: UUID?,
		timestamp: Date,
		channel: String,
		userID: String,
		displayName: String,
		displayColor: String
	) {
		self.id = id
		self.timestamp = timestamp
		self.channel = channel
		self.userID = userID
		self.displayName = displayName
		self.displayColor = displayColor
	}
}

extension Stat {
	static func from(privateMessage: PrivateMessage) -> Self {
		.init(
			id: .init(),
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
		let timestamp = timestamp?.ISO8601Format() ?? ""
		let channel = channel ?? ""
		let userID = userID ?? ""
		let displayName = displayName ?? ""
		let displayColor = displayColor ?? ""

		return
			#"Stat { "timestamp": "\#(timestamp)", "channel": "\#(channel)", "userID": "\#(userID)", "displayName": "\#(displayName)", "displayColor": "\#(displayColor)" }"#
	}
}

struct CreateStat: AsyncMigration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) async throws {
        try await database.schema(Stat.schema)
            .id()
            .field("timestamp", .date)
            .field("channel", .string)
            .field("userID", .string)
            .field("displayName", .string)
            .field("displayColor", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("galaxies").delete()
    }
}
