#!/bin/bash

ASEPRITE_PATH="Aseprite"
SPRITES_FOLDER="./Exports/"
EXPORT_FOLDER_TAG_COMBINATIONS="./ExportFolderTagCombinations.lua"
EXPORT_TAGS="./ExportTags.lua"
EXPORT_SLICES="./ExportSlices.lua"
EXPORT_SLICE_TAGS="./ExportSliceTags.lua"
EXPORT_SHEET="./ExportSheet.lua"
EXPORT_LAYERS="./ExportLayers.lua"
export_count=0

progress_bar() {
    local current=0
    local total=$1
    local bar_length=50
    local green="\033[0;32m"
    local reset="\033[0m"
    
    while [ $current -le $total ]; do
        percentage=$((current * 100 / total))
        progress=$((current * bar_length / total))
        
        printf "\r["
        for ((i = 0; i < $progress; i++)); do
            printf "${green}#${reset}"
        done
        for ((i = $progress; i < bar_length; i++)); do
            printf " "
        done
        printf "] %d%%" $percentage
        
        sleep 0.1
        ((current++))
    done
    echo ""
}

select_exports() {
    local file_path="$1"
    local results=""
    local selected_indices

    echo "Available exports:" > /dev/tty
    jq -r '.exports[].file' "$file_path" | nl > /dev/tty

    echo "Enter the number(s) of the exports to process (separated by spaces), or press Enter to export all:" > /dev/tty
    read -r selected_indices < /dev/tty

    if [[ -z "$selected_indices" ]]; then
        results=$(jq -c '.exports[]' "$file_path")
    else
        for index in $selected_indices; do
            if [[ "$index" =~ ^[0-9]+$ ]] && jq -e ".exports[$((index - 1))]" "$file_path" > /dev/null 2>&1; then
                result=$(jq -c ".exports[$((index - 1))]" "$file_path")
                results+="$result"$'\n'
            else
                echo "Invalid selection: $index" > /dev/tty
            fi
        done
    fi

    echo "$results"
}

process_exports() {
    local file_path="$1"
    local selected_exports="$2"

    if [[ ! -f "$file_path" ]]; then
        echo "File not found: $file_path"
        exit 1
    fi

    directory=$(jq -r '.directory' "$file_path")

    echo "$selected_exports" | while IFS= read -r export; do
        file=$(echo "$export" | jq -r '.file')
        echo "Sprite: $file"

        export_presets=$(echo "$export" | jq -c '.presets[]')
        total_presets=$(echo "$export_presets" | wc -l)
        current_preset=0

        echo "$export" | jq -c '.presets[]' | while IFS= read -r preset; do
            jq -r '.destinations[]' "$file_path" | while IFS= read -r destination; do
                ((current_preset++))
                preset_type=$(echo "$preset" | jq -r '.type')
                filename=$(echo "$preset" | jq -r '.filename // "{name}.png"')
                folder=$(echo "$preset" | jq -r '.folder // "{name}"')
                scale=$(echo "$preset" | jq -r '.scale // 1')
                tag=$(echo "$preset" | jq -r '.tag // ""')
                layer=$(echo "$preset" | jq -r '.layer // ""')
                slice=$(echo "$preset" | jq -r '.slice // ""')
                ignored_layers=$(echo "$preset" | jq -r '.ignored_layers // [] | join(",")')
                ignored_slices=$(echo "$preset" | jq -r '.ignored_slices // [] | join(",")')
                ignored_tags=$(echo "$preset" | jq -r '.ignored_tags // [] | join(",")')

                filepath="$directory$file.aseprite"
                destination=$(echo "$destination" | sed 's/ /{space}/g')
                ADDITIONAL_PARAMS=" --script-param scale=$scale --script-param ignored-layers=$ignored_layers --script-param ignored-slices=$ignored_slices --script-param ignored-tags=$ignored_tags --script-param tag=$tag --script-param layer=$layer --script-param slice=$slice --script-param filename=$filename --script-param folder=$folder"
                PARAMS="--script-param sprites-folder=$destination" 

                echo "Exporting $preset_type from $filepath to $destination\\$folder\\$filename"
                progress_bar $total_presets

                case "$preset_type" in
                    "sheet")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script "$EXPORT_SHEET" > /dev/null 2>&1
                        ;;
                    "slices")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script-param trim-cels="true" --script "$EXPORT_SLICES" > /dev/null 2>&1
                        ;;
                    "slice_tags")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script-param trim-cels="true" --script "$EXPORT_SLICE_TAGS" > /dev/null 2>&1
                        ;;
                    "tags")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script-param trim-cels="true" --script "$EXPORT_TAGS" > /dev/null 2>&1
                        ;;
                    "folder_tags")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script "$EXPORT_FOLDER_TAG_COMBINATIONS" > /dev/null 2>&1
                        ;;
                    "layers")
                        "$ASEPRITE_PATH" -b $filepath $PARAMS $ADDITIONAL_PARAMS --script "$EXPORT_LAYERS" > /dev/null 2>&1
                        ;;
                    *)
                        echo "  Unknown preset type: $preset_type"
                        ;;
                esac

                export_count=$((export_count + 1))
            done
            echo ""
        done
    done

    echo "Process completed!"
    echo "---"
}

main() {
    json_file="export.json"
    selected_exports=$(select_exports "$json_file" | tee /dev/tty)
    process_exports "$json_file" "$selected_exports"
}

while true; do
    main
done