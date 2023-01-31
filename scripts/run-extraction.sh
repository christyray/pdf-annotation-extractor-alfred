#!/bin/zsh
# shellcheck disable=2164
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

function notify() {
	osascript -e "display notification \"$2\" with title \"$1\""
}

#───────────────────────────────────────────────────────────────────────────────
# GUARD CLAUSES & RETRIEVE PATH/CITEKEY

if [[ ! -f "$bibtex_library_path" ]]; then
	notify "Error" "$bibtex_library_path does not exist."
	exit 1
fi

pdf_path=$(osascript "./scripts/get-pdf-path.applescript")
if [[ ! "$pdf_path" == *.pdf ]]; then
	notify "Error" "Not a .pdf file."
	exit 1
fi

citekey=$(basename "$pdf_path" .pdf | sed -E 's/_.*//')
entry=$(grep --after-context=20 --max-count=1 --ignore-case "{$citekey," "$bibtex_library_path")
if [[ -z "$entry" ]]; then
	notify "Error" "No entry with the citekey $citekey not found in library file."
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────
# EXTRACTION
notify "Annotation Extractor" "⏳ Running Extraction…"

if [[ "$extraction_engine" == "pdfannots" ]]; then
	annotations=$(pdfannots --no-group --format=json "$pdf_path")
else
	IMAGE_FOLDER="${obsidian_destination/#\~/$HOME}/attachments/image_temp"
	wd="$PWD"

	mkdir -p "$IMAGE_FOLDER" && cd "$IMAGE_FOLDER"

	annotations=$(pdfannots2json "$pdf_path" --image-output-path=./ --image-format="png")

	# IMAGE EXTRACTION
	# shellcheck disable=SC2012
	NUMBER_OF_IMAGES=$(ls | wc -l | tr -d " ")
	[[ $NUMBER_OF_IMAGES -eq 0 ]] && exit 0 # abort if no images

	# HACK: fix zero-padding for low page numbers, all images get 4 digits.
	# see https://github.com/mgmeyers/pdfannots2json/issues/16
	for image in *; do
		leftPadded=$(echo "$image" | sed -E 's/-([[:digit:]])-/-000\1-/' | sed -E 's/-([[:digit:]][[:digit:]])-/-00\1-/' | sed -E 's/-([[:digit:]][[:digit:]][[:digit:]])-/-0\1-/')
		mv "$image" "$leftPadded"
	done

	# rename for workflow
	i=1
	for image in *; do
		mv -f "$image" ../"${citekey}_image${i}.png"
		i=$((i + 1))
	done

	rmdir "$IMAGE_FOLDER" # remove temp folder
	cd "$wd"
fi

#───────────────────────────────────────────────────────────────────────────────

# PROCESS ANNOTATIONS
osascript -l JavaScript "./scripts/process_annotations.js" "$citekey" "$annotations"
