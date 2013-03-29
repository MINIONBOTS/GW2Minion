
wt_task = inheritsFrom( nil )

wt_task.UID = 0

wt_task.name = "task"

wt_task.timestamp = 0

wt_task.lifetime = 0

wt_task.priority = 500

function wt_task:execute()

end

function wt_task:expired()
	if (wt_task.lifetime ~= 0) then
		return (wt_global_information.Now - wt_task.timestamp > wt_task.lifetime )
	else
		return false
	end
end

function wt_task:isFinished()
	return true
end
