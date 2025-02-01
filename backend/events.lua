local function on_player_join(player, first)
  print(player.ID.." has joined.")
end

local function on_player_leave(player)
  print(player.ID.." has left.")
end

return {on_player_join=on_player_join, on_player_leave=on_player_leave}
