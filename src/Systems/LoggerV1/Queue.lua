local processorFn = nil

local Queue = {}
Queue.QueueTable = {}
Queue.Processing = false

function Queue.Add(moduleName: string, severity: number, log: string)
	table.insert(Queue.QueueTable, { moduleName, severity, log })

	Queue.Process()
end

function Queue.Get()
	local theChosenOne = Queue.QueueTable[1]
	table.remove(Queue.QueueTable, 1)

	return table.unpack(theChosenOne)
end

function Queue.AttachProcessor(fn: (any) -> nil)
	processorFn = fn
end

function Queue.DeAttachProcessor()
	processorFn = nil
end

function Queue.Process()
	if Queue.Processing then
		return
	end

	Queue.Processing = true

	while #Queue.QueueTable ~= 0 or not Queue.Processing do
		processorFn(Queue.Get())
		--task.wait()
	end

	Queue.Processing = false
end

function Queue.Clear()
	Queue.Processing = false
	Queue.QueueTable = {}
end

return Queue
