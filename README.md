# Important
A collective repository for all the important things related to this SFOS port.

## What's this?

[Sailfish OS](https://sailfishos.org/) (often abbreviated as SFOS) is an independent and mature mobile Linux distribution focused on privacy and security. It provides a true alternative to the dominant mobile operating systems such as Google's Android and Apple's iOS. For example [it is being adopted by the Russian government](https://techcrunch.com/2016/11/29/jollas-sailfish-os-now-certified-as-russias-first-android-alternative/) for it's secure nature.

My aim with this project is to port Sailfish OS to the [OnePlus 5](https://www.gsmarena.com/oneplus_5-8647.php) (and maybe later [5T](https://www.gsmarena.com/oneplus_5t-8912.php) with unified builds).

## Issues

If you've found a bug on a release build, in the build process (regarding my guide) or would like to have a public convo about something SFOS related, go ahead and [create a new issue](../../issues)!

## Releases

I will add releases occasionally to [their dedicated page](../../releases) on this repo. If you just want notifications about new releases, feel free to adjust this [repo's notification settings](https://help.github.com/en/articles/watching-and-unwatching-releases-for-a-repository) for yourself.

## Building from source
The build guide expects an x64-based Linux environment for building the Sailfish OS source code, related packages and LineageOS HAL side + around 50 GB of free space on top of that to comfortably build everything without issues. Also 4+ GB of RAM is required: the more the better.

When these basic requirements are met, you can move onto the [initial building guide](INITIAL-BUILDING.md) and go on from there.

The guide has been built with the help of the [HADK](https://sailfishos.org/develop/hadk/), [FAQ](https://public.etherpad-mozilla.org/p/faq-hadk), [IRC logs](https://piggz.co.uk/sailfishos-porters-archive/index.php) & the awesome people at [#sailfishos-porters](https://webchat.freenode.net/#sailfishos-porters).
