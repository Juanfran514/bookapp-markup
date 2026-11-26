// swift-tools-version: 6.2
// Paquete multiplataforma: mantiene siempre SwiftOpenUI en el paquete.
// En Linux y Windows usa Compat/SwiftUI (GTK4 / Win32); en macOS usa SwiftUI de Apple
// conservando la dependencia de SwiftOpenUI para que Xcode y SwiftPM la detecten.
import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

#if os(Linux)
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
let packageTargets: [Target] = [
    .executableTarget(
        name: "BookApp",
        dependencies: [
            .product(name: "SwiftOpenUI", package: "SwiftOpenUI"),
        ],
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
    dependencies: [
        .package(url: "https://github.com/uallps/SwiftOpenUI.git", branch: "uallps"),
    ],
    targets: packageTargets
)
