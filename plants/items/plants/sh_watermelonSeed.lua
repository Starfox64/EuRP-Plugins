ITEM.name = "Watermelon Seeds"
ITEM.uniqueID = "watermelonSeed"
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.desc = "Produces Watermelon once grown and gathered."
ITEM.plant = "watermelon"
ITEM.plantmdl = "models/props_junk/watermelon01.mdl"
ITEM.time = 400
ITEM.pos = Vector(0, 0, 14)
ITEM.ang = Angle(45, 0, 45)
ITEM.price = 15
ITEM.functions = {}

ITEM.functions.Use = {
	menuOnly = true,
	alias = "Plant",
	tip = "Plant the seeds in the pot.",
	icon = "icon16/water.png",
	run = function(itemTable, client, data)
		if (SERVER) then
			local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
			local trace = util.TraceLine(data)

			if IsValid(trace.Entity) and trace.Entity:GetClass() == "nut_item" then
				local uniqueID = trace.Entity:GetItemTable().uniqueID
				if uniqueID == "pot" and not trace.Entity:GetData().inUse then
					local pos, ang = trace.Entity:GetPos(), trace.Entity:GetAngles()
					local newData = {
						inUse = true,
						plant = itemTable.plant,
						endTime = CurTime() + itemTable.time
					}

					trace.Entity:Remove()
					local pot = nut.item.Spawn(pos, ang, "pot", newData)

					local spawnPos, spawnAng = LocalToWorld(itemTable.pos, itemTable.ang, pot:GetPos(), pot:GetAngles())
					local plant = ents.Create("prop_physics")
					plant:SetSolid(0)
					plant:SetModel(itemTable.plantmdl)
					plant:SetPos(spawnPos)
					plant:SetAngles(spawnAng)
					plant:SetParent(pot)

					pot:DeleteOnRemove(plant)

					client:EmitSound("player/footsteps/dirt1.wav")

					return true
				end
			end

			return false
		end
	end,
	shouldDisplay = function( itemTable, data, entity )
		local traceData = {}
		traceData.start = LocalPlayer():GetShootPos()
		traceData.endpos = traceData.start + LocalPlayer():GetAimVector() * 96
		traceData.filter = LocalPlayer()
		local trace = util.TraceLine(traceData)

		if IsValid(trace.Entity) and trace.Entity:GetClass() == "nut_item" then
			local uniqueID = trace.Entity:GetItemTable().uniqueID
			if uniqueID == "pot" and not trace.Entity:GetData().inUse then
				return true
			end
		end

		return false
	end
}