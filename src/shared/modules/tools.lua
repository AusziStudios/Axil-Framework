local tools = {}

function tools.deepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[tools.deepCopy(orig_key, copies)] = tools.deepCopy(orig_value, copies)
            end
            setmetatable(copy, tools.deepCopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

function tools.expandTable(object, allTables) --Turns a table into a list of all the sub tables
    allTables = allTables or {}

    if type(object) ~= "table" then
        return
    end
    if table.find(allTables, object) then
        return
    end

    table.insert(allTables, object)

    for key, value in pairs(object) do
        tools.expandTable(key, allTables)
        tools.expandTable(value, allTables)
    end

    return allTables
end

function tools.respectClone(object, allObjects)
    if type(object) ~= "table" then
        return object
    end

    allObjects = allObjects or {}
    if allObjects[object] then
        return allObjects[object]
    else
        allObjects[object] = table.clone(object)
        object = allObjects[object]
    end

    for key, value in pairs(object) do
        object[tools.respectClone(key, allObjects)] = tools.respectClone(value, allObjects)
    end

    return object
end

return tools