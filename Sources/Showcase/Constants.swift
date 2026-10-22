// Copyright 2023–2026 Skip
import Foundation

/// URL string of the source this app.
let showcaseSourceURLString = "https://github.com/tifroz/skipapp-showcase/tree/tifroz/review-attributed-text/"
let playgroundPath = "Sources/Showcase/"

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })
