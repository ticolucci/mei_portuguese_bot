# Goal

Provide a "Babel Fish" like telegram bot, where you install in your telegram account, then in a group of foreign language. Then the bot forwards a translated message to your chat with the bot.

## What works so far

* If you manually register the id of the telegram chat of the account with the bot in the db of the app, then you can add the bot to a group of Brazilians. Each text message posted there will be translated to english and posted to the bot chat.

## Roadmap:

* Specs!
* REFACTORING
* MORE refactoring
* Register and Unregister bot through messages (`/start_mei_bot`, `/end_mei_bot`)
* Support Stickers
* Support Files
* When user publishes msg in the "main group", they should not receive their own translation
* User should be able to register a group. So that they can post messages in :en to the bot, and the bot forwards to the group in :pt
* Make the bot universal (create relationships between User -> Group, Group -> User). So that the bot can be used by more people simultaneously
