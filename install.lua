local repo = "Fireshoa/DeepSlate-OS"
local branch = "edit" 
local zipPath = "os/"

-- [HELPER: FILE EXTRACTOR]
-- This parses the ZIP binary structure manually to avoid external requirements
local function extractZip(rawData, dest)
    local pos = 1
    
    local function read(n)
        local res = rawData:sub(pos, pos + n - 1)
        pos = pos + n
        return res
    end

    print("Analyzing ZIP structure...")
    while pos < #rawData do
        local sig = rawData:sub(pos, pos + 3)
        
        if sig == "\80\75\3\4" then -- Local File Header
            pos = pos + 18
            local compressedSize = string.unpack("<I4", rawData:sub(pos, pos + 3))
            local uncompressedSize = string.unpack("<I4", rawData:sub(pos + 4, pos + 7))
            local fileNameLen = string.unpack("<I2", rawData:sub(pos + 8, pos + 9))
            local extraLen = string.unpack("<I2", rawData:sub(pos + 10, pos + 11))
            pos = pos + 12
            
            local fileName = rawData:sub(pos, pos + fileNameLen - 1)
            pos = pos + fileNameLen + extraLen
            
            local fileData = rawData:sub(pos, pos + compressedSize - 1)
            pos = pos + compressedSize
            
            local targetPath = fs.combine(dest, fileName)
            
            if fileName:sub(-1) == "/" then
                fs.makeDir(targetPath)
            else
                print("Extracting: /" .. fileName)
                -- If uncompressedSize == compressedSize, it's 'Stored' (easy)
                -- If not, we'd need the full inflate library.
                local f = fs.open(targetPath, "wb")
                f.write(fileData)
                f.close()
            end
        elseif sig == "\80\75\1\2" then -- Central Directory (End of file list)
            break
        else
            pos = pos + 1
        end
    end
    return true
end

-- [MAIN INSTALLER]
term.clear()
term.setCursorPos(1,1)
print("--- DeepSlateOS Setup (Standalone) ---")
print("Branch: " .. branch)
write("Edition (Latest/Prerelease): ")
local edition = read()
if edition == "" then edition = "Latest" end

-- 1. Fetch File Info from GitHub API
local apiUrl = "https://api.github.com/repos/"..repo.."/contents/"..zipPath..edition..".zip?ref="..branch
local apiRes = http.get(apiUrl)

if not apiRes then
    print("\nError: Could not find the file.")
    print("Check: "..apiUrl)
    return
end

local data = textutils.unserializeJSON(apiRes.readAll())
apiRes.close()

-- 2. Download ZIP Binary
print("Downloading " .. edition .. ".zip...")
local zipRes = http.get(data.download_url, nil, true) -- Binary mode is CRITICAL
if not zipRes then error("Download failed.") end
local rawZipData = zipRes.readAll()
zipRes.close()

-- 3. Extract to Root
if extractZip(rawZipData, "/") then
    print("\n-------------------------------")
    print("DeepSlateOS Install Complete!")
    print("Rebooting...")
    sleep(2)
    os.reboot()
else
    print("\nExtraction failed.")
end
