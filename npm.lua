-- preamble: common routines

function dir_match_generator_impl(text)
    -- Strip off any path components that may be on text.
    local prefix = ""
    local i = text:find("[\\/:][^\\/:]*$")
    if i then
        prefix = text:sub(1, i)
    end

    local matches = {}
    local mask = text.."*"

    -- Find matches.
    for _, dir in ipairs(clink.find_dirs(mask, true)) do
        local file = prefix..dir
        if clink.is_match(text, file) then
            table.insert(matches, prefix..dir)
        end
    end

    return matches
end

local function dir_match_generator(word)
    local matches = dir_match_generator_impl(word)

    -- If there was no matches but text is a dir then use it as the single match.
    -- Otherwise tell readline that matches are files and it will do magic.
    if #matches == 0 then
        if clink.is_dir(rl_state.text) then
            table.insert(matches, rl_state.text)
        end
    else
        clink.matches_are_files()
    end

    return matches
end

function file_match_generator_impl(text)
    -- Strip off any path components that may be on text.
    local prefix = ""
    local i = text:find("[\\/:][^\\/:]*$")
    if i then
        prefix = text:sub(1, i)
    end

    local matches = {}
    local mask = text.."*"

    -- Find matches.
    for _, dir in ipairs(clink.find_files(mask, true)) do
        local file = prefix..dir
        if clink.is_match(text, file) then
            table.insert(matches, prefix..dir)
        end
    end

    return matches
end

local function file_match_generator(word)
    local matches = file_match_generator_impl(word)

    -- If there was no matches but text is a dir then use it as the single match.
    -- Otherwise tell readline that matches are files and it will do magic.
    if #matches == 0 then
        if clink.is_dir(rl_state.text) then
            -- table.insert(matches, rl_state.text)
        end
    else
        clink.matches_are_files()
    end

    return matches
end

local function modules(token)
    local res = {}
    local modules = clink.find_dirs('node_modules/*')
    for _,module in ipairs(modules) do
        if string.match(module, token) then
            table.insert(res, module)
        end
    end
    return res
end

local parser = clink.arg.new_parser

-- end preamble

-- TODO: add support for multiple modules
install_parser = parser({dir_match_generator},
        "--force",
        "-g", "--global",
        "--link",
        "--no-bin-links",
        "--no-optional",
        "--no-shrinkwrap",
        "--nodedir=/",
        "--production",
        "--save", "--save-dev", "--save-optional",
        "--tag"
        )

search_parser = parser("--long")

npm_parser = parser({
    "add-user",
    "adduser",
    "apihelp",
    "author",
    "bin",
    "bugs",
    "c",
    "cache",
    "completion",
    "config",
    "ddp",
    "dedupe",
    "deprecate",
    "docs",
    "edit",
    "explore",
    "faq",
    "find" .. search_parser,
    "find-dupes",
    "get",
    "help",
    "help-search",
    "home",
    "info",
    "init",
    "install" .. install_parser,
    "issues",
    "la",
    "link",
    "list",
    "ll",
    "ln",
    "login",
    "ls",
    "outdated",
    "owner",
    "pack",
    "prefix",
    "prune",
    "publish",
    "r",
    "rb",
    "rebuild",
    "remove",
    "repo",
    "restart",
    "rm" .. parser({modules}), -- TODO: add support for multiple modules and -g key
    "root",
    "run-script",
    "search" .. search_parser,
    "set",
    "show",
    "shrinkwrap",
    "star",
    "stars",
    "start",
    "stop",
    "submodule",
    "tag",
    "test" .. parser({modules}),
    "un",
    "uninstall" .. parser({modules}), -- TODO: add support for multiple modules and -g key
    "unlink",
    "unpublish",
    "unstar",
    "up",
    "update",
    "v",
    "version",
    "view",
    "whoami"
    },
    "-h"
)

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