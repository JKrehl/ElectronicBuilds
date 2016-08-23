# julia-portage
Overlay for portage for the Julia language.

##Installation

Add the repo to layman via
```bash
layman -o  https://raw.github.com/JKrehl/julia-portage/master/repositories.xml -f -a julia-portage
```
and thats it.

Some strange error produces access violations of the sandbox. They seem to be ignorable but the ebuild install and qmerge steps have to be invoked by hand, install will also throw access violations.
