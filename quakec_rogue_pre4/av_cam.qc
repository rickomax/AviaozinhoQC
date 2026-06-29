.entity	av_camera;
.float	av_camera_active;

float AV_CAMERA_DIST = 64;
float AV_CAMERA_PADDING = 12;

void() AV_CamUpdate = {
	if(self.av_camera_active == 0) return;
	
	self.weaponmodel = "";
	
	local vector view_org, view_end;
	makevectors(self.v_angle);
	view_org = self.origin + '0 0 32';
	view_end = view_org + (v_forward * -(AV_CAMERA_DIST + AV_CAMERA_PADDING));
	
	local vector padding_dir = normalize(view_org - view_end);
	
	traceline(view_org, view_end, TRUE, self);
	if(trace_fraction < 1.0)
		view_end = trace_endpos + padding_dir * AV_CAMERA_PADDING;
	else
		view_end = view_end + padding_dir * AV_CAMERA_PADDING;
	
	setorigin(self.av_camera, view_end);
};

void() AV_SwitchCam = {
	self.av_camera_active = !self.av_camera_active;
	
	if(self.av_camera_active){
		if(self.av_camera == world) self.av_camera = spawn();
		
		setmodel(self.av_camera, "progs/eyes.mdl");
		
		self.av_camera.solid = SOLID_NOT;
		self.av_camera.movetype = MOVETYPE_FLY;
		
		msg_entity = self;
		WriteByte(MSG_ONE, 5);
		WriteEntity(MSG_ONE, self.av_camera);
		
		AV_CamUpdate();
	}else{
		msg_entity = self;
		WriteByte (MSG_ONE, 5);
		WriteEntity (MSG_ONE, self);
		
		W_SetCurrentAmmo();
		
		setmodel(self.av_camera, "");
	}
};