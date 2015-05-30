# VSH-Advanced
"VSH is too restricted with boss-modifications and FF2 is too god-damn clunky." - Nergal

We hope to achieve something far more advanced and stable.

# Words from Nergal about bugs & glitches
some bugs are that sometimes it doesn't allocate the rightly chosen player to be the boss, some private forwards are not called back sometimes which I find very odd.

when a player is finished being the boss, sometimes their boss specific variables aren't reset.

There's not many bugs and glitches but they're major flaws that screw up the mod in general.

# Your viewing the Master Branch

If you was looking for the most recent bleeding edge technology, you need to click on the button that says branch: master, and change it to branch: develop

Currently VSHA is now working.

# To Developers of Addons:

* Developers / server owners can use the chat command /reloadboss
/reloadboss will bring up a menu of the bosses you can reload.  This will help speed up development of new bosses, without having to restart the server for every update.  I strongly stress not to use "sm plugins reload" because it will cause VSHA to become unstable.
* Each boss can be loaded separately anytime.  (I have yet to create a /unloadboss command, and strongly suggest you wait until I do in order to remove boss plugins)
* See vsha-saxtonhale.sp for using as an example on how to create a boss plugin for VSHA
* See vsha-OnEquipPlayer-example.sp for creating non-boss plugins example
