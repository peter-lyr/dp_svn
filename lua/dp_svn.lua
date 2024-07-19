local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
    } then
  return
end

-- 帮助
-- {https://blog.csdn.net/kenkao/article/details/103384392}

function M.tortoisesvn(cmd, cur, prompt)
  if not cmd then
    return
  end
  local path = B.get_proj_root()
  if cur == 'cur' then
    path = B.buf_get_name()
  end
  if not prompt or B.is_sure('Sure to %s in %s', cmd, path) then
    vim.fn.execute(string.format('silent !%s && start tortoiseproc.exe /command:%s /path:\"%s\"', B.system_cd(path), cmd, path))
  end
end

vim.api.nvim_create_user_command('TortoiseSvn', function(params)
  M.tortoisesvn(params['fargs'])
end, { nargs = '*', })

require 'which-key'.register {
  ['<leader>v'] = { name = 'dp_svn', },
  ['<leader>vo'] = { function() M.tortoisesvn('settings', 'cur') end, 'svn: settings cur', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vf'] = { function() M.tortoisesvn 'diff' end, 'svn: diff', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vd'] = { function() M.tortoisesvn('diff', 'cur') end, 'svn: diff cur', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>v;'] = { function() M.tortoisesvn 'log' end, 'svn: log', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vl'] = { function() M.tortoisesvn('log', 'cur') end, 'svn: log cur', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vw'] = { function() M.tortoisesvn('repobrowser', 'cur') end, 'svn: repobrowser cur', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ve'] = { function() M.tortoisesvn 'repobrowser' end, 'svn: repobrowser', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vu'] = { function() M.tortoisesvn 'update /rev' end, 'svn: update /rev', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vb'] = { function() M.tortoisesvn('blame', 'cur') end, 'svn: blame cur', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vv'] = { function() M.tortoisesvn 'revert' end, 'svn: revert', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vk'] = { function() M.tortoisesvn 'checkout' end, 'svn: checkout', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vn'] = { function() M.tortoisesvn 'cleanup' end, 'svn: cleanup', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>va'] = { function() M.tortoisesvn 'add' end, 'svn: add', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vc'] = { function() M.tortoisesvn 'commit' end, 'svn: commit', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>v<leader>'] = { function() vim.cmd [[call feedkeys(":\<c-u>TortoiseSvn ")]] end, 'svn: more', mode = { 'n', 'v', }, },
}
