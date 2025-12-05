local library = require("Library")
local sprite = app.activeSprite
local spritesFolder = app.params["sprites-folder"]
local ignoredLayers = library.getArrayParam("ignored-layers")
local ignoredSlices = library.getArrayParam("ignored-slices")
local singleSlice = library.getParam("slice", "")
local scale = library.getNumberParam("scale", 1)
local filename = library.getParam("filename", "{name}_{slicename}_{tag}")
local folder = library.getParam("folder", "{name}")

spritesFolder = string.gsub(spritesFolder, "{space}", " ")

if not spritesFolder then
  spritesFolder = "Sprites/"
end

library.hideIgnoredLayers(app.activeSprite, ignoredLayers)

folder = string.gsub(folder, "{name}", app.fs.fileTitle(sprite.filename))
local outputPath = spritesFolder .. folder
app.fs.makeDirectory(outputPath)
filename = string.gsub(filename, "{name}", app.fs.fileTitle(sprite.filename))

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

        local sliceFilename = filename

        sliceFilename = string.gsub(sliceFilename, "{slicename}", slice.name)

        local groupPath = slice.data:gsub("[^%w_]", "/")
        local fullOutputPath = app.fs.joinPath(outputPath, groupPath)

        for _, tag in ipairs(sprite.tags) do
            local should_hide = false
        
            if not should_hide then
              local sanitizedTagName = tag.name:gsub("[^%w_]", "")
              local tagFilename = sliceFilename
              tagFilename = string.gsub(tagFilename, "{tag}", sanitizedTagName)
              local outputFilename = app.fs.joinPath(outputPath, tagFilename)
              print(outputFilename)
        
              app.command.ExportSpriteSheet {
                ui = false,
                askOverwrite = false,
                tag = tag.name,
                type = SpriteSheetType.HORIZONTAL,
                textureFilename = outputFilename,
                splitTags = true,
                trimSprite = trim
              }
            end
        end
    end
    
    sliceCount[sliceId] = sliceCount[sliceId] - 1
    
end

return 0