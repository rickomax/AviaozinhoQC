.string path_corner_trigger;
.string trigger_target;

void() modeltrain_next;
void() func_modeltrain_find;

void() modeltrain_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

void() modeltrain_use =
{
	if (self.think != func_modeltrain_find)
		return;		// already activated
	modeltrain_next();
};

void() modeltrain_wait =
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
		self.nextthink = self.ltime + 0.1;
	
	if(self.target == self.path_corner_trigger){
		local string otarget = self.target;
		self.target = self.trigger_target;
		SUB_UseTargets();
		self.target = otarget;
	}
	
	self.think = modeltrain_next;
};

void() modeltrain_next =
{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror ("train_next: no next target");
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	SUB_CalcMove (targ.origin, self.speed, modeltrain_wait);
	
	self.angles = vectoangles(targ.origin - self.origin);
};

void() func_modeltrain_find =

{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = modeltrain_next;
	}
};

void() func_modeltrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = modeltrain_blocked;
	self.use = modeltrain_use;
	self.classname = "modeltrain";
	
	precache_model(self.model);
	setmodel (self, self.model);
	setsize (self, '-16 -16 0', '16 16 56');
	setorigin (self, self.origin);

	av_global_train = self;
	
// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_modeltrain_find;
};