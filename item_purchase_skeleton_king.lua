----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W. 
--[[ safe-carry skeleton king build: 
	tango, flask, mango, stout shield, branches, quelling blade, power treads, 
	blade mail, radiance, assault cuirass, maelstrom, mjollnir
--]]
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_tango",
	"item_stout_shield",
	"item_branches",
	"item_flask",
	"item_enchanted_mango",
	"item_quelling_blade",
	"item_boots",
	"item_belt_of_strength",
	"item_gloves",					--power treads
	"item_chainmail",
	"item_robe",
	"item_broadsword",				--blade mail
	"item_relic",
	"item_recipe_radiance",			--radiance
	"item_hyperstone",
	"item_platemail",
	"item_chainmail",
	"item_recipe_assault",			--assault cuirass
	"item_mithril_hammer",
	"item_gloves",
	"item_recipe_maelstrom",		--maelstrom
	"item_hyperstone",
	"item_recipe_mjollnir",			--mjollnir
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.ItemPurchase(ItemsToBuy)
end