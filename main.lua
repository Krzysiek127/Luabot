local spawn = require('coro-spawn')
local parse = require('url').parse
local discordia = require('discordia')

local client = discordia.Client()

discordia.extensions()

local function getStream(url)
    local child = spawn('youtube-dl', {
        args = {'-g', url},
        stdio = { nil, true, 2 }
    })

    local stream
    for chunk in child.stdout.read do
        local urls = chunk:split('\n')

        for _, yturl in pairs(urls) do
            local mime = parse(yturl, true).query.mime

            if mime and mime:find('audio') == 1 then
                stream = yturl
            end
        end
    end

    return stream
end

local connections = { }

client:on('messageCreate', function(message)
    if message.author == client.user then return end
    if message.author.bot then return end
    if not message.guild then return end

    print(os.date('!%Y-%m-%d %H:%M:%S', message.createdAt).. ' <'.. message.author.name.. '> '.. message.content)

    local args = message.content:split('%s+')
    local cmd = table.remove(args, 1)

    local connection = connections[message.guild.id]

    if cmd == 'audio.join' then
        local member = message.guild:getMember(message.author)
        local channel = member.voiceChannel

        if channel then
            if connection and connection.channel ~= channel or not connection then
                print('joining')
                connection = channel:join()
                connections[message.guild.id] = connection
            end
        end
    elseif cmd == 'audio.leave' then
        if connection then
            print('leaving')
            connection:close()
        end
    elseif cmd == 'audio.play' then
        if connection then
            local requested = args[1]
            local url = getStream(requested)

            print('fetching', requested)
            if url then
                print('playing', url)
                connection:playFFmpeg(url)
            else
                message:reply('could not fetch the audio for that video.')
            end
        end
    elseif cmd == 'audio.pause' then
        print('pausing')
        connection:pauseStream()
    elseif cmd == 'audio.resume' then
        print('resuming')
        connection:resumeStream()
    elseif cmd == 'audio.skip' then
        print('stopping')
        connection:stopStream()
    elseif cmd == 'audio.leave' then
        print('leaving')
        connection:close()
    end
end)

local open = io.open

local function read_file(path)
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

client:run("Bot " .. read_file("token.txt"))