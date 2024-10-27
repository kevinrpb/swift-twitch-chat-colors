import Foundation

actor StatsManager {
	struct Stat: Codable, Sendable {
		let timestamp: Date
		let userID: String
		let displayName: String
		let displayColor: String?
	}

	static let shared: StatsManager = .init()

	private(set) var stats: [Stat] = []

	private init() {}

	func add(_ stat: Stat) async throws {
		stats.append(stat)
	}
}
