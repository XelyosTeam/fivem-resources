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

-- Récupérer un domaine
function MailRP:findSubdomain(callBack, name)
    if name == nil then
        self:__sendGetRequest('subdomains', callBack)
    else
        if type(name) ~= 'string' then
            error('name attribut must be a string')
        end

        if callBack and type(callBack) ~= 'table' then
            error('The callBack must be a function and not ' .. type(callBack))
        end

        self:__sendGetRequest('subdomains/' .. name, callBack)
    end
end

-- Récupérer la liste des domaines
function MailRP:findSubdomains(callBack)
    self:findSubdomain(callBack)
end

-- Ajouter un domaine
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
function MailRP:sendEmail(callBack, from, to, subject, content, confirmOpened, attachments)
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

    if attachments and type(attachments) ~= 'table' then
        error('attachments must be a string or an array (table) and not ' .. type(attachments))
    elseif attachments and #attachments > 0 then
        local tempAttachments = {}
        for k in pairs(attachments) do
            if type(attachments[k]) ~= 'string' and type(attachments[k]) ~= 'table' then
                error('value in attachments must be a string or an array (table) and not ' .. type(attachments[k]))
            else
                table.insert(tempAttachments, attachments[k])
            end
        end

        if #tempAttachments > 0 then
            data.attachments = tempAttachments
        end
    end

    if callBack and type(callBack) ~= 'table' then
        error('The callBack must be a function and not ' .. type(callBack))
    end

    self:__sendPostRequest('mail/send', data, callBack)
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

    self:__sendPostRequest('address/create', data, callBack)
end

function MailRP:findAddress(callBack, email)
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

RegisterNetEvent("xelyos:MailRP") -- For using the class from another resource.
AddEventHandler("xelyos:MailRP", function(cb)
    cb(MailRP:new())
end)