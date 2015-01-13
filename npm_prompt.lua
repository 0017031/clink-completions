clink.arg.register_parser("npm", npm_parser)
function npm_prompt_filter()
    local package = io.open('package.json')
    if package ~= nil then
        local package_info = package:read('*a')
        local package_name = string.match(package_info, '"name"%s*:%s*"(%g-)"')
        local package_version = string.match(package_info, '"version"%s*:%s*"(.-)"')
        clink.prompt.value = color_text("["..package_name.."@"..package_version.."]", "black", "green").." "..clink.prompt.value
        package:close()
    end
    return false
end

clink.prompt.register_filter(npm_prompt_filter, 40)
