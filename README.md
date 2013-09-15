
# Koding Compiler Plus, The Reckoning

Welcome to what i am calling *kdc-plus*. This project is an alternate KDApp
Compiler, which can be replace the default `kdc` compiler.
By making an alternate compiler, we have an easy way to add features to
the compilation process. The primary of these features being, compile-time
and runtime dependency resolution. For further explanation,
[see below][#the-long-version].

## Installation

To install, simply run the following command:

```
npm install -g kdc-plus
```

Note that if you're installing on a default Koding VM, you will need to
use `sudo` with that command.

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
  "compiler": "commonjs"
}
```

### Dependencies

The `dependencies` object is a series of keys with `true`/`false` values. Each
key represents a packaging system we support, and if the value is true we will
install those dependencies.

Remember, these are **runtime** dependencies. Whatever is in here, is required
for users of our application to install. Generally, these will be serverside
dependencies such as web servers, etc.

### devDependencies

The `devDependencies` object is a series of keys with `true`/`false` values.
Each key represents a packaging system we support, and if the value is
true we install those devDependencies.

Remember, these are **compile-time** dependencies. Whatever is in here, is
required for our app to *compile*. Typically, this is used to include 3rd
party code in our application's compiled `index.js` file.

## The Long Explanation

Most KDApps at the time of this writing have no external dependencies. This
is okay for the basic stuff, but this severely limits the potential of the
applications *(in my modest opinion)*.

If you look at any popular language with a healthy community, you see a strong
packaging system behind this community. Allowing them to share libraries
and functionality. I'm not suggesting we build our own packaging system,
i don't see the need. I *am* suggesting that we create a system by which we
can include these packages as dependencies of our applications.

### So, how will this work?

To understand the implementation, we must understand the constraints that
KDApps put on us.

When a KDApp is "installed" from the main App List it comes with two files.
This process is simply a copying of the two files, a compiled
JavaScript file, and a Manifest file. Users then run it, and that's it, any
custom serverside code or processes that we may depend on are not installed.
To install serverside dependencies that our runtime depends on,
we have to run code during the apps execution. This installer code
has to be *included* in this application. These are considered runtime
dependencies, or `dependencies` in the manifest.

For dependencies that are included *in* the source of the application *(that
JavaScript file)*, or that a compiler hook may depend on,
we need to include those at the time of compilation. We will consider
these compile-time dependencies, or `devDependencies` in the manifest. 

### Compile-Time Dependencies

Compile-time dependencies will be resolved by kdc-plus, before compiling.
By resolving it before compiling, we can then compile like normal and any
files from any npm/bower/etc libraries can be included in the manifest and
compilation like normal. No failed compilations due to missing npm modules.

### Runtime Dependencies

Runtime dependencies are a bit more complex. Because these can't be baked
with the application *(for multiple reasons)*, we must install them on the
user machine at the time of running the application. This means that we'll
have to inject this installer code into the compiled js file. It will run
in the background of the app launching and in a configurable way, and will
prompt the user informing that the KDApp has VM-side dependencies that
are being installed.
