# PatchDay CONTRIBUTING.md

## IDE

I recommend to just use Xcode. However, AppCode may also work and have some desirable tooling.

## Linter

Use [SwiftLint](https://github.com/realm/SwiftLint). Follow the install instructions - make sure `swiftlint` is in 
your path.

**NOTE**: If you get a fatal error regarding `sourcekitd`, try the following command:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

To check lint errors, do:

```bash
swift tasks.swift lint
```

The `lint` command also fixes the errors it can.

## Testing

### PDTest

The project `PDTest` contains manual mocks for protocols defined in `PDKit.Protocols`. Use them, follow their 
patterns, create new ones if you need, modify them as you need. Mocks are mostly built and updates on a 
needs-basis, but the basic pattern is:

* If the method has no arguments and no return value, use a call count feature:

```swift
    public var fooCallCount = 0
    public func foo() {
        foo += 1
    }
```

Have tests verify the call count:

```swift
    XCTAssertEqual(1, mockObject.fooCallCount
```

* Does the mocked method contain arguments? Create a public variable containing the args and append them 
during calls. The convention for the variable name is `<method-name>CallArgs`:

```swift
    public var fooCallArgs: [Int]] = []
    public func foo(bar: Int) {
        resetCallArgs.append(bar)
    }
```

```swift
    foo(bar: 6)
    ...
    PDAssertSingle(6, fooCallArgs)
```

If there are mutliple args, use a tuple to track them in the list:

```swift
    public var fooCallArgs: [(Int, String)] = []
    public func foo(bar: Int, jules: String) {
        resetCallArgs.append((bar, jules))
    }
```

* Does the mocked method have a return value? Create a variable named `<method-name>ReturnValue` and 
make it settable:

Example:

```swift
    public var fooReturnValue = 0
    public func foo() {
        fooReturnValue
    }
```

```swift
    mockObject.fooReturnValue = 500
    let actual = mockObject.foo()
    XCTAssertEqual(500, actual)
```

* Is your method annoying complex? Well, just allow for a mock implementation, and make it settable

```swift
    public var fooMockImplementation: () -> () = { }
    public func foo() {
        fooMockImplementation()
    }
```

```swift
    var wasCalled = false
    mockObject.fooMockImplementation = { wasCalled = true }
    mockObject.foo()
    XCTAssert(wasCalled)
```
