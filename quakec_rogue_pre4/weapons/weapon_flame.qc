.float flame_time;
.float inflamed;

//função que "queima" o inimigo aos poucos
void() hit_flame_think = {
	setorigin(self, self.owner.origin);
	// intervalo entre frames = 0.03;
	self.nextthink = time + 0.03;
	self.flame_time = self.flame_time + 1;
	// quantidade de frames da animação = 7
	self.frame = self.flame_time % 7;
	// quantidade de frames em que o efeito de fogo fica no inimigo
	if (self.flame_time > 56)
	{
		remove(self);
		return;
	}
	if (self.frame == 0) {
		// som da chama em loop
		sound(self, CHAN_AUTO, "dread/flameoff.wav", 1, ATTN_NORM);
	}
	// aplica dano enquanto o inimigo queima. último parâmetro é a quantidade de dano
	T_Damage(self.owner, self, self, 1);
}

void() weapon_spawn_hit_flame;

void() hit_flame_touch = {
	if (other == self.owner || other.classname == "player") {
		return;
	}
	if (other.health > 0 && !other.inflamed)
	{
		weapon_spawn_hit_flame();
	}
}

void() weapon_spawn_hit_flame = {
	local entity flame;
	flame = spawn();
	// sprite da chama
	setmodel(flame, "progs/s_flame.spr");
	setsize(flame, '16 16 16', '16 16 16');
	flame.solid = SOLID_TRIGGER;
	flame.owner = other;
	flame.movetype = MOVETYPE_NONE;
	flame.think = hit_flame_think;
	// comente para evitar espalhamento
	flame.touch = hit_flame_touch;
	flame.nextthink = time;
	flame.flame_time = 0;
	flame.frame = 0;
	other.inflamed = 1;
}

void() weapon_flame_touch =
{
	if (other == self.owner) {
		return;
	}
	if (other.solid == SOLID_TRIGGER) {
		return;
	}
	self.movedir = '0 0 0';
	if (other.health > 0)
	{
		// aplica o dano inicial. último parâmetro é o dano da arma
		T_Damage(other, self, self.owner, 5);
		if (!other.inflamed) {
			weapon_spawn_hit_flame();
		}
	}
	remove(self);
};

void() weapon_flame_fly =
{
	self.frame = self.frame + 1;
	if (self.frame > 7 || pointcontents(self.origin) != CONTENT_EMPTY)
	{
		remove(self);
		return;
	}
	//self.velocity = self.velocity + '0 0 15' - (self.movedir * 0.12);
	
	self.nextthink = time + 0.1;
};

void(vector org, vector vec) weapon_make_flame =
{
	local entity flame;
	flame = spawn();
	flame.owner = self;
	setmodel(flame, "progs/s_flame.spr");
	setorigin(flame, org);
	flame.movetype = MOVETYPE_FLY;
	flame.solid = SOLID_BBOX;
	
	local vector variance;
	variance = '-10 -10 0' + random() * '20 20 0';
	flame.movedir = normalize(vec) * 550 + variance;
	flame.velocity = flame.movedir;
	
	local float roll;
	roll = 350 + random() * 20;
	flame.angles_z = anglemod(roll);
	
	flame.nextthink = time + 0.1;
	flame.think = weapon_flame_fly;
	flame.touch = weapon_flame_touch;
	flame.classname = "weapon_flame";
	flame.frame = 0;
	setsize(flame, '0 0 0', '0 0 0');
};

void() w_fire_flames =
{
	local vector org;
	makevectors(self.v_angle);
	// posição da chama do ataque
	org = self.origin + v_forward * 30 + v_right * 2 + '0 0 21';
	weapon_make_flame(org, v_forward);
	
	self.ammo_lava_nails = self.ammo_lava_nails - 1;
    self.currentammo = self.ammo_lava_nails;
    UpdateAmmoCounts(self);
};