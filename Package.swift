// swift-tools-version: 6.2
// Paquete multiplataforma:
// - En macOS/iOS usa directamente el SwiftUI nativo de Apple (tanto desde Package.swift como desde BookApp.xcodeproj).
// - En Linux y Windows usa SwiftOpenUI a través de Compat/SwiftUI.
import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

#if os(Linux)
let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/uallps/SwiftOpenUI.git", branch: "uallps"),
]
let packageTargets: [Target] = [
    .target(
        name: "SwiftUI",
        dependencies: [
            .product(name: "SwiftOpenUI", package: "SwiftOpenUI"),
            .product(name: "BackendGTK4", package: "SwiftOpenUI"),
        ],
        path: "Compat/SwiftUI"
    ),
    .executableTarget(
        name: "BookApp",
        dependencies: ["SwiftUI"],
        path: "BookApp",
        exclude: ["Assets.xcassets"],
        swiftSettings: sharedSwiftSettings
    ),
]
#elseif os(Windows)
let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/uallps/SwiftOpenUI.git", branch: "uallps"),
]
let packageTargets: [Target] = [
    .target(
        name: "SwiftUI",
        dependencies: [
            .product(name: "SwiftOpenUI", package: "SwiftOpenUI"),
            .product(name: "BackendWin32", package: "SwiftOpenUI"),
        ],
        path: "Compat/SwiftUI"
    ),
    .executableTarget(
        name: "BookApp",
        dependencies: ["SwiftUI"],
        path: "BookApp",
        exclude: ["Assets.xcassets"],
        swiftSettings: sharedSwiftSettings
    ),
]
#else
let packageDependencies: [Package.Dependency] = []
let packageTargets: [Target] = [
    .executableTarget(
        name: "BookApp",
        path: "BookApp",
        exclude: ["Assets.xcassets"],
        swiftSettings: sharedSwiftSettings
    ),
]
#endif

let package = Package(
    name: "BookApp",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    // Productos de la línea: cada trait activo es una variable de compilación (#if Prioridades).
    // En Xcode, el mismo papel lo cumple el target «BookApp Prioridades».
    traits: [
        .trait(name: "Prioridades", description: "Característica opcional: prioridad del libro"),
    ],
    dependencies: packageDependencies,
    targets: packageTargets
)
