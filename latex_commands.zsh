# Global variables for containing the result of _tex_parse_args
# Using after calling the function
typeset -g _TEX_FILTERED_ARGS
typeset -g _TEX_NOCLEAR

# Common function for detecting and removing --noclear
# Result will be contained in _TEX_FILTERED_ARGS and _TEX_NOCLEAR
_tex_parse_args() {
  _TEX_NOCLEAR=0
  _TEX_FILTERED_ARGS=()

  for arg in "$@"; do
    if [[ "$arg" == "--noclear" ]]; then
      _TEX_NOCLEAR=1
    else
      _TEX_FILTERED_ARGS+=("$arg")
    fi
  done
}

# Common function for removing the temporary files due to compiling TeX
_tex_cleanup() {
  local exit_status=$1
  shift

  # Collect extensions until "--"
  local extra_extensions=()
  while [[ $1 != "--" ]]; do
    extra_extensions+=("$1")
    shift
  done
  shift  # Skip "--"

  # Common extensions + Extensions which belong to compiler
  local all_extensions=(aux log out toc "${extra_extensions[@]}")

  # Find .tex files from the parameters left
  for arg in "$@"; do
    if [[ "$arg" == *.tex ]]; then
      local base="${arg%.tex}"
      for ext in "${all_extensions[@]}"; do
        [[ -f "${base}.${ext}" ]] && rm "${base}.${ext}"
      done
    fi
  done

  return $exit_status
}

# LuaLaTeX
lualatex() {
  _tex_parse_args "$@"

  command lualatex "${_TEX_FILTERED_ARGS[@]}"
  local exit_status=$?

  if (( _TEX_NOCLEAR == 0 )); then
    _tex_cleanup $exit_status nav snm -- "${_TEX_FILTERED_ARGS[@]}"
  fi

  return $exit_status
}

# pdfLaTeX
pdflatex() {
  _tex_parse_args "$@"

  command pdflatex "${_TEX_FILTERED_ARGS[@]}"
  local exit_status=$?

  if (( _TEX_NOCLEAR == 0 )); then
    _tex_cleanup $exit_status nav snm -- "${_TEX_FILTERED_ARGS[@]}"
  fi

  return $exit_status
}

# XeLaTeX
xelatex() {
  _tex_parse_args "$@"

  command xelatex "${_TEX_FILTERED_ARGS[@]}"
  local exit_status=$?

  if (( _TEX_NOCLEAR == 0 )); then
    _tex_cleanup $exit_status nav snm -- "${_TEX_FILTERED_ARGS[@]}"
  fi

  return $exit_status
}

# pLaTeX
platex() {
  _tex_parse_args "$@"

  command platex "${_TEX_FILTERED_ARGS[@]}"
  local exit_status=$?

  if (( _TEX_NOCLEAR == 0 )); then
    _tex_cleanup $exit_status nav snm -- "${_TEX_FILTERED_ARGS[@]}"
  fi

  return $exit_status
}

# upLaTeX
uplatex() {
  _tex_parse_args "$@"

  command uplatex "${_TEX_FILTERED_ARGS[@]}"
  local exit_status=$?

  if (( _TEX_NOCLEAR == 0 )); then
    _tex_cleanup $exit_status nav snm -- "${_TEX_FILTERED_ARGS[@]}"
  fi

  return $exit_status
}