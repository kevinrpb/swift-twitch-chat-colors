import Elementary
import Foundation
import HummingbirdFluent

struct ChannelPage: HTML {
	let channel: String
	let fluent: Fluent

	var content: some HTML {
		main(
			.class(
				"mx-auto min-h-screen w-full p-4 flex flex-col justify-center overflow-hidden bg-black"
			)
		) {
			div(.class("w-full")) {
				h1(.class("mb-10 text-3xl text-center font-semibold")) {
					"\(channel) stats"
				}
			}

			div(.class("flex flex-row justify-center align-center gap-2")) {
				AsyncContent {
					let chartsData = try await processData()

					if !chartsData.isEmpty {
						for data in chartsData {
							Chart(data: data)
						}
					} else {
						p { "No data for this channel" }
					}
				}
			}
		}
	}

	// TODO: Maybe move this and the charts elsewhere
	private func processData() async throws -> [ChartData] {
		let stats = try await Stat.query(on: fluent.db())
			.filter(\.$channel, .equal, channel)
			.all()

		if stats.isEmpty { return [] }

		var messageCountByColor: [String: Int] = [:]
		var usersByColor: [String: Set<String>] = [:]

		for stat in stats {
			guard let userID = stat.userID, let displayColor = stat.displayColor else {
				continue
			}

			if !messageCountByColor.keys.contains(displayColor) {
				messageCountByColor[displayColor] = 0
			}

			if !usersByColor.keys.contains(displayColor) {
				usersByColor[displayColor] = .init()
			}

			messageCountByColor[displayColor]! += 1
			usersByColor[displayColor]!.insert(userID)
		}

		return [
			.init(
				title: "Messages by color",
				points: messageCountByColor.map { .init(label: $0.key, value: $0.value) }
			),
			.init(
				title: "Users by color",
				points: usersByColor.map { .init(label: $0.key, value: $0.value.count) }
			),
		]
	}
}

private struct DataPoint {
	let label: String
	let value: Int
}

private struct ChartData {
	let title: String
	let points: [DataPoint]
	let maxValue: Int
	let totalValue: Int

	init(title: String, points: [DataPoint]) {
		self.title = title
		self.points = points.sorted(using: KeyPathComparator(\.value))
		maxValue = self.points.last?.value ?? 0
		totalValue = self.points.reduce(into: 0) { partialResult, point in
			partialResult += point.value
		}
	}
}

private struct Chart: HTML {
	let data: ChartData

	var content: some HTML {
		section(
			.class(
				"h-full w-[400px] p-4 flex flex-col rounded-lg bg-comment-grey bg-clip-border shadow-md"
			)
		) {
			h2(.class("mb-2 text-xl text-center")) { data.title }

			table(.class("charts-css column hide-data")) {
				caption { data.title }

				tbody {
					ForEach(data.points.sorted(using: KeyPathComparator(\.label))) { point in
						TableData(
							point: point, maxValue: data.maxValue, totalValue: data.totalValue)
					}
				}
			}
		}
	}

	@HTMLBuilder
	private func TableData(point: DataPoint, maxValue: Int, totalValue: Int) -> some HTML {
		let size = Double(point.value) / Double(maxValue)
		let percent = (100 * point.value / totalValue).formatted(.percent)

		let label = point.label.isEmpty ? "none" : point.label
		let color =
			point.label.isEmpty
			? "repeating-linear-gradient(135deg, #fff 0px, #fff 6px, #000 6px, #000 12px);"
			: point.label

		tr {
			th(.custom(name: "scope", value: "row")) { label }

			td(.style("--size: \(size); --color: \(color);")) {
				span(.class("data")) { "\(point.value)" }
				span(.class("tooltip")) {
					label
					br()
					percent
					br()
					"\(point.value)"
				}
			}
		}
	}
}
