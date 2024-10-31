import ArgumentParser
import Hummingbird
import HummingbirdElementary
import Twitch

@main
struct App: AppArguments, AsyncParsableCommand {
	@Option(name: .shortAndLong)
	var channels: [String] = ["kevinrpb"]

	@Option(name: .shortAndLong)
	var hostname: String = "127.0.0.1"

	@Option(name: .shortAndLong)
	var port: Int = 8080

	@Option(name: .long)
	var dbPath: String = "./db.sqlite"

	@Flag(name: .long)
	var dbMemory: Bool = false

	func run() async throws {
		let app = try await Self.buildApp(self)
		try await app.runService()
	}
}
