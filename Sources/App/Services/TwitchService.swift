import Logging
import ServiceLifecycle
import Twitch

struct TwitchService: Service {
	let channel: String
	let logger: Logger

	func run() async throws {
		let client = try await TwitchIRCClient(.anonymous)
		let (stream, continuation) = await client.stream()

		try await withGracefulShutdownHandler {
			try await client.join(to: channel)

			for try await message in stream {
				switch message {
				case let .privateMessage(privateMessage):
					logger.info(
						"Private message from <\(privateMessage.displayName)> with color <\(privateMessage.color)>"
					)
					try? await StatsManager.shared.add(
						.init(
							timestamp: .now, userID: privateMessage.userId,
							displayName: privateMessage.displayName,
							displayColor: privateMessage.color)
					)
				default:
					logger.info("Skipping message: \(message)")
				}
			}
		} onGracefulShutdown: {
			continuation.finish()
		}
	}
}
