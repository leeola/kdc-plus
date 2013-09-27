
# Koding Compiler Plus, The Reckoning

Welcome to what i am calling *kdc-plus*. This project is an alternate KDApp
Compiler, which can be replace the default `kdc` compiler.
By making an alternate compiler, we have an easy way to add features to
the compilation process such as languages, commonjs, dependency resolution,
etc. For a further explanation, check out [the ABOUT page](ABOUT.md).

## Installation

To install, simply run the following two commands *(you may need `sudo`)*:

```
npm uninstall -g kdc
npm install -g kdc-plus
```

## Usage

`kdc-plus` also uses the `kdc` namespace, so usage is the same as normal
`kdc`. Feel free to call `kdc -h` for additional options such as minifying
and overriding manifest options.

## Manifest Additions

Below is an example of the additions we are currently adding to the manifest,
see each of the following topics to explain the properties.

```
{
  "commonjs": false,
  "no-coffee": false
}
```

### Commonjs

If `commonjs` is `false`, we simply concat the compiled CoffeeScript files
*(or normal JavaScript)* into a single file. If it is `true`, then we use
Browserify v2 to implement the standard commonjs require system.

### No Coffee, wut?

Coffee support is on by default since the normal KDC uses coffee. You can
disable it with this option.

## I still don't get it

If you're looking for additional explanation of what this project is, why it
exists, and what goals it has, please see [the ABOUT page](ABOUT.md).
