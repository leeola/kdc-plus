
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

**Note about the KDC Namespace:** The current default usage of the KDC
namespace is intended to be a short term occupation. I would like to keep all
kdc-plus functionality separated from kdc, while perserving the ability to be
backwards compatible. In this case, i will likely create a 2nd project named
something like `kdc-plus-legacy` which will occupy the legacy namespace while
using kdc-plus. For now though, we're forcefully occupying both namespaces.

## Usage

`kdc-plus` also uses the `kdc` namespace, so usage is the same as normal
`kdc`. Feel free to call `kdc -h` for additional options such as minifying
and overriding manifest options.

## Manifest Additions

Below is an example of the additions we are currently adding to the manifest,
see each of the following topics to explain the properties.

```
{
  "coffee": false,
  "commonjs": false
}
```

### Commonjs

If `commonjs` is `false`, we simply concat the compiled CoffeeScript files
*(or normal JavaScript)* into a single file. If it is `true`, then we use
Browserify v2 to implement the standard commonjs require system.

### Coffee

Coffee support is at it sounds, support for Coffee files.

## CLI Additions

The CLI is entirely different from `kdc`, and is all pretty obvious and
documented through `kdc-plus -h`. With that said, below we will go over any
notable points.

### --pipe

`kdc-plus -p` will pipe all output instead of writing it to a file. Output
goes to `stdout` as expected, and logs go to `stderr` as expected. It's
worth noting that the CLI parse library that kdc-plus uses outputs to stdout
by default, this is something i want changed as soon as possible.

### --transform

While pipe outputs the compiled, concatenated, and closured *final* output
of kdc-plus, a transform has the ability to modify a specific file
as it is passing through kdc-plus.

The purpose being, compilers such as Coffee *(or whatever language you may
like)* don't have the ability to distinguish between file types. With a
transformer you can modify the incoming DSL of your choise and output
javascript back to kdc-plus. kdc-plus will then take that output, and
concat/wrap/etc it with the rest of the files in the kdapp.

kdc-plus will write to `stdin` and read `stdout`, `stderr` is ignored.

### --trans-ext

If you have a mix of file types, such as javascript, coffee, and typescript,
you may have the need to use a transform on only a specific file type.
`--trans-ext <ext>` allows you to do this, and will only transform the
file type that the extension matches. Even better, if your needs are more
complex, you can specify a regex string to use instead of the simple file
extension. Positive matches will be transformed, everything else is ignored
from this transform.

## I still don't get it

If you're looking for additional explanation of what this project is, why it
exists, and what goals it has, please see [the ABOUT page](ABOUT.md).

## Looking towards the future, v030
