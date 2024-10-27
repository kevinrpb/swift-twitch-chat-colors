import Elementary
import HummingbirdFluent

struct ChannelPage: HTML {
	let channel: String
	let fluent: Fluent

	var content: some HTML {
		AsyncContent {
			let rows = try await Stat.query(on: fluent.db())
				.filter(\.$channel, .equal, channel)
				.all()

			h1 { "\(channel) stats" }

			ul {
				li {
					b {
						"Count"
					}
					": \(rows.count)"
				}
			}
		}
	}
}
