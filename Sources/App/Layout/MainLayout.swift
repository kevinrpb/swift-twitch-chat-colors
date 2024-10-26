import Elementary

extension MainLayout: Sendable where Content: Sendable {}
struct MainLayout<Content: HTML>: HTMLDocument {
	var title: String

	@HTMLBuilder
	var pageContent: Content

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
		meta(.title(title))

		// TODO: Use Tailwind CLI to generate CSS instead
		script(.src("https://cdn.tailwindcss.com")) {}
	}

	var body: some HTML {
		main {
			pageContent
		}
	}
}
