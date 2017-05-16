----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W.
----------------------------------------------------------------------------
--------------------------------------
-- General Initialization
--------------------------------------

require(GetScriptDirectory() ..  "/utility")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")

local debugmode=false
local ARCANE_ORB_STATUS = false
local npcBot = GetBot()
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}

--ability_item_usage_generic.InitAbility(Abilities,AbilitiesReal,Talents) 

table.insert(Abilities,"obsidian_destroyer_arcane_orb")
table.insert(Abilities,"obsidian_destroyer_astral_imprisonment")
table.insert(Abilities,"obsidian_destroyer_essence_aura")
table.insert(Abilities,"obsidian_destroyer_sanity_eclipse")

table.insert(AbilitiesReal,npcBot:GetAbilityByName("obsidian_destroyer_arcane_orb"))
table.insert(AbilitiesReal,npcBot:GetAbilityByName("obsidian_destroyer_astral_imprisonment"))
table.insert(AbilitiesReal,npcBot:GetAbilityByName("obsidian_destroyer_essence_aura"))
table.insert(AbilitiesReal,npcBot:GetAbilityByName("obsidian_destroyer_sanity_eclipse"))

table.insert(Talents,"special_bonus_movement_speed_10")
table.insert(Talents,"special_bonus_mp_250")
table.insert(Talents,"special_bonus_attack_speed_20")
table.insert(Talents,"special_bonus_armor_5")
table.insert(Talents,"special_bonus_hp_275")
table.insert(Talents,"special_bonus_intelligence_15")
table.insert(Talents,"special_bonus_spell_amplify_8")
table.insert(Talents,"special_bonus_unique_outworld_devourer")

local AbilityToLevelUp=
{
	Abilities[2],
	Abilities[3],
	Abilities[2],
	Abilities[3],
	Abilities[2],
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[1],
	Abilities[1],
	Abilities[4],
	Abilities[1],
	Abilities[4],
	"talent",
	"talent",
	Abilities[2],
	"nil",
	Abilities[4],
	"nil",
	"talent",
	"nil",
	"nil",
	"nil",
	"nil",
	"talent",
}

local TalentTree={
	function()
		return Talents[2]
	end,
	function()
		return Talents[3]
	end,
	function()
		return Talents[6]
	end,
	function()
		return Talents[8]
	end
}

-- check skill build vs current level
utility.CheckAbilityBuild(AbilityToLevelUp)

function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end

--------------------------------------
-- Ability Usage Thinking
--------------------------------------
local cast={} cast.Desire={} cast.Target={} cast.Type={}
local Consider ={}
local CanCast={utility.NCanCast,utility.NCanCast,utility.NCanCast,utility.UCanCast}
local enemyDisabled=utility.enemyDisabled

function GetComboDamage()
	return ability_item_usage_generic.GetComboDamage(AbilitiesReal)
end

function GetComboMana()
	return ability_item_usage_generic.GetComboMana(AbilitiesReal)
