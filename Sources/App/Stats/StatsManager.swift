import Foundation

actor StatsManager {
	static let shared: StatsManager = .init()

	private(set) var stats: [Stat] = []

	private init() {}

	func add(_ stat: Stat) async throws {
		stats.append(stat)
	}
}
