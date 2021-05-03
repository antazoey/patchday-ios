# PDTest

This project implements all of the protocols in [PDKIT](../PDKit/README.md) as mocks.

## The PDTest Protocol

The standard PDTest protocol is this. Say you have a simple class that implements a simple protocol.

```swift 	
protocol SimpleProtocol {
	func simpleFunc()
	func simpleArgsFunc(arg1: Int, arg2: String)
}

class SimpleObject: SimpleProtocol {

	func simpleFunc() {
		...
	}
	
	func simpleArgsFunc(arg1: Int, arg2: String) {
		...
	}
}
```

Then, this would be the standard way of writing the Mock:

```swift
class MockObject: SimpleProtocol {
	
	var simpleFuncCallCount = 0
	func simpleFunc() {
		simpleFuncCallCount += 1
	}
	
	var simpleArgsFuncCallArgs: [(Int, String)] = []
	func simpleArgsFunc(arg1: Int, arg2: String) {
		simpleArgsFuncCallArgs.append((arg1, arg2))
	}
}
```

## Tests

After defining mock dependencies to classes, you can make assertions on them to verify a particular method was 
called.

```swift

func testWhenA_callsB() {
	...
	XCTAssertEqual(1, mockObj.simpleFuncCallCount)
	XCTAssertEqual(2, mockObj.simpleArgsFuncCallArgs[0].0)
	XCTAssertEqual("Test", mockObj.simpleArgsFuncCallArgs[0].1)
}
```

## Variance

There are some exceptions to this. `PDTest` is not a public library; it is internal for PatchDay test projects. Do 
what works and what makes sense.
