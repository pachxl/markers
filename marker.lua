-- raycasting helper functions

local function RotationToDirection(rotation)
	local adjustedRotation = { 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = { 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end

local function createBlip(coords)
    local blip = AddBlipForCoord(coords) SetBlipSprite(blip, 148) SetBlipScale(blip, 0.25) SetBlipColour(blip, 1) 
    return blip 
end



-- markers

local markerActive = false


local config = {
    markerShowDistance = 100.0, -- markers start showing over 100m
    markerDeleteDistance = 5.0, -- marker will delete when distance is under 5m
    showTime = 10000, -- 10 seconds default
    entities = {
        [2] = {follow = true},
        [1] = {follow = true},
    }
}

local function createMarker()

    -- delete the previous marker
    if markerActive == true then 
        markerActive = false 
        Wait(0) -- wait one tick for the loop to complete otherwise the previous marker wont delete
    end

    local followEntity = false -- default values
    local _, coords, entity = RayCastGamePlayCamera(1000.0)

    if coords == vector3(0.0, 0.0, 0.0) then -- sometimes this happens
        return 
    end

    local dist = #(GetEntityCoords(PlayerPedId()) - coords)
    if dist < config.markerDeleteDistance then -- check if the marker is too close, then delete
        return
    end

    if config.entities[GetEntityType(entity)] ~= nil then 
        followEntity = (config.entities[GetEntityType(entity)].follow == true) 
    end

    local blip = createBlip(coords) -- marker blip
    PlaySoundFrontend(-1, "10_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", true) -- beep sound
    markerActive = true
    local now = GetGameTimer()

    while (GetGameTimer() - now < config.showTime) and (markerActive == true) do 
        Wait(0)
        if DoesEntityExist(entity) == false then -- delete when entity is gone
            markerActive = false 
        end
        if followEntity == true then
            coords = GetEntityCoords(entity) -- set the coords to the coords of the entity
            SetBlipCoords(blip, coords)
        end 
        dist = #(GetEntityCoords(PlayerPedId()) - coords) -- distance from marker
        if dist < config.markerDeleteDistance then  -- if you walk too close to the marker it goes 
            markerActive = false  
        end 
        if dist > config.markerShowDistance then 
            -- draw marker
            DrawMarker(1, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 100.0, 255, 0, 150, 75, false, true, 2, nil, nil, false)
        else
            -- draw sprite 
            UI.DrawSprite3d({
                pos = coords + vector3(0.0, 0.0, dist/100), -- place the sprite slightly above the distance text
                textureDict = 'markers',
                textureName = 'genericBlip',
                width = 0.06,
                height = 0.1,
                r = 255,
                g = 0,
                b = 150,
                a = 255
            })
        end
        -- distance text 
        UI.DrawText3D(coords, tostring(math.floor(dist))..'m')
    end
    RemoveBlip(blip)
end
RegisterCommand('marker', createMarker)

