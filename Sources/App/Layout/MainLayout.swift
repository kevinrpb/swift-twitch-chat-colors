import Elementary

private let tailwindConfig = """
	tailwind.config = {
		theme: {
			extend: {
				colors: {
					'black': '#282c34',
					'white': '#abb2bf',
					'light-red': '#e06c75',
					'dark-red': '#be5046',
					'green': '#98c379',
					'light-yellow': '#e5c07b',
					'dark-yellow': '#d19a66',
					'blue': '#61afef',
					'magenta': '#c678dd',
					'cyan': '#56b6c2',
					'gutter-grey': '#4b5263',
					'comment-grey': '#5c6370'
				}
			}
		}
	}
	"""

private let tailwindCSS = """
	@tailwind base;
	@tailwind components;
	@tailwind utilities;

	@layer base {
		html, body {
			@apply bg-black;
			@apply text-white;
		}
	}
	"""

extension MainLayout: Sendable where Content: Sendable {}
struct MainLayout<Content: HTML>: HTMLDocument {
	var title: String

	@HTMLBuilder
	var pageContent: Content

	var head: some HTML {
		meta(.charset(.utf8))
		meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
		meta(.title(title))

		script(.src("https://cdn.tailwindcss.com")) {}
		script { tailwindConfig }
		style(.custom(name: "type", value: "text/tailwindcss")) { tailwindCSS }

		link(.rel(.stylesheet), .href("https://unpkg.com/charts.css/dist/charts.min.css"))
	}

	var body: some HTML {
		pageContent
	}
}
