-- init is called every time a chunk is loaded, if the chunk has been loaded before then chunk.Generated will be true, else it will be false
function init()
  -- let's set some random data in the chunk's data store
  chunk.Data.test = "test"
  -- do this block of code if the chunk is at (0,0) in chunk space and has not been generated yet
  if chunk.X == 1 and chunk.Y == 1 and not chunk.Generated then
    for i=1,20 do
      -- create entity with parameters: type, x, y, z, data
      -- type must match the name of one of the lua files in entity folder of this repo
      -- data is an arbitrary lua table
      api.entity.Create("tst", -35, 25, 0, {name="jar jar "..i})
    end
  end
  if not chunk.Generated then
    print("Initialised chunk at (", chunk.X, chunk.Y, ")")
    for i=1,25 do
      -- create some tree entities at random locations, 'math' and other standard lua library functions (excluding io/os operations) are included
      api.entity.Create("tree", (chunk.X + math.random()) * chunk.Size, (chunk.Y+math.random()) * chunk.Size, 0, {})
    end
  end
  print(chunk.Data)
end
