
function _smart_tab() {
  # 1) autosuggestion(회색 제안)이 있으면 무조건 수락
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
    return
  fi

  # 2) selector 메뉴 이동 중이면 메뉴 선택
  if [[ "$KEYMAP" == "menuselect" ]]; then
    zle menu-complete
    return
  fi

  # 3) 기본 completion
  zle expand-or-complete
}

zle -N _smart_tab
bindkey '^I' _smart_tab

