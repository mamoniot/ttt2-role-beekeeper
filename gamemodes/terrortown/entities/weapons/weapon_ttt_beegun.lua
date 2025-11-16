if SERVER then
    AddCSLuaFile()
end

if CLIENT then
    SWEP.PrintName = "Beegun"
    SWEP.Author = "Monica Moniot"
    SWEP.Contact = "";
    SWEP.Instructions = "Left click to place a bee at your cursor"
    SWEP.Slot = 9
    SWEP.SlotPos = 1
    SWEP.ViewModelFOV = 70
    -- SWEP.IconLetter = "M"
    -- SWEP.ViewModelFlip = true
    SWEP.DrawCrossHair = true
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Delay = 10
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Primary.Sound = Sound( "Metal.SawbladeStick" )
SWEP.ReloadSound = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.FiresUnderwater = true

SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = nil
SWEP.LimitedStock = false
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.InLoadoutFor = nil --<--
SWEP.Kind = WEAPON_EQUIP

-- SWEP.Weight = 7
-- SWEP.DrawAmmo = true

-- local ShootSound = Sound( "Metal.SawbladeStick" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 1 )

    if not SERVER then return end

    -- if self:Clip1() > 0 then
    --     self:TakePrimaryAmmo(1)

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
    -- else
    --     self:EmitSound("Weapon_AR2.Empty")
    -- end
end

function SpawnNPC( Position, Class )

	local NPCList = list.Get( "NPC" )
	local NPCData = NPCList[ Class ]

	-- Don't let them spawn this entity if it isn't in our NPC Spawn list.
	-- We don't want them spawning any entity they like!
	if ( !NPCData ) then
        Player:SendLua( "Derma_Message( \"Sorry! You can't spawn that NPC!\" )" );
	return end

	local bDropToFloor = false

	--
	-- This NPC has to be spawned on a ceiling ( Barnacle )
	--
	if ( NPCData.OnCeiling && Vector( 0, 0, -1 ):Dot( Normal ) < 0.95 ) then
		return nil
	end

	if ( NPCData.NoDrop ) then bDropToFloor = false end

	--
	-- Offset the position
	--


	-- Create NPC
	local NPC = ents.Create( NPCData.Class )
	if ( !IsValid( NPC ) ) then return end

	NPC:SetPos( Position )
	--
	-- This NPC has a special model we want to define
	--
	if ( NPCData.Model ) then
		NPC:SetModel( NPCData.Model )
	end

	--
	-- Spawn Flags
	--
	local SpawnFlags = bit.bor( SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
	if ( NPCData.SpawnFlags ) then SpawnFlags = bit.bor( SpawnFlags, NPCData.SpawnFlags ) end
	if ( NPCData.TotalSpawnFlags ) then SpawnFlags = NPCData.TotalSpawnFlags end
	NPC:SetKeyValue( "spawnflags", SpawnFlags )

	--
	-- Optional Key Values
	--
	if ( NPCData.KeyValues ) then
		for k, v in pairs( NPCData.KeyValues ) do
			NPC:SetKeyValue( k, v )
		end
	end

	--
	-- This NPC has a special skin we want to define
	--
	if ( NPCData.Skin ) then
		NPC:SetSkin( NPCData.Skin )
	end

	--
	-- What weapon should this mother be carrying
	--

	NPC:Spawn()
	NPC:Activate()

	if ( bDropToFloor && !NPCData.OnCeiling ) then
		NPC:DropToFloor()
	end

	return NPC
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

-- function SWEP:Reload()
--     return false
-- end
