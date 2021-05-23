
--- A library representing the server's currency system.
-- @module ix.currency

ix.currency = ix.currency or {}
ix.currency.symbol = ix.currency.symbol or "$"
ix.currency.singular = ix.currency.singular or "dollar"
ix.currency.plural = ix.currency.plural or "dollars"
ix.currency.model = ix.currency.model or "models/props_lab/box01a.mdl"

--- Sets the currency type.
-- This is how you would set the currency for your Schema.
-- @realm shared
-- @string symbol The symbol of the currency.
-- @string singular The name of the currency in it's singular form.
-- @string plural The name of the currency in it's plural form.
-- @string model The model of the currency entity.
-- @usage
-- ix.currency.Set('₽', 'Monopoly Dollar', 'Monopoly Dollars', 'models/headcrab.mdl')
-- -- Sets the currency to `Monopoly Dollar(s)`, using the symbol representing the Russian Ruble and the Fast Headcrab model.
function ix.currency.Set(symbol, singular, plural, model)
	ix.currency.symbol = symbol
	ix.currency.singular = singular
	ix.currency.plural = plural
	ix.currency.model = model
end

--- Returns a formatted string according to the current currency.
-- @realm shared
-- @number amount The amount of cash being formatted.
-- @treturn string The formatted string.
function ix.currency.Get(amount)
	if (amount == 1) then
		return ix.currency.symbol.."1 "..ix.currency.singular
	else
		return ix.currency.symbol..amount.." "..ix.currency.plural
	end
end

--- Spawns an amount of cash at a specific location on the map.
-- @realm shared
-- @vector pos The position of the money to be spawned.
-- @number amount The amount of cash being spawned.
-- @angle[opt=angle_zero] angle The angle of the entity being spawned.
-- @treturn entity The spawned money entity.
function ix.currency.Spawn(pos, amount, angle)
	if (!amount or amount < 0) then
		print("[Helix] Can't create currency entity: Invalid Amount of money")
		return
	end

	local money = ents.Create("ix_money")
	money:Spawn()

	if (IsValid(pos) and pos:IsPlayer()) then
		pos = pos:GetItemDropPos(money)
	elseif (!isvector(pos)) then
		print("[Helix] Can't create currency entity: Invalid Position")

		money:Remove()
		return
	end

	money:SetPos(pos)
	-- double check for negative.
	money:SetAmount(math.Round(math.abs(amount)))
	money:SetAngles(angle or angle_zero)
	money:Activate()

	return money
end

function GM:OnPickupMoney(client, moneyEntity)
	if (IsValid(moneyEntity)) then
		local amount = moneyEntity:GetAmount()

		client:GetCharacter():GiveMoney(amount)
	end
end

do
	local character = ix.meta.character

	--- Character currency methods
	-- @classmod Character

	--- Whether or not this `Character` has less than `amount` of money.
	-- [The implementation in ixhl2rp's Vending Machine.](https://github.com/NebulousCloud/helix-hl2rp/blob/3c8d7f1a37489cddd773eb76869ff8abb4a33a8b/entities/entities/ix_vendingmachine.lua\#L136)
	-- @realm shared
	-- @number amount The amount to check for.
	-- @treturn bool Whether or not the character has enough money.
	-- @see ix.currency
	function character:HasMoney(amount)
		if (amount < 0) then
			print("Negative Money Check Received.")
		end

		return self:GetMoney() >= amount
	end

	--- Give an amount of money to a `Character`.
	-- The difference between `GiveMoney`, `TakeMoney` and `SetMoney` is that you must log `SetMoney` manually.
	-- Is that you must log `SetMoney` manually.
	-- @realm shared
	-- @number amount The amount to give.
	-- @bool bNoLog Whether or not to log this action.
	-- @treturn true Always returns true.
	-- @see ix.currency
	-- @see SetMoney
	-- @see TakeMoney
	function character:GiveMoney(amount, bNoLog)
		amount = math.abs(amount)

		if (!bNoLog) then
			ix.log.Add(self:GetPlayer(), "money", amount)
		end

		self:SetMoney(self:GetMoney() + amount)

		return true
	end

	--- Take an amount of money from a `Character`.
	-- The difference between `GiveMoney`, `TakeMoney` and `SetMoney` is that you must log `SetMoney` manually.
	-- Is that you must log `SetMoney` manually.
	-- @realm shared
	-- @number amount The amount to take
	-- @bool bNoLog Whether or not to log this action.
	-- @treturn true Always returns true.
	-- @see ix.currency
	-- @see SetMoney
	-- @see GiveMoney
	function character:TakeMoney(amount, bNoLog)
		amount = math.abs(amount)

		if (!bNoLog) then
			ix.log.Add(self:GetPlayer(), "money", -amount)
		end

		self:SetMoney(self:GetMoney() - amount)

		return true
	end
end
