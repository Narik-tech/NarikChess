# FiveDPGN.gd
# Helper parser for 5DPGN-like files (tags + timeline board blocks + move text)
# Usage:
#   var p = FiveDPGN.parse_string(text)
#   print(p.tags)
#   print(p.timelines)
#   print(p.moves)

class_name FiveDPGN

# -----------------------------
# Public API
# -----------------------------

static func parse_string(text: String) -> Dictionary:
	var result := {
		"tags": {},        # e.g. {"Mode":"5D","White":"recon",...}
		"timelines": [],   # board state blocks: raw strings (can post-parse later)
		"moves": []        # parsed ply list (each entry is one side's ply)
	}
	var lines := _split_lines(text)

	var i := 0
	# 1) Parse header/tag lines + timeline board blocks
	while i < lines.size():
		var line := lines[i].strip_edges()
		if line.is_empty():
			i += 1
			continue

		# Tag line: [Key "Value"]
		if line.begins_with("[") and line.ends_with("]") and line.find("\"") != -1:
			var tag := _parse_tag_line(line)
			if tag.size() == 2:
				result.tags[tag[0]] = tag[1]
			i += 1
			continue

		# Timeline board/state blocks in your sample also appear as bracketed lines:
		# [r*nbqk*bnr*/...:0:0:b]
		# They don't have quotes, so treat as timeline raw blocks.
		if line.begins_with("[") and line.ends_with("]") and line.find("\"") == -1:
			result.timelines.append(line.substr(1, line.length() - 2))
			i += 1
			continue

		# First non-tag/non-timeline line means moves section begins
		break

	# 2) Parse moves section (may span multiple lines)
	var moves_text := ""
	while i < lines.size():
		var line := lines[i].strip_edges()
		if not line.is_empty():
			if moves_text.is_empty():
				moves_text = line
			else:
				moves_text += " " + line
		i += 1

	result.moves = _parse_moves_section(moves_text)
	return result

# -----------------------------
# Moves parsing
# -----------------------------

# Output format:
# result.moves = [
#   {
#     "move_number": 1,
#     "white": {"clock":"20:05","turn":"0T1","san":"Ng1f3","raw":"{20:05}(0T1)Ng1f3"},
#     "black": {"clock":"20:05","turn":"0T1","san":"Ng8f6","raw":"{20:05}(0T1)Ng8f6"}
#   },
#   ...
# ]
static func _parse_moves_section(text: String) -> Array:
	var s := text.strip_edges()
	if s.is_empty():
		return []

	# Normalize spacing around "/" so splitting is easier.
	# Your format: " ... Ng1f3 / {..}Ng8f6"
	s = s.replace("\t", " ")
	while s.find("  ") != -1:
		s = s.replace("  ", " ")

	var entries := []
	var idx := 0

	while idx < s.length():
		# Find next move number like "12."
		var num_info := _find_next_move_number(s, idx)
		if num_info.is_empty():
			break
		var move_number = num_info["number"]
		idx = num_info["after_dot"]

		# Read white ply until we hit "/" or next move number.
		var white_end := _find_delim_for_ply(s, idx)
		var white_raw := s.substr(idx, white_end - idx).strip_edges()
		idx = white_end

		# Consume optional "/" (black ply delimiter)
		if idx < s.length():
			# allow spaces around delimiter
			while idx < s.length() and s[idx] == " ":
				idx += 1
			if idx < s.length() and s[idx] == "/":
				idx += 1
			while idx < s.length() and s[idx] == " ":
				idx += 1

		# Read black ply until next move number or end.
		var black_end := _find_next_move_number_start(s, idx)
		var black_raw := ""
		if black_end == -1:
			black_raw = s.substr(idx, s.length() - idx).strip_edges()
			idx = s.length()
		else:
			black_raw = s.substr(idx, black_end - idx).strip_edges()
			idx = black_end

		# Build record
		var rec := {
			"move_number": move_number,
			"white": _parse_ply(white_raw),
			"black": _parse_ply(black_raw)
		}
		entries.append(rec)

	return entries

# Ply format in sample:
#   {20:05}(0T1)Ng1f3
# There can also be comments elsewhere; this parser focuses on this exact prefix pattern.
static func _parse_ply(raw: String) -> Dictionary:
	var ply := {"clock": null, "turn": null, "san": null, "raw": raw}

	var r := raw.strip_edges()
	if r.is_empty():
		return ply

	# Extract {clock}
	var clock = null
	if r.begins_with("{"):
		var close := r.find("}")
		if close != -1:
			clock = r.substr(1, close - 1)
			r = r.substr(close + 1, r.length() - (close + 1)).strip_edges()

	# Extract (turn)
	var turn = null
	if r.begins_with("("):
		var close2 := r.find(")")
		if close2 != -1:
			turn = r.substr(1, close2 - 1)
			r = r.substr(close2 + 1, r.length() - (close2 + 1)).strip_edges()

	# Remaining is the move token(s). Keep first token as "san" (or long algebraic).
	# Sample uses "Ng1f3" / "c2c4".
	var move_token := r
	# If there are trailing annotations, keep only up to first space.
	var sp := move_token.find(" ")
	if sp != -1:
		move_token = move_token.substr(0, sp)

	ply.clock = clock
	ply.turn = turn
	ply.san = move_token if not move_token.is_empty() else null
	return ply

static func _find_next_move_number(s: String, from_idx: int) -> Dictionary:
	var i := from_idx
	while i < s.length():
		# seek digit
		if s[i] >= "0" and s[i] <= "9":
			# parse integer
			var j := i
			while j < s.length() and s[j] >= "0" and s[j] <= "9":
				j += 1
			# require dot
			if j < s.length() and s[j] == ".":
				var num_str := s.substr(i, j - i)
				return {"number": int(num_str), "after_dot": j + 1}
		i += 1
	return {}

static func _find_next_move_number_start(s: String, from_idx: int) -> int:
	# returns index of the digit where "<digits>." begins, else -1
	var i := from_idx
	while i < s.length():
		if s[i] >= "0" and s[i] <= "9":
			var j := i
			while j < s.length() and s[j] >= "0" and s[j] <= "9":
				j += 1
			if j < s.length() and s[j] == ".":
				return i
		i += 1
	return -1

static func _find_delim_for_ply(s: String, from_idx: int) -> int:
	# stop at "/" OR next move number start, whichever comes first
	var slash := s.find("/", from_idx)
	var next_num := _find_next_move_number_start(s, from_idx)
	if slash == -1 and next_num == -1:
		return s.length()
	if slash == -1:
		return next_num
	if next_num == -1:
		return slash
	return min(slash, next_num)

# -----------------------------
# Tag/timeline parsing
# -----------------------------

static func _parse_tag_line(line: String) -> Array:
	# [Key "Value"]
	var inner := line.substr(1, line.length() - 2).strip_edges()
	var sp := inner.find(" ")
	if sp == -1:
		return []
	var key := inner.substr(0, sp).strip_edges()
	var rest := inner.substr(sp + 1, inner.length() - (sp + 1)).strip_edges()

	# rest should be "Value" (quoted)
	if not rest.begins_with("\""):
		return []
	var last_quote := rest.rfind("\"")
	if last_quote <= 0:
		return []
	var val := rest.substr(1, last_quote - 1)
	return [key, val]

static func _split_lines(text: String) -> PackedStringArray:
	# Handle Windows/Mac newlines
	var t := text.replace("\r\n", "\n").replace("\r", "\n")
	return t.split("\n", false)
