local M = {}

function M.get_action()
    local key = io.read()

    return ({
        w = "up",
        s = "down",
        a = "left",
        d = "right"
    })[key]
end

return M
