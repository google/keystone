# Keystone

Keystone is an architectural analysis toolset integrated in the Atom text
editor. It allows software engineers to create models of system architectures
which can be used to guide development decisions through analysis and
simulation. The modelling and simulation capabilities are inspired by Palladio,
a powerful analysis tool integrated into Eclipse, but with models represented in
a plain text language. This yields some compelling benefits over the binary blob
approach:

+ Models can be checked into version control
+ A common on-disk format enables integration with other tools, including design
rules checkers
+ Human-readable text can be viewed and considered without special tooling
+ Support for multiple formats can be added; Keystone currently supports models
embedded in Markdown files

## Building

To build the project, follow these steps:

1. Install the latest [Atom](https://atom.io) release for your system.
2. Clone the repository.
3. Install the Elm toolset: `npm install -g elm elm-test`
4. Run the build script: `./build.sh`
5. Link Keystone to your Atom packages directory: `apm link keystone`
6. Start Atom in developer mode with `atom -d` or `View > Developer > Open In
Dev Mode`

Keystone uses Elm, a strongly-typed functional language, for the bulk of its
logic. You will need to recompile the project before your changes to any `.elm`
files will be visible in Atom. Generally, the edit flow goes something like
this:

1. Make a change to an Elm file.
2. Run `./build.sh`, and fix any compile or test failures.
3. Reload Atom (`Alt+Ctrl+R` on Linux, `Cmd+Option+Ctrl+L` on OSX, or `View >
Developer > Reload Window` anywhere).
4. Test the change in Atom.

## Contributing

We'd love to accept your patches and contributions to this project. Here are a
few small guidelines you need to follow.

### Contributor License Agreement

Contributions to any Google project must be accompanied by a Contributor License
Agreement. This is necessary because you own the copyright to your changes, even
after your contribution becomes part of this project, so this agreement simply
gives us permission to use and redistribute your contributions as part of the
project. Head over to <https://cla.developers.google.com/> to see your current
agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

### Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult [GitHub Help] for more
information on using pull requests.

[GitHub Help]: https://help.github.com/articles/about-pull-requests/

## Disclaimer

Please note that while Keystone is an open-source project started by Google
engineers, it is *not* an official Google product.
