function Linemode:mtime_ls()
	local mtime = self._file.cha.mtime
	local date = ""
	if mtime then
		local t = math.floor(mtime)
		if os.date("%Y", t) == os.date("%Y") then
			date = os.date("%b %e %H:%M", t)
		else
			date = os.date("%b %e  %Y", t)
		end
	end

	local size = self._file:size()
	local size_str = size and ya.readable_size(size) or "-"

	return string.format("%6s  %s", size_str, date)
end
