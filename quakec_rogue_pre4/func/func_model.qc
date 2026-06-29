.vector mdl_size;
.float mdl_notsolid;

void() func_model = {
	precache_model(self.model);
	setmodel(self, self.model);
	
	local vector smin, smax;
	smin_x = -self.mdl_size_x / 2;
	smin_y = -self.mdl_size_y / 2;
	smin_z = 0;
	smax_x = -smin_x;
	smax_y = -smin_y;
	smax_z = self.mdl_size_z;
	
	if(self.mdl_notsolid == 0)
		self.solid = SOLID_SLIDEBOX;
	else
		self.solid = SOLID_NOT;
		
	setsize(self, smin, smax);
}