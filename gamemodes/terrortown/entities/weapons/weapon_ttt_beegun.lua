if SERVER then
    AddCSLuaFile()
end

if CLIENT then
    SWEP.PrintName = "Bee gun"
    SWEP.Author = "Monica Moniot"
    SWEP.Contact = "";
    SWEP.Instructions = "Left click to place a bee at your crosshair"
    SWEP.Slot = 9
    SWEP.SlotPos = 1
    SWEP.ViewModelFOV = 70
    -- SWEP.IconLetter = "M"
    SWEP.ViewModelFlip = false
    SWEP.DrawCrossHair = true
	SWEP.UseHands = true
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Ammo = "none"
-- SWEP.Primary.Recoil = 1.04
-- SWEP.Primary.Cone = 0.025
-- SWEP.Primary.Damage = 17

SWEP.Primary.Delay = 0.5
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 7
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = 7

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Sound = Sound("Default.Zoom")
SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)
SWEP.Primary.Sound = Sound("Metal.SawbladeStick")

SWEP.HoldType = "ar2"
SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_aug.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_aug.mdl")

SWEP.ReloadSound = ""
SWEP.FiresUnderwater = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.UseHands = true
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = nil
SWEP.LimitedStock = false
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.InLoadoutFor = nil --<--
SWEP.Kind = WEAPON_EQUIP

local reload_time = 3.7;
local clip_empty_sound = Sound("Weapon_AR2.Empty");

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if self:Clip1() <= 0 then
        self:EmitSound(clip_empty_sound)
		return
	end

	self:EmitSound(self.Primary.Sound)

    if not SERVER then return end

	self:TakePrimaryAmmo(1)

    local myPosition = self.Owner:EyePos()
    local data = EffectData()
    data:SetOrigin(myPosition)

    util.Effect("MuzzleFlash", data)

    local tr = self.Owner:GetEyeTrace()
    local spos = tr.HitPos + Vector(0,0,2);

    local headbee = ents.Create("npc_manhack")
    if not IsValid(headbee) then return end

    headbee:SetPos(spos)
    headbee:Spawn()
    headbee:Activate()

    headbee:SetNPCState(2)

    local bee = ents.Create("prop_dynamic")
    bee:SetModel("models/lucian/props/stupid_bee.mdl")
    bee:SetPos(spos)
    bee:SetAngles(Angle(0,0,0))
    bee:SetParent(headbee)

    headbee:SetNWEntity("Thrower", self.Owner)
    headbee:SetNoDraw(true)
    headbee:SetHealth(1000)
end

function SWEP:SecondaryAttack()
	if (self.IronSightsPos and self:GetNextSecondaryFire() <= CurTime()) then
		-- set the delay for left and right click
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		local bIronsights = not self:GetIronsights()
		self:SetIronsights(bIronsights)
		if SERVER then
			self:SetZoom(bIronsights)
		else
			self:EmitSound(self.Secondary.Sound)
		end
	end
end

function SWEP:SetZoom(state)
	if not SERVER then return end
	local player = self:GetOwner()
	if IsValid(player) and player:IsPlayer() then
		if state then
			player:SetFOV(20, 0.3)
		else
			player:SetFOV(0, 0.2)
		end
	end
end

function SWEP:ResetIronSights()
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:PreDrop()
	self:ResetIronSights()
	return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
	self:ResetIronSights()
	return true
end

function SWEP:Reload()
	if self:Clip1() < self.Primary.ClipSize then
		self:ResetIronSights()
		self:SetNextPrimaryFire(CurTime() + reload_time)
		self:SetNextSecondaryFire(CurTime() + reload_time)
		self:SetClip1(self.Primary.ClipSize)
		self:SendWeaponAnim(ACT_VM_RELOAD)
	end
end

-- draw the scope on the HUD
if CLIENT then
	local scope = surface.GetTextureID("sprites/scope")
	function SWEP:DrawHUD()
		if self:GetIronsights() then
			surface.SetDrawColor(0, 0, 0, 255)

			local x = ScrW() / 2.0
			local y = ScrH() / 2.0
			local scope_size = ScrH()

			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			gap = 0
			length = 50
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			surface.SetDrawColor(231, 197, 0)
			surface.DrawLine(x, y, x + 1, y + 1)

			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		else
			return self.BaseClass.DrawHUD(self)
		end
	end

	function SWEP:AdjustMouseSensitivity()
		return (self:GetIronsights() and 0.2) or nil
	end
end
