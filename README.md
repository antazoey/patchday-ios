# PatchDay

An iOS app for managing HRT medication. The primary use-case is the "patch staggering"
technique for transdermal patches. PatchDay also supports Pills, Injection-based HRT, 
and Gel-based HRT. To learn more about how to set up the app, visit the support site.

[Support Site](https://patchdayhrt.com)

## Targets

### PatchDay

- The main app target, the target that gets archived for production.

### Embedded libraries / widgets

* [PatchData](./Sources/PatchData/) - the PatchDay backend Core Data proxy.
* [PatchDaySite](https://github.com/unparalleled-js/patchday-site) - the PatchDay support website.
* [PDKit](./Sources/PDKit/) - shared PatchDay app tools.
* [NextHormoneWidget](./Sources/NextHormoneWidget/) - Displays when next the hormone is due as a widget.

## Schemes

### Notifications Test

This target sets hormones that are about to expire. You can use this target to verify notification-based 
behavior.  Run the target and then minimize the app and wait for notificaitons to appear.  The hormone notification occurs in a few seconds but the pill notification takes until the start of the next minute.

See [Contributing](./CONTRIBUTING.md).

### Debug

The debug target includes additional logging.

## Building

Do

```bash
make build
```

Or build the PatchDay target.
