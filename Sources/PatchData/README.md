# PatchData

PatchData is the [PatchDay](../PatchDay/README.md) backend. It implements the 
[Core Data](https://developer.apple.com/documentation/coredata) stack.

## Entities

* Hormones
* Pills
* Sites

## Relationships

* Sites can have 1:N hormones.

## Settings

Settings are implemented using 
[User Defaults](https://developer.apple.com/documentation/foundation/userdefaults) and mostly apply to as 
global Hormone settings. Equivalent Pill settings are attached to their entity since each Pill entity can represent 
a different medication whereas Hormone entities refer to just one type of medication.
