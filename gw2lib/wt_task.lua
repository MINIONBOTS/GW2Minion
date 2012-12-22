
wt_task = inheritsFrom( nil )

wt_task.name = "task"

wt_task.priorities = {
	normal = 50,
	high = 75,
}

wt_task.priority = wt_task.priorities.normal
wt_task.execution_count = 0
wt_task.max_execution_count = 0
wt_task.duration = 0

function wt_task:canRun()
	
	return true
end

function wt_task:execute()

end

function wt_task:isFinished()
	return true
end