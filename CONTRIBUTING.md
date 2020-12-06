# PatchDay CONTRIBUTING.md

## Environment

Recommended to use Xcode. AppCode may also work (and may have some desired tooling).

## Linter

Use [SwiftLint](https://github.com/realm/SwiftLint). Follow the install instructions - make sure `swiftlint` is in your path.

To check lint errors, do:

```bash
make lint
```

`make autocorrect` works decently for correcting some errors.

CircleCI will complain about certain lint errors for the project.

## Testing

### PDMock 
The project `PDMock` contains manual mocks for protocols defined in `PDKit.Protocols`. Use them, follow their patterns,
create new ones if you need, modify them as you need. Mocks are mostly built and updates on a needs-basis, but the basic pattern is:

* Does the mocked function contain arguments? Create a public variable containing the args and append them during calls. The 
convention for the variable name is `<function-name>CallArgs`. If the function does not take arguments, simply create a 
`<function-name>.CallCount` variable and increment it in the mock implementation.

* Does the mocked function have a return value? Create a variable named `<function-name>ReturnValue` and make it settable. Set it 
during tests.

### Tests Scheme

If you create a new tests project, make sure to add it to the shared testing scheme.
