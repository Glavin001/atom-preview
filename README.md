# [Preview for Atom](https://github.com/Glavin001/atom-preview)

> Ultimate previewer of source code in Atom.

[![Gitter chat](https://badges.gitter.im/Glavin001/atom-preview.png)](https://gitter.im/Glavin001/atom-preview)

Atom Package: https://atom.io/packages/preview

```bash
apm install preview
```

Or Settings/Preferences ➔ Packages ➔ Search for `preview`

## Features

- [x] Preview source code in compiled form in separate tab
- [x] Live updating of preview
- [x] Shows loading and error messages
- [x] [Updates on Tab Change](https://github.com/Glavin001/atom-coffeescript-preview/issues/3)
- [x] [Highlights using active Atom theme](https://github.com/Glavin001/atom-coffeescript-preview/issues/5)

## Supported Languages

- [x] [CoffeeScript](https://github.com/Glavin001/atom-preview/issues/1)
- [x] [LESS](https://github.com/Glavin001/atom-preview/issues/2)
- [ ] [SASS](https://github.com/Glavin001/atom-preview/issues/3)
- [ ] [TypeScript](https://github.com/Glavin001/atom-preview/issues/5)
- [ ] [Markdown](https://github.com/Glavin001/atom-preview/issues/7)
- [x] [Jade](https://github.com/Glavin001/atom-preview/issues/8)
- [ ] [Haml](https://github.com/Glavin001/atom-preview/issues/9)

## Package Settings

- `Refresh Debounce Period` (milliseconds) -
Set the debounce rate for preview refreshing.
For instance, if you type or switch tabs,
how long of a pause before the preview refreshes.
- `Update On Tab Change` (boolean) -
Should the preview update to the currently active tab?

## Screenshots

### Preview CoffeeScript as JavaScript

![screenshot](https://raw.githubusercontent.com/Glavin001/atom-coffeescript-preview/master/screenshot.png)

### Syncing with Tab Changes

![screencapture](https://cloud.githubusercontent.com/assets/1885333/3576573/99212e10-0b93-11e4-8cd5-9da29e9230dd.gif)


[npm]: https://www.npmjs.org/package/generator-atom-package
[atom-doc]: https://atom.io/docs/latest/creating-a-package "Official documentation"
