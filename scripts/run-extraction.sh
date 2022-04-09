#!/bin/zsh
# shellcheck disable=SC2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
mkdir -p "$alfred_workflow_cache"

# pdfannots
if [[ "$extractor_cli" == "pdfannots" ]]; then
	python3 -c "import pdfminer"
	pdfannots "$file_path" --format json > "$alfred_workflow_cache"/temp.json
	exit 0
fi

# pdf-annots2json

image_folder="${obsidian_destination/#\~/$HOME}"/attachments

pdf-annots2json "$file_path" \
	--image-output-path="$image_folder/image_temp" \
	--image-format="png" \
	--image-base-name="image" \
	> "$alfred_workflow_cache"/temp.json

# move images properly renamed up
if [[ "$citekey_insertion" == "none" ]] ; then
	filename=$(date '+%Y-%m-%d')
else
	filename="$citekey"
fi

cd "$image_folder/image_temp" || exit 1
for image in *; do
	clean_name="$(echo "$image" | cut -d- -f-2 | tr -d "-").png"
	mv "$image" ../"${filename}_$clean_name"
done