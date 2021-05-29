--SECTION[epic=docs,seq=2] libs/sh_player

local playerMeta = FindMetaTable("Player")





do
	if (SERVER) then
	

		--- Player Data Library Extensions
		-- @classmod Player

		--- Returns a data field set on this player. If it doesn't exist, it will return the given default or `nil`. 
		-- This is only valid on the server and the client that has the data.
		-- @realm shared
		-- @string key Name of the field that's holding the data
		-- @param default Value to return if the given key doesn't exist, or is `nil`
		-- @return[1] Data stored in the field
		-- @treturn[2] nil If the data doesn't exist, or is `nil`
		function playerMeta:GetData(key, default)
			if (key == true) then
				return self.ixData
			end

			local data = self.ixData and self.ixData[key]

			if (data == nil) then
				return default
			else
				return data
			end
		end
	else
		function playerMeta:GetData(key, default)
			local data = ix.localData and ix.localData[key]

			if (data == nil) then
				return default
			else
				return data
			end
		end

		net.Receive("ixDataSync", function()
			ix.localData = net.ReadTable()
			ix.playTime = net.ReadUInt(32)
		end)

		net.Receive("ixData", function()
			ix.localData = ix.localData or {}
			ix.localData[net.ReadString()] = net.ReadType()
		end)
	end
end

--Whitelist networking information here.
do
	--- Whether or not a player has the specified whitelist.
	-- @realm shared
	-- @number faction The faction ID to check for.
	-- @treturn bool Whether or not the player has the whitelist.
	-- @usage print(Entity(1):HasWhitelist(FACTION_MPF))
	-- > true
	function playerMeta:HasWhitelist(faction)
		local data = ix.faction.indices[faction]

		if (data) then
			if (data.isDefault) then
				return true
			end

			local ixData = self:GetData("whitelists", {})

			return ixData[Schema.folder] and ixData[Schema.folder][data.uniqueID] == true or false
		end

		return false
	end

	--- Returns the `Item`s the` Player`'s `Character` posesses.
	-- @realm shared
	-- @treturn[1] table The `Item`s the `Player` has.
	-- @treturn[2] nil If the player does not have a character loaded, or does not have an inventory.
	-- @usage for client in ix.util.GetCharacters do
	-- 	print(client:GetItems())
	-- end
	-- > table: 0x32d18c88
	-- -- Uses ix.util.GetCharacters to loop through all players who currently have a character loaded, and prints the memory reference to their items. Use `PrintTable` if you want to see the full list yourself.
	function playerMeta:GetItems()
		local char = self:GetCharacter()

		if (char) then
			local inv = char:GetInventory()

			if (inv) then
				return inv:GetItems()
			end
		end
	end

	function playerMeta:GetClassData()
		local char = self:GetCharacter()

		if (char) then
			local class = char:GetClass()

			if (class) then
				local classData = ix.class.list[class]

				return classData
			end
		end
	end
end

do
	if (SERVER) then
		util.AddNetworkString("PlayerModelChanged")
		util.AddNetworkString("PlayerSelectWeapon")

		local entityMeta = FindMetaTable("Entity")

		entityMeta.ixSetModel = entityMeta.ixSetModel or entityMeta.SetModel
		playerMeta.ixSelectWeapon = playerMeta.ixSelectWeapon or playerMeta.SelectWeapon

		function entityMeta:SetModel(model)
			local oldModel = self:GetModel()

			if (self:IsPlayer()) then
				hook.Run("PlayerModelChanged", self, model, oldModel)

				net.Start("PlayerModelChanged")
					net.WriteEntity(self)
					net.WriteString(model)
					net.WriteString(oldModel)
				net.Broadcast()
			end

			return self:ixSetModel(model)
		end

		function playerMeta:SelectWeapon(className)
			net.Start("PlayerSelectWeapon")
				net.WriteEntity(self)
				net.WriteString(className)
			net.Broadcast()

			return self:ixSelectWeapon(className)
		end
	else
		net.Receive("PlayerModelChanged", function(length)
			hook.Run("PlayerModelChanged", net.ReadEntity(), net.ReadString(), net.ReadString())
		end)

		net.Receive("PlayerSelectWeapon", function(length)
			local client = net.ReadEntity()
			local className = net.ReadString()

			if (!IsValid(client)) then
				hook.Run("PlayerWeaponChanged", client, NULL)
				return
			end

			for _, v in ipairs(client:GetWeapons()) do
				if (v:GetClass() == className) then
					hook.Run("PlayerWeaponChanged", client, v)
					break
				end
			end
		end)
	end
end
