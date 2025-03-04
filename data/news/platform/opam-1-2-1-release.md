---
title: "OPAM 1.2.1 Released"
authors: [ "Louis Gesbert" ]
date: "2015-03-18"
description: "Release announcement for OPAM 1.2.1"
tags: [platform]
---

[OPAM 1.2.1](https://github.com/ocaml/opam/releases/tag/1.2.1) has just been
released. This patch version brings a number of fixes and improvements
over 1.2.0, without breaking compatibility.


### Upgrade from 1.2.0 (or earlier)

See the normal
[installation instructions](https://opam.ocaml.org/doc/Install.html): you should
generally pick up the packages from the same origin as you did for the last
version -- possibly switching from the official repository packages to the ones
we provide for your distribution, in case the former are lagging behind.


### What's new

No huge new features in this point release -- which means you can roll back
to 1.2.0 in case of problems -- but lots going on under the hood, and quite a
few visible changes nonetheless:

* The engine that processes package builds and other commands in parallel has
  been rewritten. You'll notice the cool new display but it's also much more
  reliable and efficient. Make sure to set `jobs:` to a value greater than 1 in
  `~/.opam/config` in case you updated from an older version.
* The install/upgrade/downgrade/remove/reinstall actions are also processed in a
  better way: the consequences of a failed actions are minimised, when it used
  to abort the full command.
* When using version control to pin a package to a local directory without
  specifying a branch, only the tracked files are used by OPAM, but their
  changes don't need to be checked in. This was found to be the most convenient
  compromise.
* Sources used for several OPAM packages may use `<name>.opam` files for package
  pinning. URLs of the form `git+ssh://` or `hg+https://` are now allowed.
* `opam lint` has been vastly improved.

... and much more

There is also a [new manual](https://opam.ocaml.org/doc/Manual.html) documenting
the file and repository formats.


### Fixes

See [the changelog](https://github.com/ocaml/opam/blob/1.2.1/CHANGES) for a
summary or
[closed issues](https://github.com/ocaml/opam/issues?q=is%3Aissue+closed%3A%3E2014-10-16+closed%3A%3C2015-03-05+)
in the bug-tracker for an overview.


### Experimental features

These are mostly improvements to the file formats. You are welcome to use them,
but they won't be accepted into the
[official repository](https://github.com/ocaml/opam-repository) until the next
release.

* New field `features:` in opam files, to help with `./configure` scripts and
  documenting the specific features enabled in a given build. See the
  [original proposal](https://github.com/ocaml/opam/blob/master/doc/design/depopts-and-features)
  and the section in the [new manual](https://opam.ocaml.org/doc/Manual.html#opam)
* The "filter" language in opam files is now well defined, and documented in the
  [manual](https://opam.ocaml.org/doc/Manual.html#Filters). In particular,
  undefined variables are consistently handled, as well as conversions between
  string and boolean values, with new syntax for converting bools to strings.
* New package flag "verbose" in opam files, that outputs the package's build
  script to stdout
* New field `libexec:` in `<name>.install` files, to install into the package's
  lib dir with the execution bit set.
* Compilers can now be defined without source nor build instructions, and the
  base packages defined in the `packages:` field are now resolved and then
  locked. In practice, this means that repository maintainers can move the
  compiler itself to a package, giving a lot more flexibility.
