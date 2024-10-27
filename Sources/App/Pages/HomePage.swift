import Elementary
import HummingbirdFluent

struct HomePage: HTML {
	let fluent: Fluent

	var content: some HTML {
		main(
			.class(
				"mx-auto flex min-h-screen w-full max-w-[400px] flex-col justify-center overflow-hidden bg-black"
			)
		) {
			div(.class("w-full")) {
				h1(.class("mb-2 text-3xl font-semibold")) {
					"Channels"
				}
			}

			div(
				.class(
					"relative flex h-full flex-col overflow-scroll rounded-lg bg-comment-grey bg-clip-border shadow-md"
				)
			) {
				TableContent()
			}
		}
	}

	private func TableContent() -> some HTML {
		AsyncContent {
			let channels = try await Stat.query(on: fluent.db()).all()
			let channelCounts: [String: Int] = channels.reduce(into: [:]) {
				partialResult, stat in
				guard let channel = stat.channel else { return }

				if !partialResult.keys.contains(channel) {
					partialResult[channel] = 0
				}

				partialResult[channel]! += 1
			}

			if !channelCounts.isEmpty {
				Table(
					headers: ["Channel", "Messages", ""],
					rows: channelCounts.map { [$0.key, "\($0.value)", $0.key] }
				) { i, text in
					switch i {
					case 0, 1:
						p(.class("text-sm")) { text }
					case 2:
						Button(href: "/channel/\(text)", text: "See stats")
					default:
						fatalError("Shouldn't get here!")
					}
				}
			} else {
				// TODO: pull the channels from the server config
				p(.class("p-4")) { "No messages recorded" }
			}
		}
	}
}

private struct Table<CellContent: HTML>: HTML {
	let headers: [String]
	let rows: [[String]]

	@HTMLBuilder
	var cellContent: (Int, String) -> CellContent

	var content: some HTML {
		table(.class("table-auto text-left")) {
			thead {
				tr {
					for header in headers {
						th(.class("border-b border-slate-600 bg-gutter-grey p-4")) {
							p(.class("text-sm font-semibold")) { header }
						}
					}
				}
			}

			tbody {
				for row in rows {
					tr {
						for (i, text) in row.enumerated() {
							td(.class("p-4")) {
								cellContent(i, text)
							}
						}
					}
				}
			}
		}
	}
}

private struct Button: HTML {
	let href: String
	let text: String

	var content: some HTML {
		a(
			.href(href),
			.class(
				"rounded-md border border-slate-300 px-4 py-2 text-center text-sm shadow-sm transition-all hover:border-slate-800 hover:bg-black hover:text-white hover:shadow-lg focus:border-slate-800 focus:bg-black focus:text-white active:border-slate-800 active:bg-black active:text-white disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none"
			),
			.custom(name: "type", value: "button")
		) { text }
	}
}
