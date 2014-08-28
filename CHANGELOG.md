# Changelog

## v0.12.1 (2014-08-27)

## Bug Fixes

- Follow renaming of ReactEditorView to EditorView
  - Matches atom/atom@3d2d8c4 which is included in Atom 0.124.0.

## v0.12.0 (2014-08-21)

## Features

- ng-classify support.

## v0.11.0 (2014-08-14)

## Features

- LiveScript language support.

## v0.10.4 (2014-08-14)

## Bug Fixes

- Improve regexes for matching extensions. No need to match entire string, just the end.

## v0.10.3 (2014-08-11)

## Bug Fixes

- Fixes #48. Preview shouldn't be focused.

## v0.10.2 (2014-08-11)

## Bug Fixes

- Fixes #48. Reverting the last changes. It actually is worse.

## v0.10.1 (2014-08-11)

## Bug Fixes

- Fixes #48. Forces focus on lastEditor after Preview.

## v0.10.0 (2014-08-11)

## Features

- Closes #22. Add interface for User to select (force) Renderer. 
- Closes #47. SpacePen preview rendering support.

## v0.9.0 (2014-08-10)

## Features

- Closes #32. PreviewView now extends ReactEditorView.

## v0.8.2 (2014-08-07)

## Bug Fixes

- Fix contex-menu in non-editeara

## v0.8.1 (2014-08-07)

## Features

- UI Improvements to error message popup.

## Bug Fixes

- Improve resource management. Destroy panel on package deactivate.

## v0.8.0 (2014-08-06)

## Features

- Closes #39. Add EmberScript support.

## v0.7.0 (2014-08-06)

## Features

- Closes #41. Add React (JSX) support.

## v0.6.8 (2014-07-30)

## Bug Fixes

- More subtle overlay for error messages

## v0.6.7 (2014-07-30)

## Bug Fixes

- Use editor font family

## v0.6.6 (2014-07-30)

## Bug Fixes

- Fixes #10. Fix bug that Google Analytics events not being tracked.
- Use same font as editor

## v0.6.5 (2014-07-28)

## Bug Fixes

- Fixes #30. LESS previewing now includes Atom's LESS variables.

## v0.6.4 (2014-07-27)

## Features

- Minor UI improvements.
  - Removed some unneccessary logging
  - Removed top and bottom padding from preview-view

## v0.6.3 (2014-07-27)

## Features

- See #15. Add ClojureScript sample. Previewer not yet implemented.

### Bug Fixes

- Fixes #28. Workaround for PreviewView to handle getModel method. 

## v0.6.2 (2014-07-27)

### Bug Fixes

- Fixes #27. Apply selected theme's syntax highlighting in Previews.

## v0.6.1 (2014-07-27)

### Features

- Add DSON support to README

## v0.6.0 (2014-07-27)

### Features

- DSON support

## v0.5.2 (2014-07-27)

### Bug Fixes

- Stylus rendering is now given a file path to resolve external files, such as used for variables.

## v0.5.1 (2014-07-27)

### Features

- Improve Analytics data tracking

## v0.5.0 (2014-07-27)

### Features

- Add Analytics to track which languages are most used

## v0.4.0 (2014-07-27)

### Features

- Stylus language support

## v0.3.1 (2014-07-27)

### Features

- Add TypeScript support to README

## v0.3.0 (2014-07-27)

### Features

- TypeScript language support

## v0.2.0 (2014-07-26)

### Features

- DodgeScript language support

## v0.1.2 (2014-07-26)

### Features

- Add ActivationEvents to improve performance

## v0.1.1 (2014-07-26)

### Features

- Add [Gitter](https://gitter.im/) badge
- Literate CoffeeScript support

## v0.1.0 (2014-07-22)

### Features

- CoffeeScript language support
- LESS language support
- Jade language support
