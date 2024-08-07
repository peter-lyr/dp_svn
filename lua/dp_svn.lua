local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

M.source = B.getsource(debug.getinfo(1)['source'])
M.lua = B.getlua(M.source)

if B.check_plugins {
      'folke/which-key.nvim',
      'git@github.com:peter-lyr/dp_git',
    } then
  return
end

M.has_tortoise_svn = 1

local result = vim.fn.systemlist { 'which', 'tortoiseproc.exe', }
if B.is_in_str('no tortoiseproc.exe in', table.concat(result, '\n')) then
  M.has_tortoise_svn = nil
end

-- 帮助
-- {https://blog.csdn.net/kenkao/article/details/103384392}

function M.tortoisesvn_do(cmd, path, revision)
  if B.is_in_str('-cmdline', cmd) then
    if B.is_in_str('update', cmd) then
      B.system_run('start', {
        B.system_cd(path),
        'echo ' .. path,
        'svn cleanup',
        'svn revert -R .',
        'svn update --set-depth infinity --accept mine-full ' .. revision,
        'timeout /t 30',
      })
    end
  else
    cmd = string.format('silent !%s && start tortoiseproc.exe /command:%s /path:\"%s\"', B.system_cd(path), cmd, path)
    print(cmd)
    vim.fn.execute(cmd)
    vim.cmd 'silent !winwaitactive.exe tortoiseproc.exe'
  end
end

function M.tortoisesvn_do_one_by_one(cmd, path, revision)
  if B.is_in_str('-cmdline', cmd) then
    if B.is_in_str('update', cmd) then
      vim.cmd('!' .. vim.fn.join({
        B.system_cd(path),
        'echo ' .. path,
        'svn cleanup',
        'svn revert -R .',
        'svn update --set-depth infinity --accept mine-full ' .. revision,
      }, ' && '))
    end
  else
    cmd = string.format('silent !%s && start tortoiseproc.exe /command:%s /path:\"%s\"', B.system_cd(path), cmd, path)
    print(cmd)
    vim.fn.execute(cmd)
    vim.cmd 'silent !winwaitactive.exe tortoiseproc.exe'
  end
end

function M.get_revision(cmd, revision)
  if not revision then
    revision = vim.fn.input(string.format('%s revision: ', cmd), '1000000')
    if not B.is(revision) then
      return nil
    end
    revision = tonumber(revision)
    if not revision then
      revision = 1000000
    end
    if revision >= 1000000 then
      revision = ''
    else
      revision = string.format('-r %d', revision)
    end
  end
  return revision
end

function M.tortoisesvn(cmd, cwd, revision)
  if not M.has_tortoise_svn then
    return
  end
  if not cmd then
    return
  end
  if B.is_in_str('-cmdline', cmd) then
    revision = M.get_revision(cmd, revision)
    if revision == nil then
      return
    end
  end
  local path = B.get_proj_root()
  if cwd == 'cur' then
    path = B.buf_get_name()
  elseif cwd == 'git' then
    local paths = B.get_dirs_named_with_till_git '.svn'
    if B.is_in_str('-cmdline', cmd) then
      M.tortoisesvn_do_one_by_one(cmd, paths[1], revision)
      table.remove(paths, 1)
      for _, _path in ipairs(paths) do
        M.tortoisesvn_do(cmd, _path, revision)
      end
    else
      for _, _path in ipairs(paths) do
        M.tortoisesvn_do(cmd, _path, revision)
      end
    end
    require 'dp_git.push'.git_keep()
    return
  end
  M.tortoisesvn_do(cmd, path, revision)
  require 'dp_git.push'.git_keep()
end

vim.api.nvim_create_user_command('TortoiseSvn', function(params)
  M.tortoisesvn(unpack(params['fargs']))
end, { nargs = '*', })

require 'which-key'.register {
  ['<leader>v'] = { name = 'dp_svn', },
  ['<leader>vo'] = { function() M.tortoisesvn 'settings' end, 'svn: settings', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vd'] = { function() M.tortoisesvn('diff', 'cur') end, 'svn: diff cur', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vf'] = { function() M.tortoisesvn('diff', 'proj') end, 'svn: diff proj', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vg'] = { function() M.tortoisesvn('diff', 'git') end, 'svn: diff git', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vl'] = { function() M.tortoisesvn('log', 'cur') end, 'svn: log cur', mode = { 'n', 'v', }, silent = true, },
  ['<leader>v;'] = { function() M.tortoisesvn('log', 'proj') end, 'svn: log proj', mode = { 'n', 'v', }, silent = true, },
  ["<leader>v'"] = { function() M.tortoisesvn('log', 'git') end, 'svn: log git', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vu'] = { function() M.tortoisesvn 'update /rev' end, 'svn: update /rev', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vi'] = { function() M.tortoisesvn('update-cmdline', 'git') end, 'svn: update-cmdline', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>vw'] = { function() M.tortoisesvn('repobrowser', 'cur') end, 'svn: repobrowser cur', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ve'] = { function() M.tortoisesvn 'repobrowser' end, 'svn: repobrowser', mode = { 'n', 'v', }, silent = true, },
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
  ['<leader>vc'] = { function() M.tortoisesvn('commit', 'proj') end, 'svn: commit proj', mode = { 'n', 'v', }, silent = true, },
  ['<leader>vt'] = { function() M.tortoisesvn('commit', 'git') end, 'svn: commit git', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>v<leader>'] = { function() vim.cmd [[call feedkeys(":\<c-u>TortoiseSvn ")]] end, 'svn: more', mode = { 'n', 'v', }, },
}
