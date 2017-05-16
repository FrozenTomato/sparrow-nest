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
local npcBot = GetBot()
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}

ability_item_usage_generic.InitAbility(Abilities,AbilitiesReal,Talents) 

local AbilityToLevelUp=
{
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[1],
	Abilities[3],
	Abilities[4],
	Abilities[3],
	Abilities[2],
	Abilities[1],
	"talent",
	Abilities[1],
	Abilities[4],
	Abilities[2],
	Abilities[2],
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
		return Talents[5]
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

Consider[1]=function()	--Target Ability Example
	local abilityNumber=1
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber]
	local blink = nil
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end
	
	local CastRange = 0
	local Damage = ability:GetAbilityDamage()
	local Radius = ability:GetAOERadius()-50
	local CastPoint = ability:GetCastPoint()
	
	local i=npcBot:FindItemSlot("item_blink")
	if(i>=0 and i<=5)
	then
		blink=npcBot:GetItemInSlot(i)
		i=nil
	end
	if(blink~=nil and blink:IsFullyCastable())
	then
		CastRange=CastRange+1200
		if(npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
		then
			local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 )
			if ( locationAoE.count >= 2 ) 
			then
				npcBot:Action_UseAbilityOnLocation( blink, locationAoE.targetloc )
				return 1.0  --change from 0 to 1
			end
		end
	end
	
	local HeroHealth=99999
	local CreepHealth=99999
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(Radius,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- Check for a channeling enemy
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	--Try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	--protect myself
	if(((npcBot:WasRecentlyDamagedByAnyHero(2) and #enemys>=1) or #enemys >=2) and HealthPercentage<=0.3)
	then
		for _,npcEnemy in pairs( enemys )
		do
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	-- If my mana is enough,use it at enemy
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana+55))
		then
			if (WeakestEnemy~=nil)
			then
				if(GetUnitToUnitDistance(npcBot,WeakestEnemy)<Radius-CastPoint*WeakestEnemy:GetCurrentMovementSpeed())
				then
					return BOT_ACTION_DESIRE_LOW
				end
			end
		end
	end
	
	-- If we're farming and can hit 3+ creeps
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 3 ) 
		then
			if(CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana+55)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget()

		if ( npcEnemy ~= nil ) 
		then
			if ( GetUnitToUnitDistance(npcBot,npcEnemy)>=260 ) 
			then
				if( GetUnitToUnitDistance(npcBot,npcEnemy)<=1200+Radius+50 and blink~=nil)
				then
					npcBot:Action_UseAbilityOnLocation( blink, npcEnemy:GetExtrapolatedLocation(CastPoint) )
					return BOT_ACTION_DESIRE_HIGH  --change from 0
				end
			else		
				return BOT_ACTION_DESIRE_HIGH  --change from desire_moderate
			end

		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
	
end

Consider[2]=function()
	local abilityNumber=2
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[2]
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end
	
	local CastRange = ability:GetCastRange()
	local Damage = ability:GetAbilityDamage()
	local CastPoint = ability:GetCastPoint()
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--Try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[2]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy
				end
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're chased, try to slow down dangerous enemys
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and #enemys~=0) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:GetOffensivePower()< npcEnemy:GetRawOffensivePower())  --change from recently_dameged
			then
				if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy)) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy
				end
			end
		end
	end
	
	-- If my mana is enough,use it at enemy
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.5 or npcBot:GetMana()>ComboMana+55))
		then
			if (WeakestEnemy~=nil)
			then
				if ( CanCast[abilityNumber]( WeakestEnemy ) )
				then
					return BOT_ACTION_DESIRE_LOW,WeakestEnemy
				end
			end
		end
	end
	
	-- If we're farming whether can kill 1+ creeps or prevent a creep denied
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 ) 
		then
			if(CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW, WeakestCreep
			end
		end
		else if( #enemys ~= 0 and #creeps >= 1)
		then 
			if(CreepHealth<=enemys[1]:GetAttackDamage()+10 and ManaPercentage>0.7)
			then
				return BOT_ACTION_DESIRE_LOW, WeakestCreep
			end
		end
	end

	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if ( #enemys>=1) 
		then
			if (ManaPercentage>0.5 or npcBot:GetMana()>ComboMana)
			then
				if (WeakestEnemy~=nil)
				then
					if ( CanCast[abilityNumber]( WeakestEnemy )and GetUnitToUnitDistance(npcBot,WeakestEnemy)< CastRange + 75*#allys )
					then
						return BOT_ACTION_DESIRE_MODERATE, WeakestEnemy
					end
				end
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget()

		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
	
end

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
	local Damage = ability:GetSpecialValueInt("kill_threshold")
	local CastPoint = ability:GetCastPoint()
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--Try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or (npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() <= BOT_ACTION_DESIRE_MODERATE)) 
	then
		for _,npcEnemy in pairs(enemys)
		do
			if(npcEnemy:GetHealth()<=Damage)
			then
				return 0.9,npcEnemy
			end
		end
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	return BOT_ACTION_DESIRE_NONE, 0
end

function AbilityUsageThink()

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	ComboMana=GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	cast=ability_item_usage_generic.ConsiderAbility(AbilitiesReal,Consider)
	---------------------------------debug--------------------------------------------
	if(debugmode==true)
	then
		ability_item_usage_generic.PrintDebugInfo(AbilitiesReal,cast)
	end
	ability_item_usage_generic.UseAbility(AbilitiesReal,cast)
end

function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end