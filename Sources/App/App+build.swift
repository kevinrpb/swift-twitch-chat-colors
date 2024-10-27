import ArgumentParser
import Hummingbird
import HummingbirdElementary
import Logging

protocol AppArguments: Sendable {
	var hostname: String { get }
	var port: Int { get }
}

typealias AppRequestContext = BasicRequestContext

extension App {
	static func buildApp(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
		var logger = Logger(label: "twitch-chat-colors")
		logger.logLevel = .debug

		// Router
		let router = buildRouter(arguments)

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

		app.addServices(TwitchService(channel: "kevinrpb", logger: logger))

		return app
	}
}

extension App {
	static func buildRouter(_ arguments: some AppArguments) -> Router<
		AppRequestContext
	> {
		let router = Router()

		router.addMiddleware {
			LogRequestsMiddleware(.info)
		}

		router.get("") { _, _ in
			HTMLResponse {
				MainLayout(title: "Twitch Chat Colors") {
					HomePage()
				}
			}
		}

		return router
	}
}
