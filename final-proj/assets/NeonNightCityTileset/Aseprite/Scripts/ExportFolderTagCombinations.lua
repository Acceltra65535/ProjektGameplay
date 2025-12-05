local library = require("Library")
local sprite = app.activeSprite
local trim = app.params["trim"]
local trimCels = app.params["trim-cels"]
local spritesFolder = app.params["sprites-folder"]
local ignoredLayers = library.getArrayParam("ignored-layers")
local ignoredTags = library.getArrayParam("ignored-tags")
local singleTag = library.getParam("tag", "")
local singleLayer = library.getParam("layer", "")
local scale = library.getNumberParam("scale", 1)
local folder = library.getParam("folder", "{name}")
local filename = library.getParam("filename", "{name}_{layer}_{tag}.png")

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
local baseFilename = baseFolder .. sprite.filename
filename = string.gsub(filename, "{name}", app.fs.fileTitle(sprite.filename))

if baseFilename == "" or baseFilename == nil then
  baseFilename = baseFolder
else
  baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
end

for _, group in ipairs(sprite.layers) do
  if group.isGroup then
    local should_hide = false

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
      local groupFolderPath = app.fs.joinPath(baseFilename)
      app.fs.makeDirectory(groupFolderPath)
      
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
          if not library.isLayerTagEmpty(sprite, tag, group) then
            local layerFilename = filename
            
            local sanitizedTagName = tag.name:gsub("[^%w_]", "")
            layerFilename = string.gsub(layerFilename, "{layer}", group.name)
            layerFilename = string.gsub(layerFilename, "{tag}", sanitizedTagName)
            local outputFilename = app.fs.joinPath(groupFolderPath, layerFilename)

            print(outputFilename)
    
            app.command.ExportSpriteSheet {
              ui = false,
              askOverwrite = false,
              tag = tag.name,
              layer = group.name,
              type = SpriteSheetType.HORIZONTAL,
              textureFilename = outputFilename,
              splitTags = true,
              trimSprite = true,
              innerPadding = 1
            }
          end
        end
      end
    end
  end
end

local function has_groups(sprite)
  for _, layer in ipairs(sprite.layers) do
    if layer.isGroup then
      return true
    end
  end
  return false
end

if not has_groups(sprite) then
  for _, tag in ipairs(sprite.tags) do
    local should_hide = false
  
    for _, ignoredTag in ipairs(ignoredTags) do
      if tag.name == ignoredTag then
          should_hide = true
          break
      end
    end

    if not should_hide then
      if not library.isTagEmpty(sprite, tag) then
        local sanitizedTagName = tag.name:gsub("[^%w_]", "")
        local outputFilename = app.fs.joinPath(baseFilename, sanitizedTagName .. ".png")
  
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
end