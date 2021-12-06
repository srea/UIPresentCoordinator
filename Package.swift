// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "UIPresentCoordinator",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "UIPresentCoordinator", targets: ["UIPresentCoordinator"])
    ],
    targets: [
        .target(
            name: "UIPresentCoordinator",
            path: "./Sources"
        )
    ]
)
