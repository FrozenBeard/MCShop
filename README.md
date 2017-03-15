![PirateCraft](https://piratemc.com/wp-content/themes/piratemc/images/piratemc_piratemc_logo.png)
  
Website for viewing items for sale on PirateCraft Minecraft server, automatically updates once a day at 9am GMT from JSON data sent to this repo [PirateCraftData](https://github.com/FrozenBeard/PirateCraftData).

Minified JSON RAW data URL: https://raw.githubusercontent.com/FrozenBeard/PirateCraftData/master/signshop.min.json
JSON RAW data URL: https://raw.githubusercontent.com/FrozenBeard/PirateCraftData/master/signshop.json

Since the data is JSON you should be able to import into Excel or anything you want to create graphs! Make sure to share them on the [Forums](https://piratemc.com/forums)

## Working Shop URL
[Sign Shop for PiratCraft](http://signshop.piratemc.com)

## wait this repo IS the website?
Hell yeah, all hosted using Github pages, make a pull request to this Repo and the website will be updated! Since its all JS and static content!

## Features
- Automatically updates all shops located on the server every 30 minutes (Thanks to SignShopExport) we only push the data once a day.
- Dynmap support, all coordinates are clickable and will take you to that location on dynmap
- Support for enchanted items
- Shows player heads next to playername (Using Minotaur API)
- Select drop-down box is filterable by typing (Using Select2)
- Sorts results by lowest price (Using Lodash JS Library)
- Results displayed in cards (Materialize CSS Framework)
- Mobile Friendly (Materialize CSS Framework)

## How to set this up locally and make changes (To contribute)
1. Clone this repo, and just use our data, its all pulled from another Repo thats automatically updated!

## How to set this up with your own local server
1. Install the server plugin [SignShopExport](https://github.com/Gamealition/SignShopExport) by RoyCurtis. This plugin is compatable with SignShop and Quickshop.
2. At the top of `mcshop.js`, edit the values of the two variables, `JSONUrl` and `dynmapURL` with your URLs
3. Upload all files to a web server. (NOTE: If MCShop is located on a different server than the JSON, you may run into some trouble, to fix this, add `Header set Access-Control-Allow-Origin "*"` to the .htaccess file in the directory that the JSON is located)

## How to Contribute
I (GodsDead) made a fork of a project called MCshop and am using the branch by gamealition, mostly only aesthetic work, but my Javascript is terrible, so I can't implement any of the features that would be great, so I need your help to contribute.

## Featured Shops
This is pure HTML added manually, make a pull request to update, I have no idea how were going to offer these spots yet.

## To-Do / Feature Request
1. Clean up the code. It's a mess.
2. Work well with SignShop item sets (currently quite buggy)
3. At certain screen widths, some longer item's names go outside of the item's card
4. (Feature Request) New page that is a statistics page, graphs (http://www.chartjs.org/) 