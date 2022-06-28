-- Meta class
MailRP = {}

-- Initialisation de la classe Mail RP
function MailRP:new ()
    local token = 'apiToken'
    self.__index = self
    self._api = "https://mail-rp.com/api/v1/" .. token .. '/'
    return self
end

-- Envoyer une requête GET
function MailRP:__sendGetRequest(url, callBack)
    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    PerformHttpRequest(self._api .. url, function(statusCode, resultData)
        if callBack then
            callBack(statusCode, json.decode(resultData))
        end
    end, 'GET')
end

-- Envoyer une requête POST
function MailRP:__sendPostRequest(url, data, callBack)
    if type(data) ~= 'table' then
        error('post data must be a table')
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    PerformHttpRequest(self._api .. url, function(statusCode, resultData)
        if callBack then
            callBack(statusCode, json.decode(resultData))
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

-- Récupérer les informations générales du serveur
function MailRP:getServer(callBack)
    self:__sendGetRequest('server', callBack)
end

-- Récupérer un sous domaine
function MailRP:getSubdomain(callBack, name)
    if name == nil then
        self:__sendGetRequest('subdomains', callBack)
    else
        if type(name) ~= string then
            error('name attribut must be a string')
        end

        if callBack and type(callBack) ~= 'table' then
            error('The callBack must be a function and not ' .. type(callBack))
        end

        self:__sendGetRequest('server/' .. name, callBack)
    end
end

-- Récupérer la liste des sous domaines
function MailRP:getSubdomains(callBack)
    self:getSubdomain(callBack)
end

-- Ajouter un sous domaine
function MailRP:addSubdomain(callBack, name, public, manager, carnet)
    if name == nil then
        error('name is required !')
    end

    if public == nil then
        error('public is required !')
    end

    if type(name) ~= 'string' then
        error('name must be a string ' .. type(name))
    end

    if type(public) ~= 'boolean' then
        error('public must be a boolean ' .. type(public))
    end

    local data = {
        name = name,
        public = public,
    }

    if manager and type(manager) ~= 'string' then
        error('manager must be a string ' .. type(manager))
    else
        data.manager = manager
    end

    if carnet and type(carnet) ~= 'boolean' then
        error('carnet must be a boolean ' .. type(carnet))
    else
        data.carnet = carnet
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    self:__sendPostRequest('subdomains/add', data, callBack)
end

-- Envoyer un mail
function MailRP:send(callBack, from, to, subject, content, confirmOpened, attachements)
    if from == nil then
        error('Sender email is required !')
    end

    if to == nil then
        error('Recipient\'s email is required')
    end

    if subject == nil then
        error('Subject email is required')
    end

    if type(from) ~= 'string' then
        error('from must be a string and not ' .. type(from))
    end

    if type(to) ~= 'string' and type(to) ~= 'table' then
        error('to must be a string or an array (table) and not ' .. type(to))
    end

    if type(subject) ~= 'string' then
        error('subject must be a string and not ' .. type(subject))
    end

    local data = {
        from = from,
        to = to,
        subject = subject
    }

    if content and type(content) ~= 'string' then
        error('content must be a string and not ' .. type(content))
    else
        data.content = content
    end

    if confirmOpened and type(confirmOpened) ~= 'boolean' then
        error('confirmOpened must be a boolean and not ' .. type(confirmOpened))
    else
        data.confirmOpened = confirmOpened
    end

    if attachements and type(attachements) ~= 'table' then
        error('attachements must be a string or an array (table) and not ' .. type(attachements))
    elseif attachements and #attachements > 0 then
        local tempAttachements = {}
        for k in pairs(attachements) do
            if type(attachements[k]) ~= 'string' and type(attachements[k]) ~= 'table' then
                error('value in attachements must be a string or an array (table) and not ' .. type(attachements[k]))
            else
                table.insert(tempAttachements, attachements[k])
            end
        end

        if #tempAttachements > 0 then
            data.attachements = tempAttachements
        end
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    self:__sendPostRequest(self, 'mail/send', data, callBack)
end

function MailRP:addAddress(callBack, name, firstname, email, password)
    local params = {
        { var = name, name = 'name' },
        { var = firstname, name = 'firstname' },
        { var = email, name = 'email' },
        { var = password, name = 'password' }
    }
    for p in pairs(params) do
        if params[p].var == nil then
            error(params[p].name .. ' param is required !')
        end

        if type(params[p].var) ~= 'string' then
            error(params[p].name .. ' must be a string and not ' .. type(params[p].var))
        end
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    local data = {
        name = name,
        firstname = firstname,
        email = email,
        password = password,
    }

    self:__sendPostRequest(self, 'address/create', data, callBack)
end

function MailRP:getAddress(callBack, email)
    if email == nil then
        error('email param is required !')
    end

    if type(email) ~= 'string' then
        error('email must be a string and not ' .. type(email))
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    self:__sendGetRequest('address/get/' .. email, callBack)
end

RegisterNetEvent("xelyos:MailRP") -- For opening the emote menu from another resource.
AddEventHandler("xelyos:MailRP", function(cb)
    cb(MailRP:new())
end)