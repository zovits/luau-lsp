local LiveSyncService = {}

-- Mocking the APIs from the LiveSyncService

type SyncStatus = "NotSyncing" | "Syncing" | "Errored"

type SyncInfo = {
	SyncStatus: SyncStatus,
	FilePath: string?,
	DirectoryPath: string?,
	IsRoot: boolean,
	LastUpdated: string?,
}

local DEFAULT_SYNC_INFO: SyncInfo = table.freeze({
	SyncStatus = "NotSyncing",
	FilePath = nil,
	DirectoryPath = nil,
	IsRoot = false,
	LastUpdated = nil,
})

local SyncStatusChanged = Instance.new("BindableEvent")
local InternalMappings: { [Instance]: SyncInfo } = {}

function LiveSyncService:GetSyncStatus(instance: Instance): SyncStatus
	local syncInfo = InternalMappings[instance]
	if not syncInfo then
		return "NotSyncing"
	end
	return syncInfo.SyncStatus
end

function LiveSyncService:GetSyncedInstances(): { Instance }
	local instances = {}
	for instance, _ in InternalMappings do
		table.insert(instances, instance)
	end
	return instances
end

function LiveSyncService:GetSyncInfo(instance: Instance): SyncInfo
	local syncInfo = InternalMappings[instance]
	if not syncInfo then
		return DEFAULT_SYNC_INFO
	end
	return syncInfo
end

LiveSyncService.SyncStatusChanged = SyncStatusChanged.Event

task.delay(5, function()
	print("Setting up mappings")
	InternalMappings[game:GetService("ReplicatedStorage").Packages] = {
		SyncStatus = "Syncing",
		IsRoot = true,
		FilePath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("ReplicatedStorage").Packages.Foo] = {
		SyncStatus = "Syncing",
		IsRoot = false,
		FilePath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/Foo.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("ReplicatedStorage").Packages.Bar] = {
		SyncStatus = "Syncing",
		IsRoot = false,
		FilePath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/Bar.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("ReplicatedStorage").Packages.Baz] = {
		SyncStatus = "Syncing",
		IsRoot = false,
		FilePath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/Baz.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/shared/Packages/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("ServerScriptService").Server] = {
		SyncStatus = "Syncing",
		IsRoot = true,
		FilePath = "C:/Users/zovits/Downloads/proj/src/server/init.legacy.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("ServerScriptService").Server.util] = {
		SyncStatus = "Syncing",
		IsRoot = false,
		FilePath = "C:/Users/zovits/Downloads/proj/src/server/util.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/server/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("StarterPlayer").StarterPlayerScripts.Client] = {
		SyncStatus = "Syncing",
		IsRoot = true,
		FilePath = "C:/Users/zovits/Downloads/proj/src/client/init.client.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	InternalMappings[game:GetService("StarterPlayer").StarterPlayerScripts.Client.helper] = {
		SyncStatus = "Syncing",
		IsRoot = false,
		FilePath = "C:/Users/zovits/Downloads/proj/src/client/helper.luau",
		DirectoryPath = "C:/Users/zovits/Downloads/proj/src/client/",
		LastUpdated = DateTime.now():ToIsoDate(),
	}
	for instance in InternalMappings do
		SyncStatusChanged:Fire(instance, "Syncing")
	end
end)

return LiveSyncService
