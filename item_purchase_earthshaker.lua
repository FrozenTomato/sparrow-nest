----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W. 
--[[ support earthshaker build: 
	observer ward, sentry ward, clarity*2, tango, branches*2, smoke, boots, wind lace, tranquil boots, 
	magic stick, soul ring, magic wand, blink dagger
--]]
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_ward_observer",
	"item_ward_sentry",
	"item_clarity",
	"item_clarity",
	"item_tango",
	"item_branches",
	"item_branches",
	"item_smoke_of_deceit",
	"item_boots",
	"item_wind_lace",
	"item_ring_of_regen",			--tranquil boots
	"item_magic_stick",
	"item_sobi_mask",
	"item_ring_of_regen",
	"item_enchanted_mango",			--soul ring
	"item_circlet",					--magic wand
	"item_blink",					--blink dagger
	
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.BuySupportItem()
	utility.ItemPurchase(ItemsToBuy)
end