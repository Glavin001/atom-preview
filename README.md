# [Preview for Atom](https://github.com/Glavin001/atom-preview)

> Ultimate previewer of source code in Atom.

[![Gitter chat](https://badges.gitter.im/Glavin001/atom-preview.png)](https://gitter.im/Glavin001/atom-preview)

[![star this repo](http://githubbadges.com/star.svg?user=Glavin001&repo=atom-preview&background=007ec6&style=flat)](http://github.com/Glavin001/atom-preview)
[![fork this repo](http://githubbadges.com/fork.svg?user=Glavin001&repo=atom-preview&background=007ec6&style=flat)](http://github.com/Glavin001/atom-preview/fork)

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
- [x] [Users can manually change the default preview renderer](https://github.com/Glavin001/atom-preview/issues/22)
- [x] [SpacePen Views can live preview!](https://github.com/Glavin001/atom-preview/issues/47)

## Supported Languages

- [x] [CoffeeScript](https://github.com/Glavin001/atom-preview/issues/1)
- [x] [Literate CoffeeScript](https://github.com/Glavin001/atom-preview/pull/18)
- [x] [LESS](https://github.com/Glavin001/atom-preview/issues/2)
- [x] [Jade](https://github.com/Glavin001/atom-preview/issues/8)
- [x] [DogeScript](https://github.com/Glavin001/atom-preview/issues/12)
- [x] [TypeScript](https://github.com/Glavin001/atom-preview/issues/5)
- [x] [Stylus](https://github.com/Glavin001/atom-preview/issues/21)
- [x] [DSON](https://github.com/Glavin001/atom-preview/issues/13)
- [x] [React (JSX)](https://github.com/Glavin001/atom-preview/issues/41)
- [x] [EmberScript](https://github.com/Glavin001/atom-preview/issues/39)
- [x] [ng-classify](https://github.com/Glavin001/atom-preview/issues/60)
- [ ] [SASS](https://github.com/Glavin001/atom-preview/issues/3)
- [ ] [Markdown](https://github.com/Glavin001/atom-preview/issues/7)
- [ ] [Haml](https://github.com/Glavin001/atom-preview/issues/9)
- [ ] [ClojureScript](https://github.com/Glavin001/atom-preview/issues/15)
- [ ] [Dart](https://github.com/Glavin001/atom-preview/issues/14)

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
