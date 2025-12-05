local library = require("Library")
local sprite = app.activeSprite
local trim = app.params["trim"]
local trimCels = app.params["trim-cels"]
local spritesFolder = app.params["sprites-folder"]
local ignoredLayers = library.getArrayParam("ignored-layers")
local ignoredTags = library.getArrayParam("ignored-tags")
local singleTag = library.getParam("tag", "")
local filename = library.getParam("filename", "{name}_{layer}.png")
local singleLayer = library.getParam("layer", "")
local scale = library.getNumberParam("scale", 1)
local folder = library.getParam("folder", "{name}")

spritesFolder = string.gsub(spritesFolder, "{space}", " ")

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

library.hideIgnoredLayers(sprite, ignoredLayers)

folder = string.gsub(folder, "{name}", app.fs.fileTitle(sprite.filename))

local baseFolder = spritesFolder .. "/" .. folder .. "/"
local baseFilename = baseFolder
filename = string.gsub(filename, "{name}", app.fs.fileTitle(sprite.filename))


if baseFilename == "" or baseFilename == nil then
  baseFilename = baseFolder
else
  baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
end

for _, group in ipairs(sprite.layers) do
  if group.isGroup or group.parent == sprite then
    local should_hide = false
    print("inside")

    if singleLayer ~= "" then
      if singleLayer ~= group.name then
        should_hide = true
      end
    end

    for _, ignoredLayer in ipairs(ignoredLayers) do
      if group.name == ignoredLayer then
          should_hide = true
          break
      end
    end

    if not should_hide then
        local layerFilename = filename
        layerFilename = string.gsub(layerFilename, "{layer}", group.name)

        local groupFolderPath = app.fs.joinPath(baseFilename .. "\\" .. layerFilename)
        print(groupFolderPath)
      
        app.command.ExportSpriteSheet {
            ui = false,
            askOverwrite = false,
            layer = group.name,
            type = SpriteSheetType.HORIZONTAL,
            textureFilename = groupFolderPath
        }
    end
  end
end
