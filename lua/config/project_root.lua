local M = {}

local uv = vim.uv or vim.loop

local function normalize(path)
  return path and vim.fs.normalize(path) or path
end

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function has_git_dir(path)
  return path and uv.fs_stat(path .. "/.git") ~= nil
end

local function is_ancestor(parent, child)
  parent = normalize(parent)
  child = normalize(child)
  return parent and child and (child == parent or child:sub(1, #parent + 1) == parent .. "/")
end

local function git_superproject(path)
  if not path or vim.fn.executable("git") ~= 1 then
    return nil
  end

  local result = vim
    .system({ "git", "-C", path, "rev-parse", "--show-superproject-working-tree" }, { text = true })
    :wait()
  if result.code ~= 0 then
    return nil
  end

  local superproject = trim(result.stdout)
  return superproject ~= "" and normalize(superproject) or nil
end

local function parent_git_root(path)
  local dir = normalize(path and vim.fs.dirname(path) or nil)
  while dir and dir ~= "/" do
    if has_git_dir(dir) then
      return dir
    end
    dir = vim.fs.dirname(dir)
  end
end

function M.root()
  local root = normalize(LazyVim.root())
  local cwd = normalize(uv.cwd())

  if root and cwd and root ~= cwd and is_ancestor(cwd, root) and has_git_dir(cwd) then
    return cwd
  end

  return git_superproject(root) or (has_git_dir(root) and root) or parent_git_root(root) or root or cwd
end

return M
