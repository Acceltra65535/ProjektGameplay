local library = require("Library")
local sprite = app.activeSprite
local spritesFolder = library.getParam("sprites-folder")
local layer = library.getParam("layer", "")
local scale = library.getNumberParam("scale", 1)
local ignoredLayers = library.getArrayParam("ignored-layers")
local filename = library.getParam("filename", "")
local folder = library.getParam("folder", "{name}")

spritesFolder = string.gsub(spritesFolder, "{space}", " ")


if not spritesFolder then
  spritesFolder = "Sprites/"
end

if not sprite then
  return app.alert("No active sprite")
end


filename = string.gsub(filename, "{name}", app.fs.fileTitle(sprite.filename))
folder = string.gsub(folder, "{name}", app.fs.fileTitle(sprite.filename))

local baseFilename = spritesFolder .. "/" .. folder .. "/"
local outputFilename = baseFilename .. filename

if scale ~= 1 then
  sprite:resize(sprite.width * scale, sprite.height * scale) 
end

print(outputFilename)

library.hideIgnoredLayers(sprite, ignoredLayers)

app.command.ExportSpriteSheet {
    ui = false,
    askOverwrite = false,
    type = SpriteSheetType.HORIZONTAL,
    textureFilename = outputFilename,
    layer = layer,
    splitTags = true,
    -- trimSprite = true,
}