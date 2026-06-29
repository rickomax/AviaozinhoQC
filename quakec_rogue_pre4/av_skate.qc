.float av_skating;

#define AV_SKATE_FRICTION_WMOD 1.04
#define AV_SKATE_FRICTION_SMOD 1.08
#define AV_SKATE_ROTATION_SPEED 0.04
#define AV_SKATE_SPEED_LIMIT 1024

void() AV_SkateUpdate() = {
	if(!self.av_skating) return;
	
	if(!(self.flags & FL_ONGROUND)) return;
	
	//DELAY HORIZONTAL FRICTION
	if(self.movement_x || self.movement_y){
		self.velocity_x = self.velocity_x * AV_SKATE_FRICTION_SMOD;
		self.velocity_y = self.velocity_y * AV_SKATE_FRICTION_SMOD;
	}else{
		self.velocity_x = self.velocity_x * AV_SKATE_FRICTION_WMOD;
		self.velocity_y = self.velocity_y * AV_SKATE_FRICTION_WMOD;
	}
	
	//ROTATE VELOCITY TOWARDS LOOKING VECTOR
	local vector l_vec, v_vec, r_vec;
	local float s_speed;
	
	l_vec = MovementVector();
	l_vec_z = 0;
	l_vec = normalize(l_vec);
	
	v_vec = self.velocity;
	v_vec_z = 0;
	
	s_speed = vlen(v_vec); //SPEED
	if(s_speed > AV_SKATE_SPEED_LIMIT) s_speed = AV_SKATE_SPEED_LIMIT;
	
	v_vec = normalize(v_vec);
	
	r_vec_x = v_vec_x + (l_vec_x - v_vec_x) * AV_SKATE_ROTATION_SPEED;
	r_vec_y = v_vec_y + (l_vec_y - v_vec_y) * AV_SKATE_ROTATION_SPEED;
	
	r_vec = normalize(r_vec);
	
	self.velocity_x = r_vec_x * s_speed;
	self.velocity_y = r_vec_y * s_speed;
};

void() AV_SwitchSkate() = {
	self.av_skating = !self.av_skating;
	
	if(self.av_skating != self.av_camera_active) AV_SwitchCam();
	
	if(self.av_skating){
		setmodel(self, "progs/splayer.mdl");
	}else{
		setmodel(self, "progs/player.mdl");
	}
	
	modelindex_player = self.modelindex;
};