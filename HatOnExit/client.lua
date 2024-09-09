local isInEmergencyVehicle = false
local hasPlayedAnimation = false
local isPlayingAnimation = false
local hatModel = nil
local hatTexture = nil
local canReapplyHat = false -- Flag to allow reapplying the hat
local doubleTapF = false -- Flag for detecting double tap of "F"
local lastTapTime = 0 -- Time of the last "F" tap

-- Function to display text on the screen
function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Prevent crashing by waiting every frame

        local playerPed = PlayerPedId() -- Get the player's Ped
        local isInVehicle = IsPedInAnyVehicle(playerPed, false) -- Check if the player is in a vehicle
        local isInPoliceVehicle = IsPedInAnyPoliceVehicle(playerPed) -- Check if the player is in an emergency vehicle
        local currentTime = GetGameTimer() -- Get the current time for double-tap detection

        -- Detecting double-tap on "F" key
        if IsControlJustReleased(0, 23) then -- 23 corresponds to the "F" key
            if currentTime - lastTapTime < 300 then -- Double-tap detection within 300ms
                doubleTapF = true
            else
                doubleTapF = false
            end
            lastTapTime = currentTime
        end

        -- When the player is in an emergency vehicle
        if isInVehicle and isInPoliceVehicle then
            isInEmergencyVehicle = true
            hasPlayedAnimation = false -- Reset animation trigger when entering the vehicle
        end

        -- When the player exits an emergency vehicle
        if not isInVehicle and isInEmergencyVehicle and not hasPlayedAnimation and not isPlayingAnimation and not doubleTapF then
            -- Save the current hat (if any)
            hatModel = GetPedPropIndex(playerPed, 0) -- Save hat model
            hatTexture = GetPedPropTextureIndex(playerPed, 0) -- Save hat texture

            -- Only proceed with the animation if the player is wearing a hat
            if hatModel ~= -1 then
                isInEmergencyVehicle = false -- Reset the flag
                isPlayingAnimation = true -- Prevent re-triggering the animation
                canReapplyHat = false -- Reset the reapply flag

                -- Remove the hat (or any head prop) on exit
                ClearPedProp(playerPed, 0)

                -- Start the helmet-wearing animation
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
                Citizen.Wait(1200)

                -- If the animation wasn't interrupted by drawing a weapon, apply the hat
                if isPlayingAnimation then
                    SetPedPropIndex(playerPed, 0, hatModel, hatTexture, true) -- Apply the saved hat
                end

                -- Mark the animation as finished and reset the flag
                hasPlayedAnimation = true
                isPlayingAnimation = false
            end
        end

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