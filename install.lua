-- DeepSlateOS Edition Installer
local repo = "Fireshoa/DeepSlate-OS"
local rootZipPath = "os/" -- Where the zips live in your repo

-- 1. Get Edition from User
term.clear()
term.setCursorPos(1,1)
print("--- DeepSlateOS Setup ---")
write("Select Edition (Default: Latest): ")
local edition = read()
if edition == "" then edition = "Latest" end

local zipFileName = edition .. ".zip"
local tempZip = "install_temp.zip"

-- 2. Ensure Unzip Utility exists
if not fs.exists("unzip.lua") then
    print("Fetching unzip utility...")
    local res = http.get("https://pastebin.com/raw/SBy7N69A")
    if res then
        local f = fs.open("unzip.lua", "w")
        f.write(res.readAll())
        f.close()
        res.close()
    else
        error("Could not download unzip utility.")
    end
end

-- 3. Get the Download URL via GitHub API
-- This finds the specific zip file inside your 'os/' folder
local apiUrl = "https://api.github.com/repos/" .. repo .. "/contents/" .. rootZipPath .. zipFileName
print("Connecting to GitHub...")
local apiRes = http.get(apiUrl)
if not apiRes then error("Edition '" .. edition .. "' not found!") end

local data = textutils.unserializeJSON(apiRes.readAll())
apiRes.close()
local downloadUrl = data.download_url

-- 4. Download and Extract
print("Downloading " .. edition .. " edition...")
local zipRes = http.get(downloadUrl)
if zipRes then
    local f = fs.open(tempZip, "wb")
    f.write(zipRes.readAll())
    f.close()
    zipRes.close()
    
    print("Extracting to root...")
    shell.run("unzip.lua", tempZip, "/")
    
    -- Cleanup
    fs.delete(tempZip)
    fs.delete("unzip.lua")
    
    print("\nInstallation successful!")
    print("Press any key to reboot...")
    os.pullEvent("key")
    os.reboot()
else
    error("Failed to download ZIP content.")
end