end
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
Consider[2]=function()
	local abilityNumber=2
	local ability=AbilitiesReal[abilityNumber]
	local blink = nil
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end
	
	local CastRange = ability:GetCastRange()
	local Damage = ability:GetAbilityDamage()
	local Radius = ability:GetSpecialValueInt( "radius" )
	
	local HeroHealth=99999
	local CreepHealth=99999
	local allys = npcBot:GetNearbyHeroes( CastRange, false, BOT_MODE_NONE )
	local WeakestAlly,AllyHealth=utility.GetWeakestUnit(allys)
	local enemys = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+Radius,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	--local NeutralCreeps = GetNearbyNeutralCreeps(CastRange)
	--local WeakestNeutral,NeutralHealth=utility.GetWeakestUnit(NeutralCreeps)
	local EnemyTowers = npcBot:GetNearbyTowers( 800, true )
	if(enemys==nil) then enemys={} end
	if(allys==nil) then allys={} end
	if(creeps==nil) then creeps={} end
	--if(NeutralCreeps==nil) then NeutralCreeps={} end
	if(EnemyTowers==nil) then EnemyTowers={} end
	
	local i=npcBot:FindItemSlot("item_blink")
	if(i>=0 and i<=5) then
		blink=npcBot:GetItemInSlot(i)
		i=nil
	end
	
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	
	--going after someone, without blink
	if(npcBot:GetActiveMode() == BOT_MODE_ATTACK and #enemys<=2 and blink==nil) then
		local EnemyTarget = npcBot:GetTarget()
		if(EnemyTarget~=nil and CanCast[abilityNumber]( EnemyTarget ) and not enemyDisabled(EnemyTarget)) then
			return BOT_ACTION_DESIRE_HIGH,EnemyTarget
		end
	end
	
	--try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) then
		if(WeakestEnemy~=nil) then
			if ( CanCast[abilityNumber]( WeakestEnemy ) and not enemyDisabled(WeakestEnemy)) then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL)) then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy
				end
			end
		end
	end
	
	--interrupt channeling enemy
	if(#enemys~=0) then 
		for _, TEnemy in pairs(enemys) do
			if(TEnemy:IsChanneling() and CanCast[abilityNumber]( TEnemy )) then
				local distance = GetUnitToUnitDistance( npcBot, TEnemy )
				if(distance<=CastRange) then
					npcBot:Action_UseAbilityOnEntity( ability, TEnemy )
					return 0
				elseif(blink~=nil and distance>CastRange and blink:IsFullyCastable()) then
					npcBot:Action_UseAbilityOnLocation( blink, TEnemy:GetLocation() )
					npcBot:Action_UseAbilityOnEntity( ability, TEnemy )
					return 0
				end
			end
		end
	end
	
	--try to save allys in danger
	if(HealthPercentage<0.2 and #enemys>=2) then
		npcBot:Action_UseAbilityOnEntity( ability, npcBot )
		return 0
	end
	if(WeakestAlly~=nil and #enemys~=0) then
		if(AllyHealth/WeakestAlly:GetHealth()<=0.15) then
			npcBot:Action_UseAbilityOnEntity( ability, WeakestAlly )
			return 0
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	--lane by AstralImprisonment
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) then
		if(#enemys >=1 and #EnemyTowers <=0) then
			local EnemyTarget = enemys[1]
			if(npcBot:GetMana() > 350 and not EnemyTarget:IsStunned() and not EnemyTarget:IsRooted() and CanCast[abilityNumber]( EnemyTarget )) then
				return BOT_ACTION_DESIRE_HIGH,EnemyTarget
			end
		end
	end
	
	--farm by AstralImprisonment, if we can hit 3+ creeps, do it
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		if(#enemys <=0 and #creeps>=3) then
			if(WeakestCreep ~=nil and CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL)) then
				npcBot:Action_UseAbilityOnEntity( ability, WeakestCreep )
				local CreepsWithinRadius = WeakestCreep:GetNearbyCreeps(Radius,false)
				for _,creepsin in pairs( CreepsWithinRadius )
				do
					while(creepsin:GetHealth()>Damage+creepsin:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL))
					do
						npcBot:Action_AttackUnit(creepsin,true)
					end
				end
				return 0
			end
			
			if(WeakestNeutral ~=nil and NeutralHealth<=WeakestNeutral:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL)) then
				npcBot:Action_UseAbilityOnEntity( ability, WeakestNeutral )
				local NeutralsWithinRadius = WeakestNeutral:GetNearbyNeutralCreeps(Radius)
				for _,creepsin in pairs( NeutralsWithinRadius )
				do
					while(creepsin:GetHealth()>Damage+creepsin:GetActualIncomingDamage(npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL))
					do
						npcBot:Action_AttackUnit(creepsin,true)
					end
				end
				return 0
			end
		end
	end
	
	--push or defend by AstralImprisonment
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID 
		or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT) then
		local AllyCreeps = npcBot:GetNearbyCreeps(CastRange+Radius,false)
		if(AllyCreeps==nil) then AllyCreeps={} end
		if(#enemys<=0 and #AllyCreeps>0 and #creeps>=3) then
			if(ManaPercentage>0.5 or npcBot:GetMana()>ComboMana) then
				return BOT_ACTION_DESIRE_MODERATE,creeps[1]
			end
		end
	end
	
	--try to protect myself by blink after AstralImprisonment
	if(npcBot:GetActiveMode() == BOT_MODE_RETREAT) then
		
		if(npcBot:IsUsingAbility() or blink==nil or not blink:IsFullyCastable()) then
			return 0
		end
		
		local BlinkRange = 1200
		--local modifierName1 = "modifier_obsidian_destroyer_astral_imprisonment_buff"
		local modifierName = "modifier_obsidian_destroyer_astral_imprisonment_prison"
		local FountainLoc = npcBot:GetLocation()
		if ( GetTeam() == TEAM_RADIANT ) then
			FountainLoc = XYZ.RAD_FOUNTAIN;
		elseif ( GetTeam() == TEAM_DIRE ) then
			FountainLoc = XYZ.DIRE_FOUNTAIN;
		end
	
		if ( npcBot:HasModifier(modifierName)) then
			npcBot:Action_UseAbilityOnLocation( blink, FountainLoc )
		end
	end
	
	--if we're going after someone and mana is enough
	if(npcBot:GetActiveMode() == BOT_MODE_ATTACK 
		or npcBot:GetActiveMode() == BOT_MODE_ROAM
		or npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM) then
		if(npcBot:IsUsingAbility() or blink==nil or not blink:IsFullyCastable() or not ability:IsFullyCastable()) then
			return 0
		end
		
		if(#enemys<=2 and CanCast[abilityNumber]( enemys[1] )and not enemyDisabled(enemys[1]) and npcBot:GetMana()>ComboMana) then
			npcBot:Action_UseAbilityOnLocation( blink, enemys[1]:GetLocation() )
			npcBot:Action_UseAbilityOnEntity( ability, enemys[1] )
			return 0
		end
	end
end
----------------------------------------------------------------------------------------------------
Consider[4]=function()
	local abilityNumber=4
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber]
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end
	
	local CastRange = ability:GetCastRange()
	local Damage = 0
	local DamageOnWeakest = 0
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=99999
	local CreepHealth=99999
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local enemys = npcBot:GetNearbyHeroes(CastRange,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	
	local ODIntellect = npcBot:GetAttributeValue( ATTRIBUTE_INTELLECT )
	local UltLevel = ability:GetLevel()
	local EnemyTarget = nil
	local TargetIntellect = 9999
	local modifierName = "modifier_obsidian_destroyer_arcane_orb"
	local modifierCount = 0
	local modifierIndex = -1
	
	--calculate stack count of ArcaneOrb 
	if(modifierName ~= nil) then
		for i=1,npcBot:NumModifiers(),1 do
			if ( npcBot:GetModifierName(i) == modifierName ) then
				modifierIndex = i
			end
		end
	else
		modifierIndex = -1
	end
	
	if(modifierIndex>0) then
		modifierCount = npcBot:GetModifierStackCount( modifierIndex )
	end
	
	for _, TEnemy in pairs(enemys) do
		if ( TEnemy:GetAttributeValue(ATTRIBUTE_INTELLECT) < TargetIntellect ) then
			EnemyTarget = TEnemy;
			TargetIntellect = EnemyTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
		end
	end
	
	if(npcBot:GetActiveMode()~=BOT_MODE_RETREAT and WeakestEnemy~=nil) then
		Damage = (ODIntellect-TargetIntellect)*(UltLevel+7)
		DamageOnWeakest = (ODIntellect-WeakestEnemy:GetAttributeValue(ATTRIBUTE_INTELLECT))*(UltLevel+7)
		local locationUlt = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 )
		--if we steal enough intelligence and can hit 2+ heroes
		if(modifierCount > 28 and locationUlt.count>=2) then
			npcBot:Action_UseAbilityOnLocation( ability, locationUlt.targetloc )
			return 0
		end
		
		--if we can kill the weakest one or the least intelligence one
		if(EnemyTarget:GetHealth()<=EnemyTarget:GetActualIncomingDamage( Damage, DAMAGE_TYPE_MAGICAL )
			and CanCast[abilityNumber]( EnemyTarget )and not enemyDisabled(EnemyTarget)) then
			npcBot:Action_UseAbilityOnLocation( ability, EnemyTarget:GetLocation() )
			return 0
		end
		if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage( DamageOnWeakest, DAMAGE_TYPE_MAGICAL )
			and CanCast[abilityNumber]( WeakestEnemy )and not enemyDisabled(WeakestEnemy)) then
			npcBot:Action_UseAbilityOnLocation( ability, WeakestEnemy:GetLocation() )
			return 0
		end
		
		--if we can hit 4+ enemy heroes at the beginning
		if(locationUlt.count>=4 and ManaPercentage>=0.5) then
			return BOT_ACTION_DESIRE_HIGH, locationUlt.targetloc
		end
	end
