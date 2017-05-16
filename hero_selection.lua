----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W.
--	radiant only
----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Think()


	if ( GetTeam() == TEAM_RADIANT )
	then
		print( "selecting radiant" )
		SelectHero( 2, "npc_dota_hero_skeleton_king" )
		SelectHero( 3, "npc_dota_hero_obsidian_destroyer" )
		SelectHero( 4, "npc_dota_hero_axe" )
		SelectHero( 5, "npc_dota_hero_earthshaker" )
		SelectHero( 6, "npc_dota_hero_shadow_shaman" )
	elseif ( GetTeam() == TEAM_DIRE )
	then
		print( "selecting dire" )
		SelectHero( 7, "npc_dota_hero_drow_ranger" )
		SelectHero( 8, "npc_dota_hero_bane" )
		SelectHero( 9, "npc_dota_hero_juggernaut" )
		SelectHero( 10, "npc_dota_hero_mirana" )
		SelectHero( 11, "npc_dota_hero_nevermore" )
	end

end

----------------------------------------------------------------------------------------------------
function UpdateLaneAssignments()
	local AssignedLanesRad = {
	[1] = LANE_BOT,
    [2] = LANE_MID,
    [3] = LANE_TOP,
    [4] = LANE_TOP,
    [5] = LANE_BOT,
	}
	
	local AssignedLanesDire = {
	[1] = LANE_TOP,
    [2] = LANE_MID,
    [3] = LANE_BOT,
    [4] = LANE_BOT,
    [5] = LANE_TOP,
	}
	if(GetTeam() == TEAM_RADIANT) then
		local ids = GetTeamPlayers(TEAM_RADIANT)
		for i,v in pairs(ids) do
			if(not IsPlayerBot(v)) then
				local HumanLane = GetLane( TEAM_RADIANT,GetTeamMember( i ) )
				AssignedLanesRad[i] = HumanLane
			end
		end
		return AssignedLanesRad
	elseif ( GetTeam() == TEAM_DIRE ) then
		local ids = GetTeamPlayers(TEAM_DIRE)
		for i,v in pairs(ids) do
			if(not IsPlayerBot(v)) then
				local HumanLane = GetLane( TEAM_DIRE,GetTeamMember( i ) )
				AssignedLanesDire[i] = HumanLane
			end
		end
		return AssignedLanesDire
	end
	
end