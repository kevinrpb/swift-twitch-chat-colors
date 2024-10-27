import Hummingbird
import Twitch

extension App {
	static func setupTwitch(_ app: some ApplicationProtocol) async throws {
		let client: TwitchIRCClient = try await .init(.anonymous)

		try await client.join(to: "kevinrpb")

		for try await message in await client.stream() {
			switch message {
			case let .privateMessage(privateMessage):
				app.logger.info(
					"Private message from <\(privateMessage.displayName)> with color <\(privateMessage.color)>"
				)
				try? await StatsManager.shared.add(
					.init(
						timestamp: .now, userID: privateMessage.userId,
						displayName: privateMessage.displayName, displayColor: privateMessage.color)
				)
			default:
				app.logger.info("Skipping message: \(message)")
			}
		}
	}
}
