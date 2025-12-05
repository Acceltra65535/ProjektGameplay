local library = require("Library")
local sprite = app.activeSprite
local spritesFolder = app.params["sprites-folder"]
local ignoredLayers = library.getArrayParam("ignored-layers")
local ignoredSlices = library.getArrayParam("ignored-slices")
local singleSlice = library.getParam("slice", "")
local scale = library.getNumberParam("scale", 1)
local folder = library.getParam("folder", "{name}")

spritesFolder = string.gsub(spritesFolder, "{space}", " ")

if not spritesFolder then
  spritesFolder = "Sprites/"
end

library.hideIgnoredLayers(app.activeSprite, ignoredLayers)

folder = string.gsub(folder, "{name}", app.fs.fileTitle(sprite.filename))
local outputPath = spritesFolder .. "/" .. folder .. "/" app.fs.fileTitle(app.activeSprite.filename)
app.fs.makeDirectory(outputPath)

if scale ~= 1 then
    sprite:resize(sprite.width * scale, sprite.height * scale) 
end

local sliceCount = {}
for _, slice in ipairs(app.activeSprite.slices) do
    local sliceId = slice.data .. "/" .. slice.name
    sliceCount[sliceId] = (sliceCount[sliceId] or 0) + 1
end

for _, slice in ipairs(app.activeSprite.slices) do
    local should_hide = false

    if singleSlice ~= "" then
        if slice.name ~= singleSlice then
            should_hide = true
        end
    end
    
    for _, ignoredSlice in ipairs(ignoredSlices) do
        if slice.name == ignoredSlice then
            should_hide = true
            break
        end
    end
    
    local sliceId = slice.data .. "/" .. slice.name

    if not should_hide then
        app.activeSprite:crop(slice.bounds)

        local sliceFilename = slice.name .. ".png"

        if sliceCount[sliceId] > 1 then
            sliceFilename = sliceFilename .. "_" .. sliceCount[sliceId]
        end

        local groupPath = slice.data:gsub("[^%w_]", "/")
        local fullOutputPath = app.fs.joinPath(outputPath, groupPath)

        app.fs.makeDirectory(fullOutputPath)
        app.activeSprite:saveCopyAs(app.fs.joinPath(fullOutputPath, sliceFilename))
    end
    
    sliceCount[sliceId] = sliceCount[sliceId] - 1
    
end

return 0