local library = require("Library")
local sprite = app.activeSprite
local trim = app.params["trim"]
local trimCels = app.params["trim-cels"]
local spritesFolder = app.params["sprites-folder"]
local ignoredLayers = library.getArrayParam("ignored-layers")
local ignoredTags = library.getArrayParam("ignored-tags")
local singleTag = library.getParam("tag", "")
local singleLayer = library.getParam("layer", "")
local filename = library.getParam("filename", "")
local scale = library.getNumberParam("scale", 1)
local folder = library.getParam("folder", "{name}")

spritesFolder = string.gsub(spritesFolder, "{space}", " ")
library.hideIgnoredLayers(app.activeSprite, ignoredLayers)
folder = string.gsub(folder, "{name}", app.fs.fileTitle(sprite.filename))

if singleLayer ~= "" then
  library.hideTopLevelLayersExcept(app.activeSprite, singleLayer)
end

if not spritesFolder then
  spritesFolder = "Sprites/"
end

if not trim then
  trim = true
end

if trim == "false" then
  trim = false
end

if trimCels == "true" then
  trimCels = true
end

if not sprite then
  return app.alert("No active sprite")
end

if scale ~= 1 then
  sprite:resize(sprite.width * scale, sprite.height * scale) 
end

local baseFolder = spritesFolder .. "/" .. folder .. "/" 
local baseFilename = baseFolder .. sprite.filename

filename = string.gsub(filename, "{name}", app.fs.fileTitle(sprite.filename))

if baseFilename == "" or baseFilename == nil then
  baseFilename = baseFolder
else
  baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
end

for _, tag in ipairs(sprite.tags) do
    local should_hide = false

    if singleTag ~= "" then
      if singleTag ~= tag.name then
        should_hide = true
      end
    end
    
    for _, ignoredTag in ipairs(ignoredTags) do
        if tag.name == ignoredTag then
            should_hide = true
            break
        end
    end

    if not should_hide then
      local sanitizedTagName = tag.name:gsub("[^%w_]", "")
      local tagFilename = filename
      tagFilename = string.gsub(tagFilename, "{tag}", sanitizedTagName)
      local outputFilename = app.fs.joinPath(baseFilename, tagFilename)

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