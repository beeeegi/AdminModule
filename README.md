# Admin Module
This project is a comprehensive Roblox Admin Commands System based on the new BanAPI. It includes functionalities for banning and unbanning players, checking player ban history, and retrieving player IDs, all integrated with Discord for notification and logging purposes.

## Features
`-` Temporarily or permanently ban players with a reason.

`-` Remove bans from players.

`-` Retrieve the ban history log file of a player.

`-` Retrieve a player's ID based on their username.

`-` Sends notifications to a Discord webhook for all actions.


## Installation
`0.` Download the module from [here](https://devforum.roblox.com/t/open-source-adminmodule-roblox-admin-commands-system-based-on-new-banapi/3064385)

`1.` Place **AdminModule** ModuleScript in the *ReplicatedStorage*.

`2.` Place **AdminModuleCommandHandler** ServerScript in the *ServerScriptService*.

`3.` Place **AdminModule** ScreenGui in the *StarterGui*.

`4.` Edit the **Config** ModuleScript.

`5.` Make sure that files are placed correctly, like in the screenshot:

![image](https://github.com/user-attachments/assets/abcfc352-5cdc-424e-968b-25ad6b078c4c)


## Usage

```
/ban <PlayerID> <Duration> <Reason>
```

`PlayerID` - The ID of the player to be banned.  [REQUIRED]

`Duration` - The duration of the ban (e.g., 10s, 5m, 2h, 1d). *Use -1 for permanent ban.*  [OPTIONAL]

`Reason` - The reason for the ban. [OPTIONAL]

```
/unban <PlayerID>
```

`PlayerID` - The ID of the player to be unbanned.  [REQUIRED]

```
/checkhistory <PlayerID>
```

`PlayerID` - The ID of the player whose ban history you want to check.  [REQUIRED]

```
/getid <Username>
```

`Username` - The username of the player whose ID you want to retrieve.  [REQUIRED]

### Example
To ban a player with ID 12345 for 10 minutes with the reason Spamming, an admin would type:
```
/ban 12345 10m Spamming
```

### Log Example

![image](https://github.com/user-attachments/assets/891f60c9-71f1-4df6-b5db-dce4a50a6613)

Updated version

![image](https://github.com/user-attachments/assets/69fe95fd-3808-4195-8628-95522067242b)

GUI

![image](https://github.com/user-attachments/assets/5b565306-928c-4b18-960d-0bd7422a802c)


## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/beeeegi/AdminModule/blob/main/LICENSE) file for details.

## Credits
Written by [Begi](https://github.com/beeeegi)

Special thanks to the Roblox Developer Community for the continuous support and resources.
