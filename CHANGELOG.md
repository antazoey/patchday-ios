# Changelog

## Unreleased

### Fixed

- Bug where Pill Schedules "Last 10 Days" and "Last 20 Days" would use the wrong start date of the month.
- Bug where Pill Schedules "First 10 Days" and "First 20 Days" would not work correctly at the end of the month.

### Changed

- iPad font size for Hormone Cell text was decreased.

## 3.1.1

### Fixed

- Fix text in expired Gel notification's title and body - was previously the Injection title and body.
- Fix text in all expired hormone notifications where it would indicate the hormone is not expired yet.
- Fixed migration issue where you would get an extra pill time even if you were only using a single time.

### Removed

- Removed next suggested site text from expired hormone notifications, as it was faulty.

## 3.1.0

### Added

- Pills can now be taken up to 4 times per day.

### Fixed

- A bug with the Hormone Detail screen where changing both the Date and the Site would change the site of the wrong Hormone.
- An issue that prevented Pill expiration-interval changes from saving.
- A bug where the Pill expiration interval "First twenty days" mistakenly used "First ten days".
- Bugs preventing pill expiration intervals "Last Twenty Days" or "Last Ten Days" from working properly after it's initial use.
- A bug where "Last Twenty Days" and "Last Ten Days" did one more day than expected.
- Mistake in Pill Detail view title where it said "New Pill" for the initial pills created.
- An anomaly in the Pills list where a fresh a Pill schedule would say 10:00 for the initial next-due dates. It now says a more helpful message.more helpful message.

## 3.0.4

### Fixed

- Issue where App would not detect unsaved changes for Site Image.

### Removed

- Faulty Hormone notification action for changing the hormone from the notification.

## 3.0.3

### Fixed

- Issue where if you disable and re-enable the Notifications setting on Dark mode, some text would disappear.
- Issue where if there was only one Site, the site schedule would not suggest it.
- Issue where custom Gel images would appear as placeholder Gel images.
- Bug where when adding a new Site, it's order label would not display in a Site Cell.
- Actually fix issue where new Pills did not default to Notify=true.

## 3.0.2

### Fixed

- Issue where the Pill tab would not display badge alerts when notifications were disabled for the Pill.
- Issue where the App badge would not update when changing a due Pill right away.
- Issue where new Pills did not default to Notify=true like they did before.

## 3.0.1

### Fixed

- Issue where the Unsaved Changes Alert did not block the navigation after editing a hormone and tapping Back.
- Issue where if you declined adding a new site name from a type-edit on a hormone, it would not set the site.

## 3.0.0

### Added

- Dark mode.
- Estro-Gel hormonal delivery method support with site choices:
	- Arms
	Supports custom sites.
- The concept of "Pill Schedules" with choices:
	- Every Day (previously was only one supported)
	- Every Other Day
	- First 10 Days of the Month
	- First 20 Days of the Month
	- Last 10 Days of the Month
	- Last 20 Days of the Month
	Available by editing a pill in the Pill Schedule.
- Hormone Cell Actions, useful for quickly changing Hormones.
- Warning for when leaving views without saving changes.
	- Leaving Hormone Details View.
	- Leaving Pill Details View.
- Icon improvements.
- Increased sizes.
	- Changed Site Schedule tab icon.
- A Moon icon now displays in the top right of a Hormone Cell for overnight Hormones.

### Changed

- Taking Pills is handled through alert actions now. Simply select the PillCell to Take a pill.
- Editing Pills is handled through alert actions now. Simply select the PillCell to Edit pill details.
- The SiteSchedule no longer cares about occupied sites and just follows the site Index accordingly.

### Fixed

- Bug with custom sites not being scheduled correctly.
