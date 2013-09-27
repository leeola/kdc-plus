
# Koding Compiler Plus, The Reckoning

Welcome to what i am calling *kdc-plus*. This project is an alternate KDApp
Compiler, which can be replace the default `kdc` compiler.
By making an alternate compiler, we have an easy way to add features to
the compilation process. The primary of these features being, compile-time
and runtime dependency resolution. For further explanation,
[see below][#the-long-version].

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
  "dependencies": {
    "node": true,
    "bower": true
  },
  "devDependencies": {
    "node": true,
    "bower": true
  },
  "commonjs": false
}
```

### Dependencies

The `dependencies` object is a series of keys with `true`/`false` values. Each
key represents a packaging system we support, and if the value is true we will
install those dependencies.
The dependencies themselvs are not defined in our manifest, but in the
platform specific dependency file such as `package.json` or `bower.json`,
our manifest simply tells `kdc-plus` that we want to check and run
these installers.


Remember, these are **runtime** dependencies. Whatever is in here, is required
for users of our application to install. Generally, these will be serverside
dependencies such as web servers, etc.

### devDependencies

The `devDependencies` object is a series of keys with `true`/`false` values.
Each key represents a packaging system we support, and if the value is
true we install those devDependencies.
The dependencies themselvs are not defined in our manifest, but in the
platform specific dependency file such as `package.json` or `bower.json`,
our manifest simply tells `kdc-plus` that we want to check and run
these installers.

Remember, these are **compile-time** dependencies. Whatever is in here, is
required for our app to *compile*. Typically, this is used to include 3rd
party code in our application's compiled `index.js` file.

### Commonjs

If `commonjs` is `false`, we simply concat the compiled CoffeeScript files
*(or normal JavaScript)* into a single file. If it is `true`, then we use
Browserify v2 to implement the standard commonjs require system.

## I still don't get it

If you're looking for additional explanation of what this project is, why it
exists, and what goals it has, please see [the ABOUT page](ABOUT.md).
