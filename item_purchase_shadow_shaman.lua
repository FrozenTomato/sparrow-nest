----------------------------------------------------------------------------
--	Raptor Bot test version
--	By: Sparrow W. 
--[[ hard-support shadow shaman build: 
	observer ward, sentry ward, tango, courier, TPscroll, smoke, clarity*2,
	boots, magic wand, arcane boots, blink dagger, refresher orb
--]]
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_clarity",
	"item_clarity",
	"item_tango",
	"item_smoke_of_deceit",
	"item_boots",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_circlet",				--magic wand
	"item_energy_booster",		--arcane boots
	"item_blink",
	"item_ring_of_health",
	"item_void_stone",
	"item_ring_of_health",
	"item_void_stone",
	"item_recipe_refresher",	--refresher orb
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.BuySupportItem()
	utility.BuyCourier()
	utility.ItemPurchase(ItemsToBuy)
end