// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "TodoListServer",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.77.1"),
    // 🗄 An ORM for SQL and NoSQL databases.
    .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
    // ᾫ6 Fluent driver for SQLite.
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    
    .package(url: "https://github.com/FullStack-Swift/swift-extension", branch: "main"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Transform", package: "swift-extension"),
      ]
    ),
    .testTarget(name: "AppTests", dependencies: [
      .target(name: "App"),
      .product(name: "XCTVapor", package: "vapor"),
    ])
  ]
)
