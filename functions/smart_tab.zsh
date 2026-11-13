
function _smart_tab() {
  # 1) selector 메뉴 이동 중이면 메뉴 선택
  if [[ "$KEYMAP" == "menuselect" ]]; then
    zle menu-complete
    return
  fi

  # 2) 기본 completion
  zle expand-or-complete
}

zle -N _smart_tab
bindkey '^I' _smart_tab

