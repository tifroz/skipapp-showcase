// This gradle project is part of a conventional Skip app project.
pluginManagement {
    // Swift 6.4's default build engine rejects shared static products in this
    // graph. Generate the plugin output with the native engine before using it.
    if (System.getenv("BUILT_PRODUCTS_DIR") == null) {
        val sdkPath = providers.exec {
            commandLine("xcrun", "--sdk", "iphoneos", "--show-sdk-path")
        }.standardOutput.asText.get().trim()
        val prebuild = providers.exec {
            commandLine("xcrun", "swift", "build", "--build-system", "native",
                "--triple", "arm64-apple-ios", "--sdk", sdkPath,
                "--package-path", settings.rootDir.parent)
            isIgnoreExitValue = true
        }
        print(prebuild.standardOutput.asText.get())
        print(prebuild.standardError.asText.get())
        prebuild.result.get().assertNormalExitValue()
    }

    // Initialize the Skip plugin after a successful prebuild, or reuse Xcode output.
    val pluginPath = File.createTempFile("skip-plugin-path", ".tmp")

    // overriding outputs for an Android IDE can be done by un-commenting and setting the Xcode path:
    //System.setProperty("BUILT_PRODUCTS_DIR", "${System.getProperty("user.home")}/Library/Developer/Xcode/DerivedData/MySkipProject-HASH/Build/Products/Debug-iphonesimulator")

    val skipPluginResult = providers.exec {
        commandLine("skip", "plugin", "--no-prebuild", "--package-path", settings.rootDir.parent,
            "--plugin-ref", pluginPath.absolutePath)
        environment("PATH", "${System.getenv("PATH")}:/opt/homebrew/bin")
    }
    val skipPluginOutput = skipPluginResult.standardOutput.asText.get()
    print(skipPluginOutput)
    val skipPluginError = skipPluginResult.standardError.asText.get()
    print(skipPluginError)

    includeBuild(pluginPath.readText()) {
        name = "skip-plugins"
    }
}

plugins {
    id("skip-plugin") apply true
}
