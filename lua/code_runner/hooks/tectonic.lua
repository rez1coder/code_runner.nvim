local notify = require("code_runner.hooks.notify")

local M = {}

local state = {
  job_id = nil,
}

function M.stop()
  if state.job_id then
    vim.fn.jobstop(state.job_id)
    state.job_id = nil
  end
end

local function start_job(cmd)
  M.stop()
  notify.info("Start HotReload", "Tectonic")

  state.job_id = vim.fn.jobstart(cmd, {
    on_exit = function()
      notify.info("Compile finished", "Tectonic")
      state.job_id = nil
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = 0,
    once = true,
    callback = M.stop,
  })
end

--- @param flags? string
function M.build(flags)
  start_job(("tectonic -X watch -x 'build %s'"):format(flags or ""))
end

--- @param flags? string
function M.single(flags)
  local root = vim.fn.expand("%:p")
  start_job(("tectonic -X watch -x 'compile %s %s'"):format(root, flags or ""))
end

vim.api.nvim_create_user_command("TectonicStop", M.stop, {
  desc = "Stop Tectonic hot reload",
  nargs = 0,
})

return M