end
----------------------------------------------------------------------------------------------------
function AutoCastArcaneOrb()

	if ( not ARCANE_ORB_STATUS and npcBot:GetMaxMana() > 1200 ) then
		AbilitiesReal[1]:ToggleAutoCast()
		ARCANE_ORB_STATUS = true
	end

end

function CastArcaneOrb()
	if ( npcBot:IsUsingAbility() or not AbilitiesReal[1]:IsFullyCastable() or npcBot:GetActiveMode()==BOT_MODE_RETREAT) then 
		return
	end
	
	local EnemyTarget = npcBot:GetTarget()
	if(EnemyTarget~=nil and EnemyTarget:IsHero() and not ARCANE_ORB_STATUS) then
		if(ManaPercentage>=0.45 and EnemyTarget:GetHealth()/EnemyTarget:GetMaxHealth()<0.3) then
			npcBot:Action_UseAbilityOnEntity( AbilitiesReal[1], EnemyTarget )
		end
	end
end
----------------------------------------------------------------------------------------------------
function AbilityUsageThink()
	local UltAbility=AbilitiesReal[4]
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	ComboMana=GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	AutoCastArcaneOrb()
	CastArcaneOrb()
	cast=ability_item_usage_generic.ConsiderAbility(AbilitiesReal,Consider)
	---------------------------------debug--------------------------------------------
	if(debugmode==true)
	then
		ability_item_usage_generic.PrintDebugInfo(AbilitiesReal,cast)
	end
	ability_item_usage_generic.UseAbility(AbilitiesReal,cast)
end
----------------------------------------------------------------------------------------------------
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end