-- SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- FOLDERS
local ServerLibs = ServerScriptService.Forge.Libs
local ServerConfig = ServerScriptService.Forge.Config

-- MODULES
local ProfileStore = require(ServerLibs.ProfileStore)
local Signal = require(ReplicatedStorage.Forge.Shared.Libs.Signal)

-- CONFIG
local PlayerDataTemplate = require(ServerConfig.PlayerDataTemplate)

------------------------------
-- CONSTANTS --
------------------------------
local STORE_KEY = "Production"
local PLAYER_KEY_PREFIX = "Player_"

ProfileStore.SetConstant("AUTO_SAVE_PERIOD", 60)
ProfileStore.SetConstant("ASSUME_DEAD", 150)

------------------------------
-- STATE --
------------------------------
local PlayerStore = ProfileStore.New(STORE_KEY, PlayerDataTemplate)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

------------------------------
-- MODULE --
------------------------------
local ProfileManager = {
	OnProfileLoaded = Signal.new(), -- (player: Player, profileData)
	OnProfileUnloading = Signal.new(), -- (player: Player)
}

function ProfileManager.Start()
	for _, player in Players:GetPlayers() do
		task.spawn(ProfileManager.LoadProfile, player)
	end
	Players.PlayerAdded:Connect(ProfileManager.LoadProfile)
	Players.PlayerRemoving:Connect(ProfileManager.UnloadProfile)
end

function ProfileManager.LoadProfile(player: Player)
	local profile = PlayerStore:StartSessionAsync(PLAYER_KEY_PREFIX .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile == nil then
		player:Kick("Failed to load your data. Please rejoin in a few moments.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick("Your session was terminated. Please rejoin.")
	end)

	if player.Parent == Players then
		Profiles[player] = profile
		ProfileManager.OnProfileLoaded:Fire(player, Profiles[player].Data)
	else
		profile:EndSession()
	end
end

function ProfileManager.UnloadProfile(player: Player)
	-- Last chance to put the fries in the bag bro
	ProfileManager.OnProfileUnloading:Fire(player)

	local profile = Profiles[player]
	if profile then
		profile:EndSession()
		Profiles[player] = nil
	end
end

------------------------------
-- DATA ACCESS --
------------------------------

function ProfileManager.GetData(player: Player): PlayerData?
	local profile = Profiles[player]
	if not profile then
		return nil
	end
	return profile.Data
end

function ProfileManager.SetData(player: Player, key: string, value: any): (boolean, string)
	local profile = Profiles[player]
	if not profile then
		warn(`[ProfileManager] SetData: No profile for {player.Name}`)
		return false, "Profile Not Found"
	end

	profile.Data[key] = value
	return true, "OK"
end

function ProfileManager.IncrementData(player: Player, key: string, delta: number): (boolean, string)
	local profile = Profiles[player]
	if not profile then
		warn(`[ProfileManager] IncrementData: No profile for {player.Name}`)
		return false, "Profile Not Found"
	end

	local current = profile.Data[key]
	if type(current) ~= "number" then
		warn(`[ProfileManager] IncrementData: Key '{key}' is not numeric for {player.Name}`)
		return false, `Invalid Key Type got {typeof(key)}`
	end

	profile.Data[key] = current + delta
	return true, "OK"
end

return ProfileManager
