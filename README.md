Twitterpunch
===============

Twitterpunch is designed to work with PhotoBooth and OS X Folder Actions.
When this script is called with the name of an image file, it will post the
image to Twitter, along with a message randomly chosen from a list and a
specified hashtag.

If you call the script with the --stream argument instead, it will listen
for tweets to that hashtag and download them to a specified directory. If
the tweet came from another user, Twitterpunch will speak it aloud.

Configuration
===========

Configure the program via the `~/.twitterpunch.yaml` YAML file. This file should
look similar to the example below.

    ---
    :twitter:                               # twitter configuration
      :consumer_key: <consumer key>
      :consumer_secret: <consumer secret>
      :access_token: <access token>
      :access_token_secret: <access secret>
    :messages:                              # list of messages to attach
    - Hello there                           # to outgoing tweets
    - I'm a posting fool
    - minimally viable product
    :hashtag: Twitterpunch                  # The hashtag to post and listen to
    :photodir: ~/Pictures/twitterpunch/     # Where to save downloaded images
    :logfile: ~/.twitterpunch.log           # Where to save logs
    :viewer:                                # Use the built-in slideshow viewer
      :count: 5                             # How many images to have onscreen at once

A skeleton configuration file, with access tokens from Twitter, can be generated
by running the program with the `--genconfig` flag.

Usage 
==========

### Using OS X PhotoBooth

1. Start PhotoBooth at least once to generate its library.
1. Install the Twitterpunch Folder Action
    * `twitterpunch --install`
    * It may claim that it could not be attached, fear not.
1. Profit!
    * _and by that, I mean take some shots with PhotoBooth!_

#### Troubleshooting.

1. Make sure the folder action is installed properly
    1. Use the Finder to navigate to `~/Pictures/`
    1. Right click on the `Photo Booth Library` icon and choose _Show Package Contents_.
    1. Right click on the `Pictures` folder and choose `Services > Folder Actions Setup`
    1. Make sure that the `Twitterpunch` action is attached.
1. Install the folder action
    1. Open the `resources` folder of this gem.
        * Likely to be found in `/Library/Ruby/Gems/2.0.0/gems/twitterpunch-#{version}/resources/`.
    1. Double click on the `Twitterpunch` folder action and install it.
        * It may claim that it could not be attached, fear not.

### Using something else

Configure the program you are using for your photo shoot to call Twitterpunch
each time it snaps a photo. Pass the name of the new photo as a command line
argument.  Alternatively, you could batch them, as Twitterpunch can accept
multiple files at once.

    [ben@ganymede] ~ $ twitterpunch photo.jpg

### Viewing the Twitter stream

Twitterpunch will run on OS X or Windows equally well. Simply configure it on the
computer that will act as the Twitter display and then run in streaming mode.
All images tweeted to the configured hashtag will be displayed in the slideshow
and tweets that come from any other user will also be spoken aloud.

    [ben@ganymede] ~ $ twitterpunch --stream

If you don't want to use the built-in slideshow viewer, you can disable it by
removing the `:viewer` key from your `~/.twitterpunch.yaml` config file. Twitterpunch
will then simply download the tweeted images and save them into the `:photodir`
directory. You can then use anything you like to view them.

There are currently two decent viewing options I am aware of.

* Windows background image:
    * Configure the Windows background to randomly cycle through photos in a directory.
    * Hide desktop icons.
    * Hide the taskbar.
    * Disable screensaver and power savings.
    * Drawbacks: You're using Windows and you have to install Ruby & RubyGems manually.
* OS X screensaver:
    * Choose one of the sexy screensavers and configure it to show photos from the `:photodir`
    * Set screensaver to a super short timeout.
    * Disable power savings.
    * Drawbacks: The screensaver doesn't reload dynamically, so I have to kick it
      and you'll see it reloading each time a new tweet comes in.

Limitations
===========

* It currently requires manual setup for Folder Actions.
* Rubygame is kind of a pain to set up.


Contact
=======

* Author: Ben Ford
* Email: binford2k@gmail.com
* Twitter: @binford2k
* IRC (Freenode): binford2k
