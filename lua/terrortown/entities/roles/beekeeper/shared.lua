if SERVER then
  AddCSLuaFile()
  resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_beekeeper.vmt")
end

local flags = {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}
CreateConVar("ttt2_beekeeper_damage_mult", 0.0, flags)
CreateConVar("ttt2_beekeeper_damage_mult_last_stand", 0.5, flags)

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

  local cur_dmg_mult = {}
  local base_dmg_mult = 0.0
  local last_stand_dmg_mult = 0.0

  hook.Add("TTTBeginRound", "BeekeeperSelected", function()
    cur_dmg_mult = {}
    base_dmg_mult = GetConVar("ttt2_beekeeper_damage_mult"):GetFloat() or 1.0
    last_stand_dmg_mult = GetConVar("ttt2_beekeeper_damage_mult_last_stand"):GetFloat() or 1.0
  end)

  hook.Add("PlayerTakeDamage", "BeekeeperDealDamage", function(ply, inflictor, killer, amount, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetSubRole() ~= ROLE_BEEKEEPER then return end

    -- Allow beekeepers to use explosive weapons.
    if dmginfo:IsDamageType(DMG_BLAST) then return end

    dmginfo:ScaleDamage(cur_dmg_mult[attacker:UserID()] or base_dmg_mult)
  end)

  local function CheckLastStand(dead_ply)
    local all_players = player.GetAll()
    for _, beekeeper in ipairs(all_players) do
      if beekeeper:Alive() and not beekeeper:IsSpec() and beekeeper:GetSubRole() == ROLE_BEEKEEPER then
        local beekeeper_id = beekeeper:UserID()
        if not cur_dmg_mult[beekeeper_id] then
          local beekeeper_team = beekeeper:GetTeam()
          if not dead_ply or dead_ply:GetTeam() == beekeeper_team then
            local is_last_standing = true
            for _, ply in ipairs(all_players) do
              if ply:Alive() and not ply:IsSpec() and ply:GetTeam() == beekeeper_team then
                is_last_standing = false
                break
              end
            end
            if is_last_standing then
              cur_dmg_mult[beekeeper_id] = last_stand_dmg_mult

              local body
              if base_dmg_mult < last_stand_dmg_mult then
                body = "ttt2_beekeeper_last_stand_body_inc"
              else
                body = "ttt2_beekeeper_last_stand_body_dec"
              end
              EPOP:AddMessage(
                beekeeper,
                {
                  text = LANG.TryTranslation("ttt2_beekeeper_last_stand_title")
                },
                LANG.GetParamTranslation(body, {multi = last_stand_dmg_mult}),
                6
              )
            end
          end
        end
      end
    end
  end

  hook.Add("PlayerDisconnected", "BeekeeperLastStandDisconnect", CheckLastStand)
  hook.Add("TTT2PostPlayerDeath", "BeekeeperLastStandDeath", CheckLastStand)
  hook.Add("PlayerSpawn", "BeekeeperLastStandSpawn", function(ply)
    if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
    if ply:GetSubRole() == ROLE_BEEKEEPER then
      CheckLastStand(nil)
    end
  end)
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

    form:MakeSlider({
      serverConvar = "ttt2_beekeeper_damage_mult_last_stand",
      label = "label_ttt2_beekeeper_damage_mult_last_stand",
      min = 0.0,
      max = 1.0,
      decimal = 2,
    })
  end
end
