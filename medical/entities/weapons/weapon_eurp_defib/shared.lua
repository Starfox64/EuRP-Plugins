AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.Spawnable = true

SWEP.PrintName = "Defibrillator"
SWEP.Author = "_FR_Starfox64"
SWEP.Contact = ""

SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.ViewModel = "models/v_models/v_defibrillator.mdl" -- Models are from L4D2
SWEP.WorldModel = "models/w_models/weapons/w_eq_defibrillator.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 45
SWEP.HoldType = "slam"

SWEP.SwayScale = .25

SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 3
SWEP.Primary.Range = 500
SWEP.Primary.Cone = .01
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Sound = "weapons/defibrillator/defibrillator_use_start.wav"
SWEP.Primary.HitSound = "weapons/defibrillator/defibrillator_use.wav"

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 0

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false

SWEP.FallbackMat = "models/v_models/weapons/eq_defibrillator/defibrillator"

function SWEP:Initialize()
	self:SetDeploySpeed(1)
	self:SetWeaponHoldType(self.HoldType)
	self:SetMaterial(self.FallbackMat)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if (SERVER) then
		local data = {}
		data.start = self:GetOwner():GetShootPos()
		data.endpos = data.start + self:GetOwner():GetAimVector() * 84
		data.filter = self:GetOwner()
		local trace = util.TraceLine(data)
		local entity = trace.Entity
		if entity:IsValid() then
			if entity:GetNWBool("Body") and entity.player:IsValid() then
				if !entity.player.character.stabilized then
					local player = entity.player
					self:GetOwner():Freeze(true)
					self:GetOwner():EmitSound(self.Primary.Sound, 100, 100)
					timer.Simple(3, function()
						self:GetOwner():Freeze(false)
						entity.player:SetNutVar("deathTime", player:GetNutVar("deathTime") + 180)
						entity:SetNWFloat("Time", entity:GetNWFloat("Time") + 180)
						player.character.stabilized = true
						nut.util.Notify("Victim stabilized!", self:GetOwner())
						player:SendLua("nut.bar.mainFinish = nut.bar.mainFinish + 180")
						self:GetOwner():EmitSound(self.Primary.HitSound, 100, 100)
					end)
				else
					nut.util.Notify("The victim was already stabilized.", self:GetOwner())
				end
			else
				nut.util.Notify("You must be looking at an unconscious citizen!", self:GetOwner())
			end
		else
			nut.util.Notify("You must be looking at an unconscious citizen!", self:GetOwner())
		end
	end
end

/*---------------
WORLDMODEL-FIXING UTILITY CODE
ORIGINALLY BY ROBOTBOY
----------------*/
SWEP.FixWorldModel = true

SWEP.FixWorldModelPos = Vector(2.675, -0.596, -1.557)

SWEP.FixWorldModelAng = Angle(122.208, 134.936, -150.376)

SWEP.FixWorldModelScale = 1

function SWEP:DoFixWorldModel()
    if ( IsValid( self.Owner ) ) then
        local att = self.Owner:GetAttachment( self.Owner:LookupAttachment( "anim_attachment_RH" ) )
        if ( !att ) then return end
        local pos, ang = att.Pos, att.Ang
        ang:RotateAroundAxis( ang:Forward(), self.FixWorldModelAng.p )
        ang:RotateAroundAxis( ang:Right(), self.FixWorldModelAng.y )
        ang:RotateAroundAxis( ang:Up(), self.FixWorldModelAng.r )
        pos = pos + ang:Forward() * self.FixWorldModelPos.x + ang:Right() * self.FixWorldModelPos.y + ang:Up() * self.FixWorldModelPos.z
        self:SetModelScale( self.FixWorldModelScale, 0 )
        self:SetRenderOrigin( pos )
        self:SetRenderAngles( ang )
    else
        self:SetRenderOrigin( self:GetNetworkOrigin() )
        self:SetRenderAngles( self:GetNetworkAngles() )
    end
end

function SWEP:DrawWorldModel()
    if ( self.FixWorldModel ) then self:DoFixWorldModel() end
    self:DrawModel()
end

--self.Owner:GetAttachment( self.Owner:LookupAttachment( "anim_attachment_RH" ) )