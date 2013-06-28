# Supernova [![Build Status](https://travis-ci.org/redjazz96/supernova.png?branch=master)](https://travis-ci.org/redjazz96/supernova)

![A Very Pretty Supernova](http://www.nasa.gov/centers/goddard/images/content/280046main_CassAcomposite_HI.jpg)

## What is supernova?
Supernova is a way to set up software on computers in a definite and consistant process.
It's primary goals are to be cross-platform compatible, easy to use and understand, and
powerful.

## Great!  How do I get started?
It's not ready yet.  It's still early in development, and there are a few things that need
tweaking.  As of right now,  it's 100% documented, and completely written in Ruby.
I have marked things that need to be done with a `@todo` tag, if you wanna go check it out.
There are a few things I plan on adding to Supernova before I release it.

## Terminology
I came up with Supernova because I couldn't think of a better name.  Turns out, it actually
fit.  Code to set up a piece of software is a `Star`, a server with stars is called a
`Cluster`, and (if applicable) the server to manage Clusters is called a `Nucleus` (or
`Axis`, I haven't made up my mind which).

## License
Supernova is licensed under the MIT License, which can be found [here](LICENSE).

@TODO: note benefit of installing posix-spawn when using local remote.

(note: in order to work with libsodium, the location of the library needs to be added to `LD_LIBRARY_PATH`)
