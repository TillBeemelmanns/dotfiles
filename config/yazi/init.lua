function Linemode:mtime_ls()
	local mtime = self._file.cha.mtime
	if not mtime then
		return ""
	end
	local t = math.floor(mtime)
	if os.date("%Y", t) == os.date("%Y") then
		return os.date("%b %e %H:%M", t)
	else
		return os.date("%b %e  %Y", t)
	end
end
