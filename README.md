# HatOnExit Script for FiveM – Configurable Vehicles

This FiveM script allows players to automatically remove and reapply their hat with an animation when exiting certain vehicles. The vehicles that trigger this behavior are fully configurable, allowing server admins to specify which vehicle models should activate the hat animation. This is perfect for roleplay scenarios such as law enforcement, fire, EMS, or any other custom vehicles.

## Features:
- **Hat Removal and Animation**: When the player exits a configured vehicle, their hat is removed, and after a short delay, an animation is played where the character "puts on" their hat.
- **Configurable Vehicles**: Admins can add or remove vehicle models that should trigger the hat animation by editing a simple configuration file (`config.lua`).
- **Double-Tap F Key Prevention**: If the player double-taps the F key (to quickly exit the vehicle), the animation is canceled for smoother gameplay.
- **Weapon Draw Check**: The animation is interrupted if the player draws a weapon during the animation, ensuring that combat scenarios aren’t hindered by the hat animation.
- **Manual Hat Reapplication**: If the player doesn't wear their hat after exiting the vehicle, they can manually put it back on by pressing the **E key**.

## Installation Instructions

1. **Download and Extract**: Download the resource files and place them into your FiveM server’s `resources` folder.
2. **Folder Name**: Ensure the folder is named something like `hat-on-exit` to avoid conflicts.
3. **Editing `config.lua`**:
   - Open `config.lua`.
   - Add or remove vehicle models from the `Config.AllowedVehicles` list. These are the vehicle models that will trigger the hat animation when a player exits them.
   - Example vehicle models: `"police"`, `"firetruk"`, `"ambulance"`, `"your_custom_model"`.
4. **Add to `server.cfg`**:
   - In your server configuration file (`server.cfg`), add `start hat-on-exit` to ensure the resource starts with your server.
5. **Restart Server**: Restart your server for the changes to take effect.

## Configuration (`config.lua`):

You can easily configure which vehicle models will trigger the hat animation when a player exits them. Simply edit the `config.lua` file to include the vehicle models you want.

```lua
Config = {}

-- List of vehicle models that the script works for
-- You can add any vehicle model name here
Config.AllowedVehicles = {
    "police",
    "police2",
    "police3",
    "police4",
    "firetruk",
    "ambulance",
    -- Add more vehicles as needed
}
```
- **To Add a Vehicle**: Simply add the vehicle model name to the list, using the exact model name as defined in your server.
- **To Remove a Vehicle**: Delete or comment out the vehicle model name from the list.

## How to Use:
1. When a player exits a vehicle listed in `Config.AllowedVehicles`, their hat will be removed, and a "putting on hat" animation will play.
2. If the player double-taps the F key to quickly exit the vehicle, the animation is canceled for smoother gameplay.
3. If the player draws a weapon while the animation is playing, the animation will be canceled.
4. Players can manually put their hat back on by pressing the **E key** if they aren't wearing one after exiting the vehicle.

## Example Use Cases:
- **Law Enforcement**: A police officer exits their patrol vehicle, removes their hat, and after a short delay, puts their hat back on via an animation.
- **Fire Department**: A firefighter exits a firetruck, and the same behavior applies.
- **Custom Vehicles**: This script can be extended to work with any custom vehicle model you want by simply adding the model to `Config.AllowedVehicles`.

## Important Notes:
- The script uses native vehicle model names in FiveM. Be sure to use the exact vehicle model names from the game or your custom vehicle pack.
- If players want the script to work for additional vehicles, they can easily add them to `config.lua`.
