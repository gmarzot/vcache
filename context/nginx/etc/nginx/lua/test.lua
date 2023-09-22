-- Load the cjson module (JSON library for Lua)
local cjson = require "cjson"

-- Function to modify the JSON response
local function modify_json_response(response_body)
    -- Parse the JSON response
    local data = cjson.decode(response_body)

    -- Modify the JSON data
    data["message"] = "Modified JSON Response"

    -- Serialize the modified data back to JSON
    local modified_response = cjson.encode(data)

    return modified_response
end

-- Modify the response body
ngx.arg[1] = modify_json_response(ngx.arg[1])
