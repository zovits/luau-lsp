#include "LuauFileUtils.hpp"
#include "Platform/RobloxPlatform.hpp"

#include "LSP/Utils.hpp"
#include "LSP/LanguageServer.hpp"
#include "LSP/Workspace.hpp"


PluginNode* PluginNode::fromJson(const json& j, Luau::TypedAllocator<PluginNode>& allocator)
{
    auto name = j.at("Name").get<std::string>();
    auto className = j.at("ClassName").get<std::string>();
    std::vector<std::string> filePaths{};
    if (j.contains("FilePaths"))
    {
        for (auto& filePath : j.at("FilePaths"))
        {
            filePaths.emplace_back(Luau::FileUtils::normalizePath(resolvePath(filePath.get<std::string>())));
        }
    }

    std::vector<PluginNode*> children;
    if (j.contains("Children"))
    {
        for (auto& child : j.at("Children"))
        {
            children.emplace_back(PluginNode::fromJson(child, allocator));
        }
    }

    return allocator.allocate(PluginNode{std::move(name), std::move(className), std::move(filePaths), std::move(children)});
}

void RobloxPlatform::onStudioPluginFullChange(const json& dataModel)
{
    workspaceFolder->client->sendLogMessage(lsp::MessageType::Info, "received full change from studio plugin");

    pluginNodeAllocator.clear();
    setPluginInfo(PluginNode::fromJson(dataModel, pluginNodeAllocator));

    // Mutate the sourcemap with the new information
    updateSourceMap();
}

void RobloxPlatform::onStudioPluginClear()
{
    workspaceFolder->client->sendLogMessage(lsp::MessageType::Info, "received clear from studio plugin");

    // TODO: properly handle multi-workspace setup
    pluginNodeAllocator.clear();
    setPluginInfo(nullptr);

    // Mutate the sourcemap with the new information
    updateSourceMap();
}

bool RobloxPlatform::handleNotification(const std::string& method, std::optional<json> params)
{
    if (method == "$/plugin/full")
    {
        onStudioPluginFullChange(JSON_REQUIRED_PARAMS(params, "$/plugin/full"));
        return true;
    }
    else if (method == "$/plugin/clear")
    {
        onStudioPluginClear();
        return true;
    }

    return false;
}

std::optional<json> RobloxPlatform::handleRequest(const std::string& method, std::optional<json> params)
{
    if (method == "$/plugin/getFilePaths")
    {
        // Custom request to get all Luau file paths in the workspace for plugin communication
        json result;
        std::vector<std::string> allFiles;

        // Recursively traverse the workspace directory to find all .lua and .luau files
        std::string workspacePath = workspaceFolder->rootUri.fsPath();

        Luau::FileUtils::traverseDirectoryRecursive(workspacePath,
            [&](const std::string& path)
            {
                auto uri = Uri::file(path);
                auto ext = uri.extension();
                if (ext == ".lua" || ext == ".luau")
                {
                    allFiles.push_back(path);
                }
            });

        result["files"] = allFiles;
        return result;
    }

    return std::nullopt;
}