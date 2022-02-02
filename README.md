# Important
A collective repository for all the important things related to this SFOS port.

## What's this?

[Sailfish OS](https://sailfishos.org/) (often abbreviated as SFOS) is an independent and mature mobile Linux distribution focused on privacy and security. It provides a true alternative to the dominant mobile operating systems such as Google's Android and Apple's iOS. For example [it is being adopted by the Russian government](https://techcrunch.com/2016/11/29/jollas-sailfish-os-now-certified-as-russias-first-android-alternative/) for it's secure nature.

My ultimate goal with this project is to port Sailfish OS to the [OnePlus 5](https://www.gsmarena.com/oneplus_5-8647.php) and [5T](https://www.gsmarena.com/oneplus_5t-8912.php).

## Issues

If you've found a bug on a release build, in the build process (regarding my guide) or would like to have a public convo about something SFOS related, go ahead and [create a new issue](../../issues)!

For gathering required report information about crashes, freezes, battery drainage etc and generally debugging hardware / software issues check out the [debugging guide](DEBUGGING.md).

## Releases

I will add releases occasionally to [their dedicated page](../../releases) on this repo. If you just want notifications about new releases, feel free to adjust this [repo's notification settings](https://help.github.com/en/articles/watching-and-unwatching-releases-for-a-repository) for yourself.

## Flashing

Once you've got everything built or are flashing a release build, check out the [flashing guide](FLASHING.md) in case you need help.

## Building from source

The build guide expects an **x86-64 based Linux environment** for building the Sailfish OS source code, related packages and LineageOS HAL side + around **60 GB of free space** on top of that to comfortably build everything without issues. Also **4+ GB of RAM** is required: the more the better.

When these basic requirements are met, you can move onto the [sfbootstrap quick start docs](https://github.com/JamiKettunen/sfbootstrap#quick-start) and go on from there.

The guide has been built with the help of the [HADK](https://sailfishos.org/develop/hadk/), [FAQ](https://github.com/mer-hybris/hadk-faq), [IRC logs](https://piggz.co.uk/sailfishos-porters-archive/index.php), [sfbootstrap](https://github.com/JamiKettunen/sfbootstrap) & the awesome people at [#sailfishos-porters](https://web.libera.chat/#sailfishos-porters).

## Application development

To develop applications for Sailfish OS you'll be using a modified install of [Qt Creator](https://www.qt.io/). The full guide can be found [here](https://sailfishos.org/wiki/Application_SDK).
