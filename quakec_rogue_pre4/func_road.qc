void() road_update = {
	self.origin_x = self.origin_x + self.scrollspeed;
	
	if(self.origin_x < self.returnpos) self.origin_x = self.origin_x - self.returnpos;
	
	self.nextthink = time + 0.0138;
};

void() func_road = {
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	
	setsize(self, '0 0 0', '0 0 0');
	
	precache_model(self.model);
	setmodel(self, self.model);
	
	self.think = road_update;
	self.nextthink = time + 0.0138;
};