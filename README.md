<h1>Control Center Slider</h1>

<p>
    <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" />
    <img src="https://img.shields.io/badge/macOS-14.0+-orange.svg" />
    <img src="https://img.shields.io/badge/-SwiftUI-red.svg" />
</p>

A faithful recreation of iOS control center slider (with some extended functionality)

## Installation

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://github.com/joakimhellgren/swiftui-control-center-slider.git` as the URL and click the "Load" button.

## Usage
Control Center Slider (CCSlider) intentionally mimics SwiftUI's built in Slider declaration.
The following functions enables further interaction similar to the iOS Control Center slider:
- long press callback
- backdrop style
- corner radius  

```swift
// Basic use
import ControlCenterSlider

@State var value = 0.5
...
CCSlider(value: $value)
```

```swift
// Extended use
import ControlCenterSlider
...

@State var value = 0.5
@State var longPressState = false
...

CCSlider(
    value: $value,
    in: 0...1,
    step: longPressState ? 1/6 : nil,
    cornerRadius: longPressState ? 40 : 30,
    backgroundStyle: .bar,
    onEditingChanged: { gestureState in
        // do something
    },
    onLongPress: {
        withAnimation {
            longPressState.toggle()
        }
    }
)
.frame(
    width: longPressState ? 120 : 90, 
    height: longPressState ? 340 : 300
) 
```


