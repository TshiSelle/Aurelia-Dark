# Aurelia Dark — FZF color configuration for fish
# Sets FZF_DEFAULT_OPTS to match the Aurelia palette

set -Ux FZF_DEFAULT_OPTS "\
  --color=bg+:#2B303B,bg:#181B25,spinner:#F05629,hl:#F05629 \
  --color=fg:#E1E4EA,header:#F05629,info:#A97EF8,pointer:#F05629 \
  --color=marker:#F87F6B,fg+:#E1E4EA,prompt:#F05629,hl+:#F87F6B \
  --color=border:#525866,label:#99A0AE,query:#E1E4EA \
  --border=rounded \
  --border-label='' \
  --preview-window=border-rounded \
  --padding=1 \
  --prompt=' ' \
  --marker='●' \
  --pointer='▶' \
  --separator='─' \
  --scrollbar='│' \
  --info=right"
