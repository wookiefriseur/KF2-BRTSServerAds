# KF2-BRTSServerAds
Brutus ServerAds ServerActor (original from FZFalzar) https://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/general-modding-discussion-ad/beta-mod-releases/109273-mutator-brutus-serverads-serveractor

### About this Project ###
Name:       |  BRTSServerAds
----------- |   -----------
Author:   | FZFalzar (Original author)
Source: 	|   [Original version from FZFalzar](https://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/general-modding-discussion-ad/beta-mod-releases/109273-mutator-brutus-serverads-serveractor)
Homepage: | [Thread in TWI forums](https://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/general-modding-discussion-ad/beta-mod-releases/109273-mutator-brutus-serverads-serveractor)


### Dependencies and Files ###

* Configs:
	- KFBRTSServerAds.ini
  
### How To ###

* Edit PCServer-KFGame.ini or set in Webinterface:
	- `ServerActors=IpDrv.WebServer`
	- `ServerActors=BRTSServerAds.BRTSServerAds`
* Messages can be added in the ini

Wildcard:			|	Description:
-------------------:|---------------------
`{SERVERNAME}`		| server name as seen on the server browser
`{DAY}` 			| server time (Day) 	> 1-31
`{MTH}` 			| server time (Month)   > 1-12
`{YR}`				| server time (Year)    > XXXX
`{HR}`           	| server time (Hour)    > 00-23
`{MIN}`          	| server time (Min)     > 00-59
`{SEC}`          	| server time (Second)  > 00-59
`{AMPM}`         	| AM/PM (refer to NOTE)
`{SDAY}`         	| day as its respective name e.g Monday, Wednesday
`{SMTH}`         	| month as its respective name e.g January, February
`{MAPNAME}`      	| current map name
`{PLAYERCOUNT}`  	| number of players currently on the server
`{SERVERSLOTS}`  	| number of slots the server has
