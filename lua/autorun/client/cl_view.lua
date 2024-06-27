local blacklist = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["weapon_medkit"] = true,
    ["manhack_welder"] = true,
    ["gmod_camera"] = true,
    ["weapon_physcannon"] = true,
}

local CAMERA_TOGGLE = true 

function CAMERATOGGLE()
    CAMERA_TOGGLE = not CAMERA_TOGGLE
    print('Camera mode: ' .. (CAMERA_TOGGLE and "enabled" or "disabled"))
end

local function AngleDifference(a, b)
    return math.abs(math.AngleDifference(a.p, b.p)) + math.abs(math.AngleDifference(a.y, b.y)) + math.abs(math.AngleDifference(a.r, b.r))
end

local function IsWeaponBlacklisted(weapon)
    if not IsValid(weapon) then return false end
    local class = weapon:GetClass()
    return blacklist[class]
end

local currentHandOffset = Vector(0, 0, 0)
local currentHandAngle = Angle(0, 0, 0)

local function CAMERA_PLAYER(ply, pos, ang, fov)
    if not CAMERA_TOGGLE then return end
    if not ply:Alive() then return end
    
    local weapon = ply:GetActiveWeapon()
    if not weapon or IsWeaponBlacklisted(weapon) then return end
    
    local head = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if not head then return end
    
    local eyePos = head.Pos + head.Ang:Forward() * -2
    local headAng = head.Ang

    headAng.pitch = math.ApproachAngle(headAng.pitch, 0, 5)
    headAng.roll = math.ApproachAngle(headAng.roll, 0, 20)

    if not ply.LastHeadAng then
        ply.LastHeadAng = headAng
    end

    local distance = AngleDifference(headAng, ply.LastHeadAng)
    local lerpSpeed = 0.1

    if distance > 10 then
        lerpSpeed = 0.9
    end

    local finalang = LerpAngle(lerpSpeed * FrameTime(), ply.LastHeadAng, headAng)
    ply.LastHeadAng = finalang

    local finalpos = eyePos

    if ply:KeyDown(IN_ATTACK2) then 
        local offset = aimOffset[weapon:GetClass()]
        if offset then
            finalpos = finalpos + offset.pos 
            finalang = finalang + offset.ang

            local handBone = ply:LookupBone("ValveBiped.Bip01_R_Clavicle")
            if handBone then
                ply:ManipulateBonePosition(handBone, offset.handPos)
                ply:ManipulateBoneAngles(handBone, offset.handAng)
                currentHandOffset = offset.handPos
                currentHandAngle = offset.handAng
            end
        end
    else

        local handBone = ply:LookupBone("ValveBiped.Bip01_R_Clavicle")
        if handBone then
            ply:ManipulateBonePosition(handBone, Vector(0, 0, 0))
            ply:ManipulateBoneAngles(handBone, Angle(0, 0, 0))
            currentHandOffset = Vector(0, 0, 0)
            currentHandAngle = Angle(0, 0, 0)
        end
    end

    local headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
    ply:ManipulateBoneScale(headBone, Vector(0.001, 0.001, 0.001))

    local view = {
        origin = finalpos,
        angles = finalang,
        fov = fov,
        drawviewer = true,
    }
    return view
end

hook.Add("CalcView", "REALISTIC_CAMERA", CAMERA_PLAYER)
concommand.Add("camera", CAMERATOGGLE)
