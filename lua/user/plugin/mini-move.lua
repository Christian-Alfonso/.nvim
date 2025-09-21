local minimove = require('mini.move')

minimove.setup(
-- No need to copy this inside `setup()`. Will be used automatically.
    {
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
            -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
            left = 'H',
            right = 'L',
            down = 'J',
            up = 'K',

            -- Move current line in Normal mode
            line_left = 'H',
            line_right = 'L',
            line_down = 'J',
            line_up = 'K',
        },
    }
)
