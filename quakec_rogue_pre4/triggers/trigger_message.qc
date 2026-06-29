void() trigger_message_use =
{
	local entity e;
	for(e = world; (e = find(e, classname, "player"));){
		centerprint(e, self.message);
	}
};

void() trigger_message = {
	self.use = trigger_message_use;
};