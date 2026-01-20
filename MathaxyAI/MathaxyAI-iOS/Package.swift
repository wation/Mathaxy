// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mathaxy",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Mathaxy", targets: ["Mathaxy"])
    ],
    targets: [
        .target(
            name: "Mathaxy",
            path: "Mathaxy",
            resources: [
                .process("Resources"),
                .process("Localization")
            ]
        )
    ]
)
