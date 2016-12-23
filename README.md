Twitterpunch
===============

Twitterpunch is designed to work with PhotoBooth and OS X Folder Actions.
When this script is called with the name of an image file, it will post the
image to Twitter, along with a message randomly chosen from a list and a
specified hashtag.

If you call the script with the `--stream` argument instead, it will listen
for tweets to that hashtag and download them to a specified directory. If
the tweet came from another user, Twitterpunch will speak it aloud.

Typically, you'll run one copy on an OSX laptop with PhotoBooth, and a separate
copy on another machine (either Windows or OSX) for the viewer. You can also use
a mobile device as a remote control, if you like. This will allow the user to
enter a custom message for each photo that gets tweeted out, if they'd like.


Configuration
===========

Configure the program via the `~/.twitterpunch/config.yaml` YAML file. This file
should look similar to the example below.

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
    :handle: Twitterpunch                   # The twitter username to post as
    :photodir: ~/Pictures/twitterpunch/     # Where to save downloaded images
    :logfile: ~/.twitterpunch/activity.log  # Where to save logs
    :viewer:                                # Use the built-in slideshow viewer
      :count: 5                             # How many images to have onscreen at once

1. Generate a skeleton configuration file
    * `twitterpunch --configure`
1. Edit the configuration file as needed. You'll be prompted with the path.
    * If you have your own Twitter application credentials, you're welcome to use them.
1. Authorize the application with the Twitter API.
    * `twitterpunch --authorize`


Usage 
==========

### Using OS X PhotoBooth

1. Start PhotoBooth at least once to generate its library.
1. Install the Twitterpunch Folder Action
    * `twitterpunch --install`
    * It may claim that it could not be attached, fear not.
1. Profit!
    * _and by that, I mean take some shots with PhotoBooth!_

*Note*: if the folder action doesn't seem to work and photos aren't posted to
Twitter, here are some troubleshooting steps to take:

1. Run Twitterpunch by hand with photos as arguments. This may help you isolate
   configuration or authorization issues.
    * `twitterpunch foo.jpg`
1. Correct the path in the workflow.
    * `which twitterpunch`
    * Edit the Twitterpunch folder action to include that path.
    
#### Using the remote web app

1. Run the app with `twitterpunch --remote`
1. Browse to the app with http://{address}:8080
1. [optional] If on an iOS device, add to your homescreen
    * This will give you "app behaviour", such as full screen, and a nice icon

#### Troubleshooting.

1. Make sure the folder action is installed properly
    1. Use the Finder to navigate to `~/Pictures/`
    1. Right click on the `Photo Booth Library` icon and choose _Show Package Contents_.
    1. Right click on the `Pictures` folder and choose `Services > Folder Actions Setup`
    1. Make sure that the `Twitterpunch` action is attached.
1. Install the folder action
    1. Open the `resources` folder of this gem.
        * Likely to be found in `/Library/Ruby/Gems/{version}/gems/twitterpunch-#{version}/resources/`.
    1. Double click on the `Twitterpunch` folder action and install it.
        * It may claim that it could not be attached, fear not.


### Using something besides PhotoBooth

Configure the program you are using for your photo shoot to call Twitterpunch
each time it snaps a photo. Pass the name of the new photo as a command line
argument.  Alternatively, you could batch them, as Twitterpunch can accept
multiple files at once.

    [ben@ganymede] ~ $ twitterpunch photo.jpg [photo2.jpg photo3.jpg photo4.jpg]


### Viewing the Twitter stream

Twitterpunch will run on OS X or Windows equally well. Simply configure it on the
computer that will act as the Twitter display and then run in streaming mode.

    [ben@ganymede] ~ $ twitterpunch --stream

There are two modes that Twitterpunch can operate in.

1. If a `:hashtag` is defined then all images tweeted to the configured hashtag
   will be displayed in the slideshow.
1. Otherwise, Twitterpunch will stream the `:handle` Twitter user's stream and
   display all images either posted by that user or addressed to that user. With
   protected tweets, you can have rudimentary access control.

In either mode, tweets that come from any other user will also be spoken aloud.

If you don't want to use the built-in slideshow viewer, you can disable it by
removing the `:viewer` key from your `~/.twitterpunch/config.yaml` config file.
Twitterpunch will then simply download the tweeted images and save them into the
`:photodir` directory. You can then use anything you like to view them.

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
