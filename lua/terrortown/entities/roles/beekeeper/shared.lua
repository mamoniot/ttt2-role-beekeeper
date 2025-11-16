if SERVER then
  AddCSLuaFile()
  resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_beekeeper.vmt")
end

local flags = {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}
CreateConVar("ttt2_beekeeper_damage_mult", 0.0, flags)

function ROLE:PreInitialize()
  self.color = Color(231, 197, 0)

  self.abbr = "beekeeper"

  self.defaultTeam = TEAM_TRAITOR
  self.defaultEquipment = TRAITOR_EQUIPMENT
  self.preventWin = false
  self.unknownTeam = false

  self.score.surviveBonusMultiplier = 0.5
  self.score.timelimitMultiplier = -0.5
  self.score.killsMultiplier = 2
  self.score.teamKillsMultiplier = -2
  self.score.bodyFoundMuliplier = 0

  self.preventFindCredits = false
  self.preventKillCredits = false
  self.preventTraitorAloneCredits = false

  self.isOmniscientRole = true

  self.conVarData = {
    pct = 0.15, -- necessary: percentage of getting this role selected (per player)
    maximum = 1, -- maximum amount of roles in a round
    minPlayers = 4, -- minimum amount of players until this role is able to get selected
    credits = 3, -- the starting credits of a specific role
    traitorButton = 1, -- can use traitor buttons
    ragdollPinning = 1,
    shopFallback = SHOP_FALLBACK_TRAITOR,
    creditsAwardDeadEnable = 1,
    creditsAwardKillEnable = 1,
    togglable = true, -- option to toggle a role for a client if possible (F1 menu)
    random = 48,
  }
end

function ROLE:Initialize()
  roles.SetBaseRole(self, ROLE_TRAITOR)
end

if SERVER then
  function ROLE:GiveRoleLoadout(ply, isRoleChange)
    ply:GiveEquipmentWeapon("weapon_ttt_beegun")
  end

  function ROLE:RemoveRoleLoadout(ply, isRoleChange)
    ply:StripWeapon("weapon_ttt_beegun")
  end

  local function BeekeeperDealDamage(ply, inflictor, killer, amount, dmginfo)
    -- Allow beekeepers to use explosive weapons.
    if dmginfo:IsDamageType(DMG_BLAST) then return end

    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetSubRole() ~= ROLE_BEEKEEPER then return end

    dmginfo:ScaleDamage(GetConVar("ttt2_beekeeper_damage_mult"):GetFloat() or 1.0)
  end
  hook.Add("PlayerTakeDamage", "BeekeeperDealDamage", BeekeeperDealDamage)
end

if CLIENT then
  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

    form:MakeSlider({
      serverConvar = "ttt2_beekeeper_damage_mult",
      label = "label_ttt2_beekeeper_damage_mult",
      min = 0.0,
      max = 1.0,
      decimal = 2,
    })
  end
end
