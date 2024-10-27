import HummingbirdFluent
import Logging
import ServiceLifecycle
import Twitch

struct TwitchService: Service {
	let channels: [String]
	let fluent: Fluent
	let logger: Logger

	func run() async throws {
		let client = try await TwitchIRCClient(.anonymous)
		let (stream, continuation) = await client.stream()

		try await withGracefulShutdownHandler {
			for channel in channels {
				try await client.join(to: channel)
			}

			for try await message in stream {
				switch message {
				case let .privateMessage(privateMessage):
					let stat = Stat.from(privateMessage: privateMessage)

					do {
						try await stat.save(on: fluent.db())
						logger.info("Saved: \(stat)")
					} catch {
						logger.error("Failed to save: \(stat)")
					}
				default:
					logger.info("Skipping message: \(message)")
				}
			}
		} onGracefulShutdown: {
			continuation.finish()
		}
	}
}
