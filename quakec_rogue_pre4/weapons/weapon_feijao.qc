void() feijao_explode =
{
	local entity tgt = self.movetarget;
	
	if(tgt.health <= 0){
		tgt.feijao_manager = 0;
		tgt.feijao_count   = 0;
		remove(self);
		return;
	}

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.movetarget.origin_x);
	WriteCoord (MSG_BROADCAST, self.movetarget.origin_y);
	WriteCoord (MSG_BROADCAST, self.movetarget.origin_z);
	
	T_RadiusDamage (self, self.owner, tgt.feijao_count * 20, 0);
	
	tgt.feijao_manager = 0;
	tgt.feijao_count   = 0;
	
	tgt.effects = 0;
	
	remove(self);
}

float AV_FEIJAO_TIME = 0.45;

void() feijao_touch =
{
	if (other == self.owner)			return;
	if (other.solid == SOLID_TRIGGER)	return;

	if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }
	if (!other.takedamage){ remove(self); return; }
	
	spawn_touchblood (9);
	T_Damage (other, self, self.owner, 6);
	other.feijao_count = other.feijao_count + 1;
	
	if(other.feijao_manager != 0){
		if(other.feijao_count < 6)
			other.feijao_manager.nextthink = time + AV_FEIJAO_TIME;
		else
			other.feijao_manager.nextthink = time + 0.001;
			
		remove(self);
		return;
	}
	
	other.effects = EF_DIMLIGHT;
	
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	setmodel(self, "");
	setsize(self, '-8 -8 -8', '8 8 8');
	
	self.movetarget = other;
	other.feijao_manager = self;
	
	self.think = feijao_explode;
	self.nextthink = time + AV_FEIJAO_TIME;
};

void(vector org, vector dir) feijao_launch =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	newmis.effects = EF_DIMLIGHT;
	
	newmis.touch = feijao_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireFeijao =
{
	local vector	dir;
	local entity	old;
	
	sound (self, CHAN_WEAPON, "weapons/feijoada.wav", 1, ATTN_NORM);

	self.currentammo = self.ammo_lava_nails = self.ammo_lava_nails - 1;
	UpdateAmmoCounts(self);

	dir = aim (self, 1024);
	feijao_launch (self.origin + '0 0 16', dir);
	newmis.touch = feijao_touch;
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.punchangle_x = -2;
}
