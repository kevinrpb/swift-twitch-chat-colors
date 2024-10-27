import ArgumentParser
import Hummingbird
import HummingbirdElementary
import Twitch

@main
struct App: AppArguments, AsyncParsableCommand {
	@Option(name: .shortAndLong)
	var hostname: String = "127.0.0.1"

	@Option(name: .shortAndLong)
	var port: Int = 8080

	func run() async throws {
		let app = try await Self.buildApp(self)

		try await withThrowingDiscardingTaskGroup { taskGroup in
			taskGroup.addTask {
				try await app.runService()
			}

			taskGroup.addTask {
				try await Self.setupTwitch(app)
			}
		}
	}
}