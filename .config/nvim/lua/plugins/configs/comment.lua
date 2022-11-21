local ok, comment = pcall(require, "Comment")

if not ok then
    return
end

comment.setup {
    padding = true,
    sticky = true,
    ignore = nil,
    toggler = {
        line = "<c-/>",
        block = "<c-]>",
    },
    opleader = {
        line = "<c-A-/>",
        block = "<c-A-]>",
    },
    mappings = {
        basic = true,
        extra = true,
        extended = false,
    },
    pre_hook = nil,
    post_hook = nil,
}
