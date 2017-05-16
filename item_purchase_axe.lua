----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W. 
--[[ tango*2, flask, stout shield, branches, boots, wind lace, magic stick, ring of regen, magic wand, blink dagger, blade mail, vanguard, force staff,
	crimson guard, boots of travel, heart of tarrasque
--]]
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_branches",
	"item_boots",
	"item_wind_lace",
	"item_magic_stick",
	"item_ring_of_regen",			--tranquil boots
	"item_branches",
	"item_circlet",					--magic wand
	"item_blink",					--blink dagger
	"item_chainmail",
	"item_robe",
	"item_broadsword",				--blade mail
	"item_ring_of_health",
	"item_vitality_booster",		--vanguard
	"item_staff_of_wizardry",
	"item_ring_of_regen",
	"item_recipe_force_staff",		--force staff
	"item_chainmail",
	"item_branches",
	"item_recipe_buckler",			--buckler
	"item_recipe_crimson_guard",	--crimson guard
	"item_reaver",
	"item_vitality_booster",
	"item_vitality_booster",			--heart of tarrasque

}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.ItemPurchase(ItemsToBuy)
end