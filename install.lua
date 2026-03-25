--Ty Gemini for great code
local function downloadFolder(repo, folderPath, localDir)
    -- GitHub API URL for the folder content
    local url = "https://api.github.com/repos/" .. repo .. "/contents/" .. folderPath
    
    local response = http.get(url)
    if not response then
        print("Failed to connect to GitHub API.")
        return false
    end

    local data = textutils.unserializeJSON(response.readAll())
    response.close()

    if not fs.exists(localDir) then
        fs.makeDir(localDir)
    end

    for _, file in ipairs(data) do
        if file.type == "file" then
            print("Downloading: " .. file.name)
            local fileRes = http.get(file.download_url)
            if fileRes then
                local f = fs.open(fs.combine(localDir, file.name), "w")
                f.write(fileRes.readAll())
                f.close()
                fileRes.close()
            end
        elseif file.type == "dir" then
            -- Optional: Handle subfolders recursively
            downloadFolder(repo, folderPath .. "/" .. file.name, fs.combine(localDir, file.name))
        end
    end
    return true
end

-- Example Usage:
write("Ver (Default 'Latest'): ")
v = read()
if v == "" then
    v = "Latest"
end
print("Installing DeepSlateOS: " .. v)
downloadFolder("Fireshoa/DeepSlate-OS", "os/" .. v, "test/")