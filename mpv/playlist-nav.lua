-- Register keybinds to quickly navigate to playlist items 1 to 9.
for i = 1, 9 do
  local is = tostring(i)
  mp.add_key_binding(is, "playlist-go-" .. is, function()
    -- Don't try to go to a non-existing item in a playlist.
    local max = mp.get_property_number("playlist-count", 1)
    if i > max then return end

    mp.set_property_number("playlist-pos-1", i)
  end)
end

-- TODO(aktau): Multiple digit numbers. We can probably use the same hack as
-- repl.lua: https://github.com/rossy/mpv-repl/blob/master/repl.lua#L625.
