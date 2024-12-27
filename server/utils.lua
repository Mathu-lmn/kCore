function Core.Functions.GenerateUID()
    local template = "KC%d%d%d%d%d%d"
    local nums = ""
    for i = 1, 6 do
        nums = nums .. tostring(math.random(0, 9))
    end
    return string.format(template, nums:match("(%d)(%d)(%d)(%d)(%d)(%d)"))
end
