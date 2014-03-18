-- preamble: common routines

local function flags(...)
    local p = clink.arg.new_parser()
    p:disable_file_matching()
    p:set_flags(...)
    return p
end

local function arguments(...)
    local p = clink.arg.new_parser()
    p:disable_file_matching()
    p:set_arguments(...)
    return p
end

local function parser( ... )
    
    local arguments = {}
    local flags = {}
    
    for _, word in ipairs({...}) do
        if type(word) == "string" then
            table.insert(flags, word)
        elseif type(word) == "table" then
            table.insert(arguments, word)
        end
    end
    
    local p = clink.arg.new_parser()
    p:disable_file_matching()
    
    -- p:set_arguments(arguments)

    p:set_flags(flags)
    for _, a in ipairs(arguments) do
        p:add_arguments(a)
    end
    
    p:set_flags(flags)

    return p
end

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

local function find_npm_modules(root_dir, recurse)
    if not root_dir then
        return clink.find_dirs('node_modules/*')
    else
        if not recurse then
            return clink.find_dirs(root_dir ..'/node_modules/*')
        else
            return
        end
    end
end


-- end preamble

-- TODO: add support for multiple modules
install_parser = parser(
        {dir_match_generator},
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
    "i" .. install_parser,
    "info",
    "init",
    "install" .. install_parser,
    "isntall",
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
    "rm" .. parser({find_npm_modules()}), -- TODO: add support for multiple modules and -g key
    "root",
    "run-script",
    "s" .. search_parser,
    "se" .. search_parser,
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
    "test" .. parser({find_npm_modules()}),
    "tst" .. parser({find_npm_modules()}),
    "un",
    "uninstall" .. parser({find_npm_modules()}), -- TODO: add support for multiple modules and -g key
    "unlink",
    "unpublish",
    "unstar",
    "up",
    "update",
    "v",
    "version",
    "view",
    "whoami"
    }, "-h"
)

clink.arg.register_parser("npm", npm_parser)