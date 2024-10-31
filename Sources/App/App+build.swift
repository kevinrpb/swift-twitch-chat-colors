import ArgumentParser
import FluentSQLiteDriver
import Hummingbird
import HummingbirdElementary
import HummingbirdFluent
import Logging

protocol AppArguments: Sendable {
	var channels: [String] { get }
	var hostname: String { get }
	var port: Int { get }
	var dbPath: String { get }
	var dbMemory: Bool { get }
}

typealias AppRequestContext = BasicRequestContext

extension App {
	static func buildApp(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
		var logger = Logger(label: "twitch-chat-colors")
		logger.logLevel = .debug

		// Fluent
		let fluent = Fluent(logger: logger)
		#if DEBUG
			fluent.databases.use(.sqlite(.memory), as: .sqlite)
		#else
			if arguments.dbMemory {
				fluent.databases.use(.sqlite(.memory), as: .sqlite)
			} else {
				fluent.databases.use(.sqlite(.file(arguments.dbPath)), as: .sqlite)
			}
		#endif

		await fluent.migrations.add(CreateStat())
		try await fluent.migrate()

		// Twitch
		let twitch = TwitchService(channels: arguments.channels, fluent: fluent, logger: logger)

		// Router
		let router = buildRouter(arguments, fluent: fluent)

		// App
		var app = Application(
			router: router,
			configuration: .init(address: .hostname(arguments.hostname, port: arguments.port)),
			onServerRunning: { _ in
				print("Server running on http://\(arguments.hostname):\(arguments.port)/")
				#if DEBUG
					browserSyncReload()
				#endif
			},
			logger: logger
		)

		app.addServices(fluent, twitch)

		return app
	}
}

extension App {
	static func buildRouter(_ arguments: some AppArguments, fluent: Fluent) -> Router<
		AppRequestContext
	> {
		let router = Router()

		router.addMiddleware {
			LogRequestsMiddleware(.info)
		}

		router.get("") { _, _ in
			HTMLResponse {
				MainLayout(title: "Twitch Chat Colors") {
					HomePage(fluent: fluent)
				}
			}
		}

		router.group("channel")
			.get(":channel") { request, context in
				guard let channel = context.parameters.get("channel") else {
					throw HTTPError(.badRequest)
				}

				return HTMLResponse {
					MainLayout(title: "\(channel) stats") {
						ChannelPage(channel: channel, fluent: fluent)
					}
				}
			}

		router.get("raw") { _, _ in
			try await Stat.query(on: fluent.db()).all()
		}

		return router
	}
}
