// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-composable-architecture",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .tvOS(.v13),
    .watchOS(.v7),
    .visionOS(.v1)
  ],
  products: [
    .library(
      name: "ComposableArchitecture",
      targets: ["ComposableArchitecture"]
    ),
    .library(
      name: "SwiftObservation",
      targets: ["SwiftObservation"]
    ),
    .library(
      name: "StateManagement",
      targets: ["StateManagement"]
    ),

    .library(
      name: "UIComponents",
      targets: ["UIComponents"]
    ),
    .library(
      name: "SwiftExt",
      targets: ["SwiftExt"]
    ),
    .library(
      name: "ArchitectureExt",
      targets: ["ArchitectureExt"]
    ),
    .library(
      name: "Documentation",
      targets: ["Documentation"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.2"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    .package(url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
    // MARK: custom
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "ComposableArchitecture",
      dependencies: [
        "ComposableArchitectureMacros",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "SwiftUINavigationCore", package: "swiftui-navigation"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        // MARK: custom
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        "ComposeMacros",
        "SwiftExt",
        "UIComponents",
      ],
      path: "Sources/ComposableArchitecture"
    ),
    .target(
      name: "StateManagement",
      dependencies: [
        "ComposableArchitecture",
      ],
      path: "Sources/StateManagement"
    ),
    .target(
      name: "SwiftExt",
      dependencies: [
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ],
      path: "Sources/SwiftExt"
    ),
    .target(
      name: "ArchitectureExt",
      dependencies: [
        "ComposableArchitecture",
        "SwiftExt"
      ],
      path: "Sources/ArchitectureExt"
    ),
    .target(
      name: "SwiftObservation",
      dependencies: [],
      path: "Sources/SwiftObservation"
    ),
    .target(
      name: "UIComponents",
      dependencies: [
        "SwiftExt",
      ],
      path: "Sources/UIComponents",
      resources: [.process("Fonts")]
    ),
    .target(
      name: "Documentation",
      dependencies: [
        "ComposableArchitecture",
      ],
      path: "Sources/Documentation"
    ),
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    // Macro implementation that performs the source transformation of a macro.
      .macro(
        name: "ComposableArchitectureMacros",
        dependencies: [
          .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
          .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]
      ),
    .testTarget(
      name: "ComposableArchitectureMacrosTests",
      dependencies: [
        "ComposableArchitectureMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
    .macro(
      name: "ComposeMacros",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftOperators", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ],
      path: "Sources/ComposeMacros"
    ),
    .testTarget(
      name: "ComposableArchitectureTests",
      dependencies: [
        "ComposableArchitecture",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    .executableTarget(
      name: "swift-composable-architecture-benchmark",
      dependencies: [
        "ComposableArchitecture",
        .product(name: "Benchmark", package: "swift-benchmark"),
      ]
    ),
  ]
)

//for target in package.targets {
//  target.swiftSettings = target.swiftSettings ?? []
//  target.swiftSettings?.append(
//    .unsafeFlags([
//      "-Xfrontend", "-warn-concurrency",
//      "-Xfrontend", "-enable-actor-data-race-checks",
//      "-enable-library-evolution",
//    ])
//  )
//}
