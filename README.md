# PatchDay

An iOS app for managing HRT medication. The primary use-case is the "patch staggering"
technique for transdermal patches. PatchDay also supports Pills, Injection-based HRT, 
and Gel-based HRT. To learn more about how to set up the app, visit the 
[Support Site](https://patchdayhrt.com).

## Build Targets

### PatchDay

- The main app and front-end.

### Embedded libraries / widgets

* [PatchData](./Sources/PatchData/) - a [Core-Data](https://developer.apple.com/documentation/coredata) client.
* [PDKit](./Sources/PDKit/) - shared utilities.
* [NextHormoneWidget](./Sources/NextHormoneWidget/) - A widget for displaying when to take the next dose.

## Build Schemes

### Notifications Test

Use this scheme to initialize the app with hormones that are about to expire. 
You can use this target to verify notification-based behavior. 
Run the target and then minimize the app and wait for notificaitons to appear. 

See [Contributing](./CONTRIBUTING.md) to learn more about testing.

### Debug

The debug target includes additional logging.

## Building

You can build using the `make` command or via your IDE.

```bash
make build
```
