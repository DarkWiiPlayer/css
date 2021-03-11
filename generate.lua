local fun = require 'fun'
local lfs = require 'lfs'
local skooma = require 'skooma'
local warn = require 'warn.compatible'
local yaml = require 'lyaml'

local env = setmetatable({}, {__index=function(self, key)
	return _G[key] or skooma.env[key]
end})

local function foreachfile(fn, pattern, dir)
	for name in lfs.dir(dir) do
		if not name:find("^%.") then
			local file = dir .. '/' .. name
			local attr = lfs.attributes(name)
			if attr.mode == "directory" then
				foreachfile(fn, pattern, file)
			elseif file:find(pattern) then
				fn(name, file)
			end
		end
	end
end

local function files(dir, pattern)
	local pattern = pattern or ".*"
	return coroutine.wrap(function()
		foreachfile(coroutine.yield, pattern, dir)
	end), true, true
end

local function read_header(path)
	local file = io.open(path)
	if file:read()=="/*" then
		local buffer = {}
		for line in file:lines() do
			if line ~= "*/" then
				table.insert(buffer, line)
			else
				local text = table.concat(buffer, '\n'):gsub("\t", "  ")
				local ok, data = pcall(yaml.load, text)
				if ok then
					return data
				else
					warn(data)
				end
			end
		end
	end
end

local css = [[
	@import url('core.css');
	@import url('box.css');
	:root {
		--box-stripe-color: salmon;
		background-color: #f4f4f4;
		padding: 1em 2em;
	}
	body :not(:first-child) {
		margin-top: .4em;
	}
	ul.nested {
		list-style: none;
	}
	ul.nested ul.nested {
		padding: .2em .7em;
		margin-left: .1em;
		border-left: .2em solid var(--color);
	}

	.nested code { color: var(--color) }

	.property { --color: #006 }
	code.property::before { content: '--' }

	.class { --color: #060 }
	code.class::before { content: '.' }

	.element { --color: #600 }
	code.element::before { content: '' }

	.attribute { --color: #440 }
	code.attribute::before { content: '[' }
	code.attribute::after  { content: ']' }
]]

local page do
	local _ENV=env

	local function stylesheets()
		return fun.iter(files(".", "%.css$"))
	end

	local singular = {
		attributes = "attribute";
		elements="element";
		classes="class";
		properties = "property";
	}

	local types = {"attributes", "elements", "classes", "properties"}
	local function definitions(info)
		return ul(fun.iter(types):map(function(category)
			local info = info[category]
			if info then
				return {
					class = "nested",
					fun.iter(info):map(function(item)
						return {
							class = singular[category];
							p(code{item.name, class=singular[category]}, ' ', item.description);
							definitions(item);
						}
					end)
					:map(li)
					:totable()
				}
			end
		end):totable())
	end

	local function stylesheed(path)
		local data = read_header(path)
		local name = path:gsub(".-([^/]+)%.css$", "%1")
		return div(
			div({class="box"},
				h2(name),
				data.description and h3(data.description),
				definitions(data)
			)
		)
	end

	local project_title = "DarkWiiPlayer/CSS"

	page = html(head(
		style(css),
		title(project_title)
	), body(
		h1(project_title),
		stylesheets()
		:map(stylesheed)
		:totable()
	))
end

local outfile <close> = io.open("doc.html", "w")

for i, line in ipairs(skooma.serialize.html(page)) do
	outfile:write(line)
end
