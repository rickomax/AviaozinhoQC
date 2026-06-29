// Foward declaration here so we can just use the normal jump here.
void() PlayerJump;

// --- AVIÃOZINHO PLAYER FIELDS ---------------------

.float		jump_count;

.float		dash_duration;
.float		dash_cooldown;
.float		dash_count;

// FLAG
float	FL_DASHING				= 262144;	// DASHING;

// --- UTIL -----------------------------------------

float AV_ANGLE_SNAP = 45;

vector(vector vec) SnapOctants = {
	local vector v_ang = vectoangles(vec);
	local float ang = rint(v_ang_y / AV_ANGLE_SNAP) * AV_ANGLE_SNAP;
	
	local vector outvec;
	outvec_y = ang;
	makevectors(outvec);
	
	outvec_x = v_forward_x;
	outvec_y = v_forward_y;
	
	return outvec;
}

vector() MovementVector =
{
	//Keyboard axis.
	local vector wasd = SnapOctants(self.movement);
	
	//Looking direction.
	makevectors(self.angles);
	local vector dir = v_forward;
	dir_z = 0;
	dir = normalize(dir);
	
	//Rotated axis.
	local vector mov;
	mov_x = wasd_x * dir_x + wasd_y * dir_y;
	mov_y = wasd_x * dir_y - wasd_y * dir_x;

	return mov;
};

void(float speed) PushPlayer =
{
	local vector v = self.velocity;
	v_z = 0;
	
	local vector mov = MovementVector();
	
	local float vel = vlen(v);
	if(vel < speed){
		self.velocity_x = mov_x * speed;
		self.velocity_y = mov_y * speed;
	}else{
		self.velocity_x = mov_x * vel;
		self.velocity_y = mov_y * vel;
	}
};

// --- JUMP -----------------------------------------

void() PlayerDoubleJump = {
	if(self.jump_count == 0 && (self.flags & FL_ONGROUND)){
		PlayerJump();
		return;
	}
	
	if(self.av_skating)										return; //Can't double jump while skating.
	if(self.waterlevel >= 2)								return; //Can't double jump in water.
	if(!(self.flags & FL_ONGROUND) && self.jump_count >= 2)	return; // Already jumped twice.
	if(!(self.flags & FL_JUMPRELEASED))						return; // don't pogo stick
	
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	
	if(self.jump_count == 0 && !(self.flags & FL_ONGROUND)) self.jump_count = 1; // Double jump if in air, but has not jumped before.
	
	self.jump_count = self.jump_count + 1;
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	sound(self, CHAN_AUTO, "weapons/r_exp3.wav", 1, ATTN_NORM);
	
	if(vlen(self.movement) > 0) PushPlayer(460);
	self.velocity_z = 380;
};

// --- DASH -----------------------------------------

float AV_DASH_SPEED		= 650.0;
float AV_DASH_DURATION	= 0.2;
float AV_DASH_COOLDOWN	= 1.25;

#define STAT_DASH_INDEX 33
#define STAT_DASH_PERC 34

void() AV_UpdateDashHUD = {
	msg_entity = self; 
	WriteByte(MSG_ONE, SVC_UPDATESTAT);
	WriteByte(MSG_ONE, STAT_DASH_INDEX);
	WriteLong(MSG_ONE, 3 - self.dash_count);
	
	WriteByte(MSG_ONE, SVC_UPDATESTAT);
	WriteByte(MSG_ONE, STAT_DASH_PERC);
	WriteLong(MSG_ONE, (1 - (self.dash_cooldown - time) / AV_DASH_COOLDOWN) * 100);
};

void() PlayerDash =
{
	if(self.av_skating) return; //Can't double jump while skating.
	if(self.dash_count >= 3) return; //Is dash available?
	
	if(!(self.flags & FL_DASHING)) self.flags = self.flags + FL_DASHING;
	
	self.dash_duration = time + AV_DASH_DURATION;
	self.dash_cooldown = time + AV_DASH_COOLDOWN;
	self.dash_count = self.dash_count + 1;
	
	PushPlayer(AV_DASH_SPEED);
	
	if(self.velocity_z <= 0){
		self.velocity_z = 128;
		
		if(self.flags & FL_ONGROUND){
			self.jump_count = self.jump_count + 1;
			self.flags = self.flags - FL_ONGROUND;
		}
	}
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z - 8);
	
	sound(self, CHAN_AUTO, "weapons/r_exp3.wav", 0.5, ATTN_NORM);
};
