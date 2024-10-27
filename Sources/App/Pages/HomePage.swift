import Elementary
import HummingbirdFluent

struct HomePage: HTML {
	let fluent: Fluent

	var content: some HTML {
		AsyncContent {
			let channels = try await Stat.query(on: fluent.db()).all()

			let channelCounts: [String: Int] = channels.reduce(into: [:]) { partialResult, stat in
				guard let channel = stat.channel else { return }

				if !partialResult.keys.contains(channel) {
					partialResult[channel] = 0
				}

				partialResult[channel]! += 1
			}

			h1 { "Hello there" }

			ul {
				for (channel, count) in channelCounts {
					li {
						a(.href("/channel/\(channel)")) {
							channel
						}
						": \(count)"
					}
				}
			}
		}
	}
}
