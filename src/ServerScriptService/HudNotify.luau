local Remotes = require(game:GetService("ReplicatedStorage").Remotes)

local HudNotify = {}

function HudNotify.Feed(player: Player?, text: string)
	if player then
		Remotes.Fire("Feed", player, text)
	else
		Remotes.FireAll("Feed", text)
	end
end

function HudNotify.Popup(player: Player?, text: string, color: Color3, position: Vector3, big: boolean?)
	if player then
		Remotes.Fire("Popup", player, text, color, position, big)
	else
		Remotes.FireAll("Popup", text, color, position, big)
	end
end

function HudNotify.PopupOver(player: Player, text: string, color: Color3, big: boolean?)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		HudNotify.Popup(nil, text, color, root.Position + Vector3.new(0, 4, 0), big)
	end
end

return HudNotify
