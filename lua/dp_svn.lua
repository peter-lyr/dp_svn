local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
      'git@github.com:peter-lyr/dp_git',
    } then
  return
end

-- 帮助
-- {https://blog.csdn.net/kenkao/article/details/103384392}

M.commands = {
  -- "clean",
  "update",
  -- "clean_update",
  "show",
  "show-gui",
  "kill-TortoiseProc.exe",
}

function M.svn_multi_root(cwd)
  B.ui_sel(M.commands, 'svn do what', function(cmd)
    if cmd then
      if B.is_in_tbl(cmd, {'update', 'clean_update'}) then
        local revision = vim.fn.input(string.format('%s to which revision?: ', cmd))
        if B.is(revision) then
          require 'dp_git.push'.svn_multi_root(cwd, cmd, revision)
        end
      else
        require 'dp_git.push'.svn_multi_root(cwd, cmd)
      end
    end
  end)
end

function M.tortoisesvn(cmd, cur, prompt)
  if not cmd then
    return
  end
  local path = B.get_proj_root()
  if cur == 'cur' then
    path = B.buf_get_name()
  end
  if not prompt or B.is_sure('Sure to %s in %s', cmd, path) then
    cmd = string.format('silent !%s && start tortoiseproc.exe /command:%s /path:\"%s\"', B.system_cd(path), cmd, path)
    B.echo(cmd)
    vim.fn.execute(cmd)
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
  ['<leader>vg'] = { function() M.svn_multi_root 'git' end, 'svn: svn_multi_root git', mode = { 'n', 'v', }, },
  ['<leader>vh'] = { function() M.svn_multi_root 'proj' end, 'svn: svn_multi_root proj', mode = { 'n', 'v', }, },
}

require 'which-key'.register {
  ['<leader>v<leader>'] = { function() vim.cmd [[call feedkeys(":\<c-u>TortoiseSvn ")]] end, 'svn: more', mode = { 'n', 'v', }, },
}
