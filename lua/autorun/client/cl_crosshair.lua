include('cl_view.lua')

local crosshairSize = 20
local maxDistance = 350
local minDistance = 5 

hook.Add("PostDrawTranslucentRenderables", "Draw3DCrosshair", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or WEAPON_BLACKLIST(weapon) then return end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = ply
    })

    local hitPos = tr.HitPos
    local hitNormal = tr.HitNormal
    local distance = ply:GetPos():Distance(hitPos)

    if distance > maxDistance or distance < minDistance then return end

    local ang = hitNormal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)

    cam.Start3D2D(hitPos, ang, 0.1)
        local size = crosshairSize
        local halfSize = size / 1

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawCircle(0, 0, halfSize, 255, 255, 255, 255)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawLine(-1, 0, 1, 0)
        surface.DrawLine(0, -1, 0, 1)
    cam.End3D2D()
end)


hook.Add("HUDPaint", "DrawScreenCrosshair", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or WEAPON_BLACKLIST(weapon) then return end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = ply
    })

    local hitPos = tr.HitPos
    local distance = ply:GetPos():Distance(hitPos)

    if distance <= maxDistance and distance >= minDistance then return end

    local hitScreenPos = hitPos:ToScreen()

    local size = crosshairSize
    local halfSize = size / 2

    surface.SetDrawColor(255, 255, 255, 255) 
    surface.DrawCircle(hitScreenPos.x, hitScreenPos.y, halfSize, 255, 255, 255, 255)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawLine(hitScreenPos.x - 1, hitScreenPos.y, hitScreenPos.x + 1, hitScreenPos.y)
    surface.DrawLine(hitScreenPos.x, hitScreenPos.y - 1, hitScreenPos.x, hitScreenPos.y + 1)
end)


hook.Add("Think", "CrosshairRecoil", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or WEAPON_BLACKLIST(weapon) then return end

    if ply:KeyDown(IN_ATTACK) then
        crosshairSize = math.min(crosshairSize + 1, 20)
    else
        crosshairSize = math.max(crosshairSize - 0.5, 10)
    end
end)
