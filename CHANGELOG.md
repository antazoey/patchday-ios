# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The intended audience of this file is for PatchDay consumers -- as such, changes that don't affect
  [Bookmarked May 31, 2020 at 7:25:13 AM]
how a consumer would use the library (e.g. adding unit tests, updating documentation, etc) are not captured here.

## 3.0.0 - Unreleased

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

### Fixed

- Bug with custom sites not being scheduled correctly.
