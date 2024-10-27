// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-twitch-chat-colors",
	platforms: [.macOS(.v14)],
	products: [
		.executable(name: "twitch-chat-colors", targets: ["App"])
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.3.0"),
		.package(url: "https://github.com/sliemeobn/elementary.git", from: "0.4.1"),
		.package(
			url: "https://github.com/hummingbird-community/hummingbird-elementary.git",
			from: "0.4.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
		.package(url: "https://github.com/kevinrpb/swift-twitch-client.git", branch: "irc-return-continuation"),
	],
	targets: [
		.executableTarget(
			name: "App",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Elementary", package: "elementary"),
				.product(name: "Hummingbird", package: "hummingbird"),
				.product(name: "HummingbirdElementary", package: "hummingbird-elementary"),
				.product(name: "Twitch", package: "swift-twitch-client"),
			]
		),
		.testTarget(
			name: "AppTests",
			dependencies: ["App"]
		),
	]
)
