.string command;

void() trigger_localcmd_use = {
	localcmd(self.command);
	localcmd("\n");
};

void() trigger_localcmd = {
	self.use = trigger_localcmd_use;
};