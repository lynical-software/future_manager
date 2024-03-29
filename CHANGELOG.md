## [1.11.0] - 6 Feb 2024
- add `customBuilder` to `FutureManager`

## [1.10.0] - 9 Jan 2024
- add `onError` to `when` method on `FutureManager`

## [1.9.0] - 13 Dec 2023
- add `eventListener` to `FutureManager` to easily remove listener

## [1.9.0] - 13 Dec 2023
- add `eventListener`

## [1.8.1] - 30 Nov 2023
- Revert 1.8.0: `FutureManagerBuilder` now delay builder for one frame to not build a existing data if reset is called

## [1.8.0] - 30 Nov 2023
- Revert 1.6.0: `FutureManagerBuilder` now `DO NOT` delay builder for one frame. New workaround improvement

## [1.7.0] - 17 Aug 2023
- improve `onError` on FutureManager `execute` method: Allow error overriding

## [1.6.0] - 18 May 2023
- `FutureManagerBuilder` now delay builder for one frame to not build a existing data if reset is called
- Fix `FutureManagerBuilder` onError isn't called on init state if FutureManager already has an error

## [1.5.0] - 26 April 2023
- Improve callback parameter naming convention
- add `reportError` to `FutureManager`

## [1.4.0] - 1 February 2023

- Fix multiple provider's errorListener being called on multiple listener

## [1.3.0] - 18 January 2023

- Internal source code architecture changed, No Breaking change

## [1.2.0] - 6 January 2023

- add `onReadyOnce` method to FutureManagerBuilder

## [1.1.0] - 15 November 2022

- add `build` method to FutureManager

## [1.0.1] - 7 September 2022

- Update pubspec.yaml

## [1.0.0+1] - 25 August 2022

- Update pubspec.yaml

## [1.0.0] - 1 July 2022

- Rename some field and attribute
- update README and Example
- stable release

## [0.0.1] - 1 July 2022

- Initial release