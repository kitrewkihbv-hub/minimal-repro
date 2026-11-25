// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "NeoWidget macOS Native",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "NeoWidget", targets: ["NeoWidget"]),
    .library(name: "NeoWidgetExtensionLib", targets: ["NeoWidgetExtension"])
  ],
  targets: [
    .executableTarget(
      name: "NeoWidget",
      dependencies: [
        .target(name: "NeoWidgetExtension")
      ],
      path: "Sources/NeoWidget",
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "NeoWidgetExtension",
      dependencies: [],
      path: "Sources/NeoWidgetExtension",
      resources: [
        .process("Resources")
      ]
    )
  ]
)
