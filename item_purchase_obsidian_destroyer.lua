----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W. 
--[[ mid outworld devourer build: 
	faerie fire, null talisman, branches, tango(shared)*2, flask, bottle, boots, 
	magic stick, power treads, magic wand, infused raindrop, force staff, hurricane pike,
	blink dagger, rod of atos/scythe of vyse, octarine core
--]]
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" )

local ItemsToBuy = 
{ 
	"item_faerie_fire",
	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",		--null talisman
	"item_branches",
	"item_flask",
	"item_bottle",
	"item_boots",
	"item_magic_stick",
	"item_belt_of_strength",
	"item_gloves",						--power treads
	"item_circlet",
	"item_branches",					--magic wand
	"item_infused_raindrop",
	"item_staff_of_wizardry",
	"item_ring_of_regen",
	"item_recipe_force_staff",			--force staff
	"item_ogre_axe",
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_recipe_hurricane_pike",		--hurricane pike
	"item_blink",
	"item_mystic_staff",
	"item_ultimate_orb",
	"item_void_stone",					--scythe of vyse
	"item_mystic_staff",
	"item_energy_booster",
	"item_point_booster",
	"item_vitality_booster",			--octarine core
	
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.ItemPurchase(ItemsToBuy)
end