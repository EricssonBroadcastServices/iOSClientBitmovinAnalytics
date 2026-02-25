# iOSClientBitmovinAnalytics

`iOSClientBitmovinAnalytics` is a standalone Swift library that captures events emitted by **Bitmovin Player** and reliably forwards them to the RBM backend for analytics processing.

## Requirements

-   iOS 14+ / tvOS 14+
-   Swift 5.10+
-   Xcode 15.3+
-   [Bitmovin Player SDK](https://github.com/bitmovin/player-ios) 3.0.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(
        url: "https://github.com/EricssonBroadcastServices/iOSClientBitmovinAnalytics.git", 
        .upToNextMajor(from: "1.0.0")
    )
]
```

Then add it to your target:

```swift
.target(
    name: "YourAppTarget",
    dependencies: ["iOSClientBitmovinAnalytics"]
)
```

## Usage

### 1. Create the BitmovinAnalyticsAdapter

Create the analytics adapter with your configuration.

```swift
let analyticsAdapter = BitmovinAnalyticsAdapter(configuration: analyticsConfig)
```
> ⚠️ **Important:** Keep a strong reference to `analyticsAdapter` to ensure it stays alive while the player is active. Otherwise, analytics events may not be sent.

### 2. Attach Analytics to the player

Connect the adapter to the player to enable analytics event tracking.

```swift
player.attachAnalytics(using: analyticsAdapter)
```

### 3. Report program changes (when applicable)

Program changes cannot be detected automatically by the SDK. Therefore, call this method whenever your application detects that a new program has started.

```swift
analyticsAdapter.trackProgramChanged()
```
