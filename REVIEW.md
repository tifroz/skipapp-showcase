# Attributed text review snapshot

This branch demonstrates native attributed text in Showcase without adding temporary dependency changes to either library PR.

## Pinned changes

| Package | Fork | Commit |
| --- | --- | --- |
| SkipFuseUI | [tifroz/skip-fuse-ui](https://github.com/tifroz/skip-fuse-ui) | `8c78981dde21d7d90cb9e75ce8af7f8d03ac4682` |
| SkipUI | [tifroz/skip-ui](https://github.com/tifroz/skip-ui) | `f3f7c277108d54059adcdbe640499a598e9db978` |

Both revisions are pinned in Showcase's `Package.swift`. The root SkipUI pin overrides SkipFuseUI's normal version requirement. `Package.resolved` records the remaining remote dependencies. No local package checkouts or mirrors are required.

## Build Android

Use macOS with Xcode, Skip, JDK 21, the Android SDK, and the Swift 6.4.0 Android SDK installed. Validated with Xcode 27.1 / Swift 6.4, Gradle 9.7.0, and Skip CLI 1.9.13. Ensure `skip`, `gradle`, and `adb` are on your PATH and the Android SDK environment is configured.

```sh
git clone --branch tifroz/review-attributed-text --single-branch \
  https://github.com/tifroz/skipapp-showcase.git
cd skipapp-showcase
./scripts/build-attributed-review
```

The script selects Fuse mode, clears `SKIP_DEPENDENCY_ROOT`, and selects the native Swift build engine for Skip's nested Android build. The Gradle setup also uses that engine for its Apple prebuild and stops if the prebuild fails. The alert playground expression is split into smaller views to avoid a Swift 6.4 type-check timeout.

The APK is written to `.build/Android/app/outputs/apk/debug/app-debug.apk`. Install it on an attached Android device:

```sh
adb -s DEVICE_SERIAL install -r .build/Android/app/outputs/apk/debug/app-debug.apk
```

Launch **Showcase** from the device. This uses the standard Showcase application ID (`org.appfair.app.Showcase`) and updates an existing installation signed with the same debug key.

## What to review

Open **Showcase → Text** and scroll to **Markdown** and **Attributed strings**. Check nested bold/italic Markdown, code and strikethrough, whitespace, mixed fonts and colors, underlines, links, superscripts, subscripts, and styled Unicode wrapping. **Source** links point to this review branch.

The existing Apple SwiftUI rendering provides a comparison when running the workspace on an Apple device or simulator. Keep `SKIP_DEPENDENCY_ROOT` unset; set your own signing team if building for a physical Apple device.

## Validation

Validated on October 22, 2026:

- Resolved all 26 dependencies from remote repositories with no local dependency overrides or mirrors. Confirmed both fork revisions in `Package.resolved`.
- Built the native Android Showcase library and assembled the debug APK successfully using the command above.
- Installed that APK on a Samsung SM-S721U and opened **Showcase → Text**. Visually checked nested Markdown, mixed fonts/colors, underline/strikethrough, superscript/subscript, styled Unicode wrapping, and inherited font/color.
- Tapped the attributed **Swift** link and confirmed Chrome opened `swift.org`.

Apple compilation passed as part of the Gradle prebuild. Apple runtime behavior and the optional Lite build were not tested in this review snapshot.

## Scope

Only this temporary Showcase branch contains the dependency pins, default Fuse setting, build compatibility scripts, and review documentation. The two library feature branches retain their normal upstream dependency declarations.
