// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

import PackageDescription

let package = Package(
    name: "sudoku-battles-communication",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "SudokuBattlesCommunication", targets: ["SudokuBattlesCommunication"])
    ],
    dependencies: [
        .package(path: "../simple-buffers")
    ],
    targets: [
        .target(
            name: "SudokuBattlesCommunication",
            dependencies: [
                .product(name: "SimpleBuffers", package: "simple-buffers")
            ]
        ),
    ]
)
