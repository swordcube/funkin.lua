-- Backwards compatibility
table.pack = table.pack or function(...) return { n = select("#", ...), ... } end
table.unpack = table.unpack or unpack

---
--- Returns whether or not a table contains any
--- specified element.
---
--- @param table   table  The table to check.
--- @param element any    The element to check.
---
--- @return boolean
---
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

---
--- Returns the index of an element in a table.
--- Returns `-1` if the element couldn't be found in the table.
---
--- @param table   table  The table to check.
--- @param element any    The element to check.
---
--- @return integer
---
function table.indexOf(table, element)
    for index, elem in ipairs(table) do
        if elem == element then
            return index
        end
    end
    return -1
end

---
--- Makes a copy of a table.
---
--- @param t     table    The table to make a copy of.
--- @param deep? boolean  Whether or not all nested subtables should be deeply copied. If not, a shallow copy is performed, where only the top-level elements are copied.
--- @param seen? table    A tracking table to avoid infinite loops when dealing with circular references or shared references in nested tables. This parameter is primarily used internally and can be omitted when calling the function.
---
--- @return table|nil
---
function table.copy(t, deep, seen)
    seen = seen or {}
    if t == nil then return nil end
    if seen[t] then return seen[t] end

    local nt = {}
    for k, v in pairs(t) do
        if deep and type(v) == 'table' then
            nt[k] = table.copy(v, deep, seen)
        else
            nt[k] = v
        end
    end
    setmetatable(nt, table.copy(getmetatable(t), deep, seen))
    seen[t] = nt
    return nt
end

---
--- Creates a new table by filtering the elements of `t`
--- based on the result of the filtering function `func()`.
---
--- It includes only those elements for which func returns a truthy value.
---
--- @param t    table     The table to filter.
--- @param func function  The function to filter the table with.
---
--- @return table
---
function table.filter(t, func)
    local filtered = {}
    for _, value in ipairs(t) do
        if func(value) then
            table.insert(filtered, value)
        end
    end
    return filtered
end

---
--- Creates a new string based on the elements of the table `t`,
--- separated by the string `sep`.
---
--- @param t    table   The table you want to make a string representation of.
--- @param sep? string  The separator between each item of the table in the final string.
---
--- @return string
---
function table.join(t, sep)
    if sep == nil then
        sep = ""
    end

    local tl = #t
    local result = ""

    for i, value in ipairs(t) do
        result = result .. tostring(value)
        if i < tl then
            result = result .. sep
        end
    end

    return result
end

---
--- Removes a specific item from a table.
---
--- @param t     table  The table to remove the item from.
--- @param item  any    The item to remove from the table.
---
function table.removeItem(t, item)
	table.remove(t, table.indexOf(t, item))
end

return {}