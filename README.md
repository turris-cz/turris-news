Turris News
===========
This repository contains messages that are pulled by routers. They are intended as
a way to inform Turris router owners about planned changes and possible problems.

News are divided to channels and user can choose to be notified only about some of
them. At the moment following channels are defined:
* _news_: General channel mostly used for marketing purposes.
* _updates_: Channel with new Turris OS releases notifications and change lists.
* _rc_: Channel used for release candidate testers. It is used for same purpose as
  _updates_ but for release candidate branch.
* _maintain_: This channel contains various news for system administrators.
* _security_: Channel with security notices.

News format
-----------
News are just plain text files with some structured text. At the moment [plain
markdown](https://daringfireball.net/projects/markdown/syntax) is highly
suggested. Also please use 82 columns limit because these messages are also
displayed in their plain form in terminal.

Files with messages has to be placed in one of directories representing channels.
They should have following format: `YYMMDD-MESSAGE.md`. Where `YY` is used of
year, `MM` for month and `DD` for day of news release. `MESSAGE` have to be
basically title of news. It should not contain dots (`.`), dashes (`-`), and white
characters.

Messages should be written in English. There is also extension of this naming
format for translations, see section about that.

Notification system
-------------------
Tool `turris-news` automatically checks for new news on router and sends new ones
using notification system. To enable this feature you have to set
`turris_news.cron.enabled=1` in UCI. On top of that you have to set what channels
you want to track.

Example UCI configuration:
```
config cron 'cron'
	option enabled '1'
	list channel 'updates'
	list channel 'maintain'
	list channel 'security'
```

When notification is generated it also uses UCI option `foris.settings.lang` to
pull appropriate language (unless overwritten by `--lang` argument). Be aware that
every message is sent only once and that is when it is first seen and that can be
when there is no translation for it yet.

You can also set UCI option `turris_news.source.staging=1` which has same effect as
calling `turris-news --staging`.

Translations
------------
All news can be translated. That can be done just by copying original message and
to its name before format extension appending `.LANG`. As an example message with
general name `190811-new_module.md` translated to Czech should be placed in file
`190811-new_module.cs.md`.

Note that if you are changing original message that you should also change
translated version. Of course that it is not expected that author of message knows
all languages message is translated to. He rather should found correct position of
change using formating and change should be inserted in English.

Because of previous reasons in paragraph, it is highly requested that translators
should not change formating of message so original author can append new content
in English without understanding it.

Channel definition
------------------
List of channels is defined as variable `CHANNELS` at the beginning of the
`generate.sh` script. Every defined channel then should have its directory
containing at least `DESCRIPTION` file. That file should have following format:
```
Description
cs:Popis
de:Beschreibung
```
Where first line contains English description of given channel and all subsequent
lines should start with language code and colon separated translated description.

Deployment process
------------------
All news in this repository are automatically processed by our build server (using
`generate.sh` script) and deployed on staging URL. Final message is released by
copying staging content to final one.
