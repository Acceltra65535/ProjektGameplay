local Library = {}

function Library.isFrameEmpty(sprite, frame)
  for i, cel in ipairs(sprite.cels) do
    if cel.frameNumber == frame.frameNumber then
      print(cel.image:isEmpty())
      if cel.image and cel.image:isEmpty() == false then
        return false
      end
    end
  end

  return true
end

function Library.isTagEmpty(sprite, tag)
  for i = tag.fromFrame.frameNumber, tag.toFrame.frameNumber do
    local frame = sprite.frames[i]
    
    if not Library.isFrameEmpty(sprite, frame) then
      return false
    end
  end

  return true
end

function Library.isLayerFrameEmpty(sprite, frame, layer)
  if not layer.isGroup then
    for i, cel in ipairs(sprite.cels) do
      if cel.frameNumber == frame.frameNumber and cel.layer == layer then
        if cel.image and not cel.image:isEmpty() then
          return false
        end
      end
    end
    return true
  else
    for _, subLayer in ipairs(layer.layers) do
      if not Library.isLayerFrameEmpty(sprite, frame, subLayer) then
        return false
      end
    end
    return true
  end
end

function Library.isLayerTagEmpty(sprite, tag, layer)
  for i = tag.fromFrame.frameNumber, tag.toFrame.frameNumber do
    local frame = sprite.frames[i]

    if not Library.isLayerFrameEmpty(sprite, frame, layer) then
      return false
    end
  end

  return true
end

function Library.hasGroups(sprite)
  for _, layer in ipairs(sprite.layers) do
    if layer.isGroup then
      return true
    end
  end
  
  return false
end

function Library.split(str)
    local result = {}

    if str == nil then
        return result
    end

    if type(str) == "table" then
        return str
    end

    for value in string.gmatch(str, '([^,]+)') do
        table.insert(result, value)
    end

    return result
end

function Library.getParam(name, default)
    local value = app.params[name]

    if value == nil then
        return default
    end

    return value
end

function Library.getBoolParam(name, default)
    local value = Library.getParam(name, default)

    if (value == "true") or (value == "1") then
        return true
    end

    if (value == "false") or (value == "0") then
        return false
    end

    return value
end

function Library.getArrayParam(name, default)
    local value = Library.getParam(name, default)

    if not value ~= nil then
      value = Library.split(value)
    end

    return value
end

function Library.getNumberParam(name, default)
    local value = Library.getParam(name, default)
    value = tonumber(value)

    if value == nil then
        return 0
    end

    return value
end

function Library.hideIgnoredLayers(sprite, ignoredLayers)
  for i, layer in ipairs(sprite.layers) do
    local should_hide = false
    
    for _, ignoredLayer in ipairs(ignoredLayers) do
        if layer.name == ignoredLayer then
            should_hide = true
            break
        end
    end

    if should_hide then
        layer.isVisible = false
    end
  end
end

function Library.hideTopLevelLayersExcept(sprite, ignoredLayer)
  for i, layer in ipairs(sprite.layers) do
    if layer.isGroup then
      local should_hide = layer.name ~= ignoredLayer

      if should_hide then
        layer.isVisible = false
      else
        layer.isVisible = true
      end
    end
  end
end

function Library.exportSlices(sprite)
    local spritesFolder = Library.getParam("sprites-folder", "Sprites/")
    local outputPath = spritesFolder .. app.fs.fileTitle(sprite.filename)
    app.fs.makeDirectory(outputPath)
    
    local sliceCount = {}
    
    for _, slice in ipairs(app.activeSprite.slices) do
        local sliceId = slice.data .. "/" .. slice.name
        sliceCount[sliceId] = (sliceCount[sliceId] or 0) + 1
    end
    
    for _, slice in ipairs(app.activeSprite.slices) do
        app.activeSprite:crop(slice.bounds)
    
        local sliceId = slice.data .. "/" .. slice.name
        local sliceFilename = slice.name .. ".png"
    
        if sliceCount[sliceId] > 1 then
            sliceFilename = sliceFilename .. "_" .. sliceCount[sliceId]
        end
    
        local groupPath = slice.data:gsub("[^%w_]", "/")
        local fullOutputPath = app.fs.joinPath(outputPath, groupPath)
    
        app.fs.makeDirectory(fullOutputPath)
        app.activeSprite:saveCopyAs(app.fs.joinPath(fullOutputPath, sliceFilename))
        sliceCount[sliceId] = sliceCount[sliceId] - 1
    end
end

function Library.exportTags(sprite)
    local trim = Library.getBoolParam("trim", false)
    local trimCels = Library.getBoolParam("trim-cels", false)
    local spritesFolder = Library.getParam("sprites-folder", "Sprites/")
    
    if not spritesFolder then
      spritesFolder = "Sprites/"
    end
    
    local baseFolder = spritesFolder
    local baseFilename = baseFolder .. sprite.filename
    
    if baseFilename == "" or baseFilename == nil then
      baseFilename = baseFolder
    else
      baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
    end
    
    for _, tag in ipairs(sprite.tags) do
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

function Library.exportSheet(sprite)
    local spritesFolder = Library.getParam("sprites-folder", "Sprites/")
    local baseFolder = spritesFolder
    local baseFilename = baseFolder .. sprite.filename
    
    if baseFilename == "" or baseFilename == nil then
      baseFilename = baseFolder
    else
      baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
    end
    
    local outputFilename = app.fs.joinPath(baseFilename, app.fs.fileTitle(sprite.filename) .. ".png")
    print(outputFilename)
    
    app.command.ExportSpriteSheet {
        ui = false,
        askOverwrite = false,
        type = SpriteSheetType.HORIZONTAL,
        textureFilename = outputFilename,
        splitTags = true,
        trimSprite = true,
    }
end

function Library.exportFolderTags(sprite)
    local trim = Library.getBoolParam("trim", false)
    local trimCels = Library.getBoolParam("trim-cels", false)
    local spritesFolder = Library.getParam("sprites-folder", "Sprites/")
    local baseFolder = spritesFolder
    local baseFilename = baseFolder .. sprite.filename
    
    if baseFilename == "" or baseFilename == nil then
        baseFilename = baseFolder
    else
        baseFilename = baseFolder .. app.fs.fileTitle(baseFilename)
    end
    
    for _, group in ipairs(sprite.layers) do
        if group.isGroup then
            local groupFolderPath = app.fs.joinPath(baseFilename .. "/" .. group.name)
            app.fs.makeDirectory(groupFolderPath)
            
            for _, tag in ipairs(sprite.tags) do
                if not library.isLayerTagEmpty(sprite, tag, group) then
                    local sanitizedTagName = tag.name:gsub("[^%w_]", "")
                    local outputFilename = app.fs.joinPath(groupFolderPath, sanitizedTagName .. ".png")
                    
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
    
    if not Library.hasGroups(sprite) then
        for _, tag in ipairs(sprite.tags) do
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

return Library