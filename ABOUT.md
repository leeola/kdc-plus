
# Why Another Compiler?

The default KDC is a basic compiler that works perfectly fine, but i wanted
more. I wanted my KDApps to be able to declare dependencies, both
compile-time and run-time dependencies.

I could have extended `kdc` to include these features, but it would have felt
tacked on and with such a large addition of code, i figured it would make the
most sense to split the projects.

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
