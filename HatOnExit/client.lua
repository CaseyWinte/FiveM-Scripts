local isInAllowedVehicle = false
local hasPlayedAnimation = false
local isPlayingAnimation = false
local hatModel = nil
local hatTexture = nil
local canReapplyHat = false -- Flag to allow reapplying the hat
local doubleTapF = false -- Flag for detecting double tap of "F"
local lastTapTime = 0 -- Time of the last "F" tap
local hatRemoved = false -- Flag to control hat removal timing
local wasInVehicleLastFrame = false -- Flag to detect vehicle exit more reliably
local doubleTapCooldown = false -- Flag to track double-tap exit cooldown

-- Load the config
local Config = Config or {}

-- Function to display text on the screen
function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Function to check if the vehicle is in the allowed list
function IsAllowedVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    for _, allowedModel in ipairs(Config.AllowedVehicles) do
        if model == GetHashKey(allowedModel) then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId() -- Get the player's Ped
        local isInVehicle = IsPedInAnyVehicle(playerPed, false) -- Check if the player is in a vehicle
        local vehicle = GetVehiclePedIsIn(playerPed, false) -- Get the vehicle the player is in
        local currentTime = GetGameTimer() -- Get the current time for double-tap detection

        -- Detecting double-tap on "F" key
        if IsControlJustReleased(0, 23) then -- 23 corresponds to the "F" key
            if currentTime - lastTapTime < 300 then -- Double-tap detection within 300ms
                doubleTapF = true
                doubleTapCooldown = true -- Set cooldown to avoid running the animation after re-entering the vehicle
                Citizen.SetTimeout(2000, function()
                    doubleTapCooldown = false -- Reset cooldown after 2 seconds
                end)
            else
                doubleTapF = false
            end
            lastTapTime = currentTime
        end

        -- Check if the player has just exited the vehicle
        if wasInVehicleLastFrame and not isInVehicle and isInAllowedVehicle and not hasPlayedAnimation and not doubleTapF then
            -- The player has just exited an allowed vehicle, so trigger the animation if double-tap F wasn't used

            -- Remove the hat if necessary
            if not hatRemoved then
                hatModel = GetPedPropIndex(playerPed, 0) -- Save hat model
                hatTexture = GetPedPropTextureIndex(playerPed, 0) -- Save hat texture

                -- Remove the hat if the player is wearing one
                if hatModel ~= -1 then
                    ClearPedProp(playerPed, 0) -- Remove the hat immediately
                    hatRemoved = true -- Mark the hat as removed
                end
            end

            -- Wait briefly to ensure the player has fully exited
            Citizen.Wait(800)

            -- Only proceed with the animation if the player was wearing a hat
            if hatModel ~= -1 then
                isInAllowedVehicle = false -- Reset the flag
                isPlayingAnimation = true -- Prevent re-triggering the animation
                canReapplyHat = false -- Reset the reapply flag

                -- Load the animation dictionary
                RequestAnimDict("missheistdockssetup1hardhat@")
                while not HasAnimDictLoaded("missheistdockssetup1hardhat@") do
                    Citizen.Wait(0)
                end

                -- Play animation to put on the helmet (simulates putting on a hat)
                TaskPlayAnim(playerPed, "missheistdockssetup1hardhat@", "put_on_hat", 8.0, -8.0, 2000, 49, 0, false, false, false)

                -- Check if player is drawing a weapon during the animation
                Citizen.CreateThread(function()
                    while isPlayingAnimation do
                        Citizen.Wait(0)
                        if IsPedArmed(playerPed, 7) then -- Checks if the player is trying to draw any weapon
                            ClearPedTasksImmediately(playerPed) -- Instantly stops the animation
                            isPlayingAnimation = false -- Stop the animation flag
                            canReapplyHat = true -- Allow the player to reapply the hat
                            return -- Exit this thread
                        end
                    end
                end)

                -- Wait for the animation to complete before applying the hat
                Citizen.Wait(1200) -- Adjusted wait time to 1200ms

                -- Reapply the hat after the animation is complete
                if isPlayingAnimation then
                    SetPedPropIndex(playerPed, 0, hatModel, hatTexture, true) -- Apply the saved hat
                end

                -- Mark the animation as finished and reset the flag
                hasPlayedAnimation = true
                isPlayingAnimation = false
            end
        end

        -- Check if the player just entered an allowed vehicle
        if isInVehicle and IsAllowedVehicle(vehicle) and not doubleTapCooldown then -- Ensure no animation runs after double-tap F
            isInAllowedVehicle = true
            hasPlayedAnimation = false -- Reset animation trigger
            hatRemoved = false -- Reset the hat removal flag
        end

        -- Update the `wasInVehicleLastFrame` flag to track vehicle entry and exit more reliably
        wasInVehicleLastFrame = isInVehicle

        -- Show the message if the player can reapply their hat
        if canReapplyHat and hatModel ~= -1 then
            ShowHelpText("Press ~INPUT_CONTEXT~ to put your hat back on.")
            
            -- Check if the player presses the E key
            if IsControlJustReleased(0, 38) then -- 38 corresponds to the "E" key
                SetPedPropIndex(playerPed, 0, hatModel, hatTexture, true) -- Apply the saved hat
                canReapplyHat = false -- Reset the flag after the hat is reapplied
            end
        end
    end
end)
