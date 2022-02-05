UI = {}

function UI.DrawText3D(coords, text, colourData)
	colourData = colourData or {255, 255, 255, 255}
	local size = 1
	local font = 4
    local scale = 0.75
	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextColour(colourData[1], colourData[2], colourData[3], colourData[4])
	-- SetTextDropshadow(255, 255, 255, 255, 255)
	SetTextDropShadow()
	SetTextCentre(true)
	SetTextProportional(1)
	SetDrawOrigin(coords, 0)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end


function UI.DrawSprite3d(data)
    local dist = #(GetGameplayCamCoords().xy - data.pos.xy)
    local fov = (1 / GetGameplayCamFov()) * 250
    -- local scale = ((1 / dist) * 2) * fov
    local scale = 0.3
    SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
	if not HasStreamedTextureDictLoaded(data.textureDict) then
		local timer = 1000
		RequestStreamedTextureDict(data.textureDict, true)
		while not HasStreamedTextureDictLoaded(data.textureDict) and timer > 0 do
			timer = timer-1
			Citizen.Wait(100)
		end
	end
    DrawSprite(
        data.textureDict,
        data.textureName,
        (data.x or 0) * scale,
        (data.y or 0) * scale,
        data.width * scale,
        data.height * scale,
        data.heading or 0,
        data.r or 0,
        data.g or 0,
        data.b or 0,
        data.a or 255
    )
    ClearDrawOrigin()
end

