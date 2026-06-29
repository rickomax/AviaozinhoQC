/*
==============================================================================

SOLDIER / GRUNT

monster_army: ORIGINAL da id Software (intocado)
monster_nailgrunt: MODIFICADO - Moto com velocidade aumentada e melee

==============================================================================
*/

$cd id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11

$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9

$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24

/*
==============================================================================
FORWARD DECLARATIONS
==============================================================================
*/

// Shot cooldowns (reduz rate de tiro)
float ARMY_SHOT_COOLDOWN = 0.35;
float MOTO_SHOT_COOLDOWN = 0.45;


// Army (original)
void() army_fire;
void() army_missile;

// Moto (modificado)
void() moto_fire;
void() moto_missile;
void() moto_melee1;
void() moto_melee_attack;
void() moto_spike_touch;
float() moto_check_melee;
float() moto_check_range_melee;
float() moto_should_flank;

/*
==============================================================================
SOLDIER CODE - ORIGINAL ID SOFTWARE
==============================================================================
*/

void()	army_stand1	=[	$stand1,	army_stand2	] {ai_stand();};
void()	army_stand2	=[	$stand2,	army_stand3	] {ai_stand();};
void()	army_stand3	=[	$stand3,	army_stand4	] {ai_stand();};
void()	army_stand4	=[	$stand4,	army_stand5	] {ai_stand();};
void()	army_stand5	=[	$stand5,	army_stand6	] {ai_stand();};
void()	army_stand6	=[	$stand6,	army_stand7	] {ai_stand();};
void()	army_stand7	=[	$stand7,	army_stand8	] {ai_stand();};
void()	army_stand8	=[	$stand8,	army_stand1	] {ai_stand();};

void()	army_walk1	=[	$prowl_1,	army_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
ai_walk(1);};
void()	army_walk2	=[	$prowl_2,	army_walk3	] {ai_walk(1);};
void()	army_walk3	=[	$prowl_3,	army_walk4	] {ai_walk(1);};
void()	army_walk4	=[	$prowl_4,	army_walk5	] {ai_walk(1);};
void()	army_walk5	=[	$prowl_5,	army_walk6	] {ai_walk(2);};
void()	army_walk6	=[	$prowl_6,	army_walk7	] {ai_walk(3);};
void()	army_walk7	=[	$prowl_7,	army_walk8	] {ai_walk(4);};
void()	army_walk8	=[	$prowl_8,	army_walk9	] {ai_walk(4);};
void()	army_walk9	=[	$prowl_9,	army_walk10	] {ai_walk(2);};
void()	army_walk10	=[	$prowl_10,	army_walk11	] {ai_walk(2);};
void()	army_walk11	=[	$prowl_11,	army_walk12	] {ai_walk(2);};
void()	army_walk12	=[	$prowl_12,	army_walk13	] {ai_walk(1);};
void()	army_walk13	=[	$prowl_13,	army_walk14	] {ai_walk(0);};
void()	army_walk14	=[	$prowl_14,	army_walk15	] {ai_walk(1);};
void()	army_walk15	=[	$prowl_15,	army_walk16	] {ai_walk(1);};
void()	army_walk16	=[	$prowl_16,	army_walk17	] {ai_walk(1);};
void()	army_walk17	=[	$prowl_17,	army_walk18	] {ai_walk(3);};
void()	army_walk18	=[	$prowl_18,	army_walk19	] {ai_walk(3);};
void()	army_walk19	=[	$prowl_19,	army_walk20	] {ai_walk(3);};
void()	army_walk20	=[	$prowl_20,	army_walk21	] {ai_walk(3);};
void()	army_walk21	=[	$prowl_21,	army_walk22	] {ai_walk(2);};
void()	army_walk22	=[	$prowl_22,	army_walk23	] {ai_walk(1);};
void()	army_walk23	=[	$prowl_23,	army_walk24	] {ai_walk(1);};
void()	army_walk24	=[	$prowl_24,	army_walk1	] {ai_walk(1);};

void()	army_run1	=[	$run1,		army_run2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
ai_run(11);};
void()	army_run2	=[	$run2,		army_run3	] {ai_run(15);};
void()	army_run3	=[	$run3,		army_run4	] {ai_run(10);};
void()	army_run4	=[	$run4,		army_run5	] {ai_run(10);};
void()	army_run5	=[	$run5,		army_run6	] {ai_run(8);};
void()	army_run6	=[	$run6,		army_run7	] {ai_run(15);};
void()	army_run7	=[	$run7,		army_run8	] {ai_run(10);};
void()	army_run8	=[	$run8,		army_run1	] {ai_run(8);};

void()	army_atk1	=[	$shoot1,	army_atk2	] {ai_face();};
void()	army_atk2	=[	$shoot2,	army_atk3	] {ai_face();};
void()	army_atk3	=[	$shoot3,	army_atk4	] {ai_face();};
void()	army_atk4	=[	$shoot4,	army_atk5	] {ai_face();};
void()	army_atk5	=[	$shoot5,	army_atk6	] {ai_face();army_fire();};
void()	army_atk6	=[	$shoot6,	army_atk7	] {ai_face();};
void()	army_atk7	=[	$shoot7,	army_atk8	] {ai_face();SUB_CheckRefire (army_atk1);};
void()	army_atk8	=[	$shoot8,	army_atk9	] {ai_face();};
void()	army_atk9	=[	$shoot9,	army_run1	] {ai_face();};

void()	army_pain1	=[	$pain1,		army_pain2	] {};
void()	army_pain2	=[	$pain2,		army_pain3	] {};
void()	army_pain3	=[	$pain3,		army_pain4	] {};
void()	army_pain4	=[	$pain4,		army_pain5	] {};
void()	army_pain5	=[	$pain5,		army_pain6	] {};
void()	army_pain6	=[	$pain6,		army_run1	] {ai_pain(1);};

void()	army_painb1	=[	$painb1,	army_painb2	] {};
void()	army_painb2	=[	$painb2,	army_painb3	] {ai_painforward(13);};
void()	army_painb3	=[	$painb3,	army_painb4	] {ai_painforward(9);};
void()	army_painb4	=[	$painb4,	army_painb5	] {};
void()	army_painb5	=[	$painb5,	army_painb6	] {};
void()	army_painb6	=[	$painb6,	army_painb7	] {};
void()	army_painb7	=[	$painb7,	army_painb8	] {};
void()	army_painb8	=[	$painb8,	army_painb9	] {};
void()	army_painb9	=[	$painb9,	army_painb10	] {};
void()	army_painb10	=[	$painb10,	army_painb11	] {};
void()	army_painb11	=[	$painb11,	army_painb12	] {};
void()	army_painb12	=[	$painb12,	army_painb13	] {ai_pain(2);};
void()	army_painb13	=[	$painb13,	army_painb14	] {};
void()	army_painb14	=[	$painb14,	army_run1	] {};

void()	army_painc1	=[	$painc1,	army_painc2	] {};
void()	army_painc2	=[	$painc2,	army_painc3	] {ai_pain(1);};
void()	army_painc3	=[	$painc3,	army_painc4	] {};
void()	army_painc4	=[	$painc4,	army_painc5	] {};
void()	army_painc5	=[	$painc5,	army_painc6	] {ai_painforward(1);};
void()	army_painc6	=[	$painc6,	army_painc7	] {ai_painforward(1);};
void()	army_painc7	=[	$painc7,	army_painc8	] {};
void()	army_painc8	=[	$painc8,	army_painc9	] {ai_pain(1);};
void()	army_painc9	=[	$painc9,	army_painc10	] {ai_painforward(4);};
void()	army_painc10	=[	$painc10,	army_painc11	] {ai_painforward(3);};
void()	army_painc11	=[	$painc11,	army_painc12	] {ai_painforward(6);};
void()	army_painc12	=[	$painc12,	army_painc13	] {ai_painforward(8);};
void()	army_painc13	=[	$painc13,	army_run1	] {};

void(entity attacker, float damage)	army_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random ();

	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		army_pain1 ();
		sound (self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		army_painb1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		self.pain_finished = time + 1.1;
		army_painc1 ();
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
};


void() army_fire =
{
	local vector	dir;
	local entity	en;
	
	ai_face ();

	sound (self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);	

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	dir = en.origin - en.velocity*0.2;
	dir = normalize (dir - self.origin);
	
	FireBullets (4, dir, '0.1 0.1 0');

	self.attack_finished = time + ARMY_SHOT_COOLDOWN;
};


void() army_missile =
{
	// Evita entrar na animação de tiro enquanto ainda está no cooldown
	if (time < self.attack_finished)
	{
		self.think = army_run1;
		self.nextthink = time + 0.1;
		return;
	}

	army_atk1();
};


void()	army_die1	=[	$death1,	army_die2	] {};
void()	army_die2	=[	$death2,	army_die3	] {};
void()	army_die3	=[	$death3,	army_die4	]
{self.solid = SOLID_NOT;self.ammo_shells = 5;DropBackpack();};
void()	army_die4	=[	$death4,	army_die5	] {};
void()	army_die5	=[	$death5,	army_die6	] {};
void()	army_die6	=[	$death6,	army_die7	] {};
void()	army_die7	=[	$death7,	army_die8	] {};
void()	army_die8	=[	$death8,	army_die9	] {};
void()	army_die9	=[	$death9,	army_die10	] {};
void()	army_die10	=[	$death10,	army_die10	] {};

void()	army_cdie1	=[	$deathc1,	army_cdie2	] {};
void()	army_cdie2	=[	$deathc2,	army_cdie3	] {ai_back(5);};
void()	army_cdie3	=[	$deathc3,	army_cdie4	]
{self.solid = SOLID_NOT;self.ammo_shells = 5;DropBackpack();ai_back(4);};
void()	army_cdie4	=[	$deathc4,	army_cdie5	] {ai_back(13);};
void()	army_cdie5	=[	$deathc5,	army_cdie6	] {ai_back(3);};
void()	army_cdie6	=[	$deathc6,	army_cdie7	] {ai_back(4);};
void()	army_cdie7	=[	$deathc7,	army_cdie8	] {};
void()	army_cdie8	=[	$deathc8,	army_cdie9	] {};
void()	army_cdie9	=[	$deathc9,	army_cdie10	] {};
void()	army_cdie10	=[	$deathc10,	army_cdie11	] {};
void()	army_cdie11	=[	$deathc11,	army_cdie11	] {};


void() army_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		army_die1 ();
	else
		army_cdie1 ();
};


/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush

SOLDIER ORIGINAL DA id SOFTWARE - NÃO MODIFICADO
*/

void() monster_army =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/soldier.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");

	precache_sound ("player/udeath.wav");		// gib death

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/soldier.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 30;

	self.th_stand = army_stand1;
	self.th_walk = army_walk1;
	self.th_run = army_run1;
	self.th_missile = army_missile;
	self.th_pain = army_pain;
	self.th_die = army_die;

	walkmonster_start ();
};

/*
==============================================================================
NAILGRUNT - MOTO COM VELOCIDADE E MELEE
==============================================================================
*/

// Configurações de melee
float MOTO_MELEE_DAMAGE = 3;        // Reduzido 60%: era 8, agora 3
float MOTO_MELEE_RANGE = 90;
float MOTO_MELEE_COOLDOWN = 1.5;

.float melee_cooldown;

// Calcula se deve tentar flanquear para frente do jogador
float() moto_should_flank =
{
	local vector delta, player_forward;
	local float dot;
	
	if (!self.enemy)
		return FALSE;
	
	// Só flanqueia jogadores
	if (!(self.enemy.flags & FL_CLIENT))
		return FALSE;
	
	delta = self.origin - self.enemy.origin;
	makevectors(self.enemy.angles);
	player_forward = v_forward;
	
	dot = normalize(delta) * player_forward;
	
	// Se dot > 0.3, está atrás do jogador - deve flanquear!
	if (dot > 0.3)
		return TRUE;
	
	return FALSE;
};

// Stand (igual ao original)
void()	moto_stand1	=[	$stand1,	moto_stand2	] {ai_stand();};
void()	moto_stand2	=[	$stand2,	moto_stand3	] {ai_stand();};
void()	moto_stand3	=[	$stand3,	moto_stand4	] {ai_stand();};
void()	moto_stand4	=[	$stand4,	moto_stand5	] {ai_stand();};
void()	moto_stand5	=[	$stand5,	moto_stand6	] {ai_stand();};
void()	moto_stand6	=[	$stand6,	moto_stand7	] {ai_stand();};
void()	moto_stand7	=[	$stand7,	moto_stand8	] {ai_stand();};
void()	moto_stand8	=[	$stand8,	moto_stand1	] {ai_stand();};

// Walk - 3X MAIS RÁPIDO (aumentado de 2x)
void()	moto_walk1	=[	$prowl_1,	moto_walk2	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(3);};  // Era 2, agora 3
void()	moto_walk2	=[	$prowl_2,	moto_walk3	] {ai_walk(3);};
void()	moto_walk3	=[	$prowl_3,	moto_walk4	] {ai_walk(3);};
void()	moto_walk4	=[	$prowl_4,	moto_walk5	] {ai_walk(3);};
void()	moto_walk5	=[	$prowl_5,	moto_walk6	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(6);};  // Era 4, agora 6
void()	moto_walk6	=[	$prowl_6,	moto_walk7	] {ai_walk(9);};  // Era 6, agora 9
void()	moto_walk7	=[	$prowl_7,	moto_walk8	] {ai_walk(12);};  // Era 8, agora 12
void()	moto_walk8	=[	$prowl_8,	moto_walk9	] {ai_walk(12);};  // Era 8, agora 12
void()	moto_walk9	=[	$prowl_9,	moto_walk10	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(6);};  // Era 4, agora 6
void()	moto_walk10	=[	$prowl_10,	moto_walk11	] {ai_walk(6);};  // Era 4, agora 6
void()	moto_walk11	=[	$prowl_11,	moto_walk12	] {ai_walk(6);};  // Era 4, agora 6
void()	moto_walk12	=[	$prowl_12,	moto_walk13	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk13	=[	$prowl_13,	moto_walk14	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(2);};  // Era 1, agora 2
void()	moto_walk14	=[	$prowl_14,	moto_walk15	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk15	=[	$prowl_15,	moto_walk16	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk16	=[	$prowl_16,	moto_walk17	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk17	=[	$prowl_17,	moto_walk18	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(9);};  // Era 6, agora 9
void()	moto_walk18	=[	$prowl_18,	moto_walk19	] {ai_walk(9);};  // Era 6, agora 9
void()	moto_walk19	=[	$prowl_19,	moto_walk20	] {ai_walk(9);};  // Era 6, agora 9
void()	moto_walk20	=[	$prowl_20,	moto_walk21	] {ai_walk(9);};  // Era 6, agora 9
void()	moto_walk21	=[	$prowl_21,	moto_walk22	] {
sound (self, CHAN_BODY, "nailgrunt/engine.wav", 1, ATTN_NORM);
ai_walk(6);};  // Era 4, agora 6
void()	moto_walk22	=[	$prowl_22,	moto_walk23	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk23	=[	$prowl_23,	moto_walk24	] {ai_walk(3);};  // Era 2, agora 3
void()	moto_walk24	=[	$prowl_24,	moto_walk1	] {ai_walk(3);};  // Era 2, agora 3

// Run - 60% MAIS RÁPIDO + TENTATIVA DE MELEE + FLANQUEAMENTO FRONTAL
void()	moto_run1	=[	$run1,		moto_run2	] {
sound (self, CHAN_BODY, "nailgrunt/engine_rev.wav", 1, ATTN_NORM);
	
// Tenta melee se estiver perto E bem posicionado
if (moto_check_melee())
{
	moto_melee1();
}
// Se está atrás do jogador, tenta flanquear para frente
else if (moto_should_flank() && random() < 0.6)
{
	// Usa ai_run com chance de mudança de direção para flanquear
	local vector player_forward, flank_dir;
	makevectors(self.enemy.angles);
	player_forward = v_forward;
	
	// Tenta ir para um dos lados da frente do jogador
	if (random() < 0.5)
		flank_dir = player_forward + v_right * 0.7;  // Direita frontal
	else
		flank_dir = player_forward - v_right * 0.7;  // Esquerda frontal
	
	// Ajusta ideal_yaw para flanquear
	self.ideal_yaw = vectoyaw(flank_dir);
	ChangeYaw();
	ai_run(26);  // Mais rápido quando flanqueando (era 20, agora 26)
}
else
{
	ai_run(23);  // Velocidade normal aumentada (era 18, agora 23)
}
};
void()	moto_run2	=[	$run2,		moto_run3	] {
sound (self, CHAN_BODY, "nailgrunt/engine_rev.wav", 1, ATTN_NORM);
ai_run(31);};  // Era 24, agora 31
void()	moto_run3	=[	$run3,		moto_run4	] {ai_run(21);};  // Era 16, agora 21
void()	moto_run4	=[	$run4,		moto_run5	] {
sound (self, CHAN_BODY, "nailgrunt/engine_rev.wav", 1, ATTN_NORM);
ai_run(21);};  // Era 16, agora 21
void()	moto_run5	=[	$run5,		moto_run6	] {ai_run(17);};  // Era 13, agora 17
void()	moto_run6	=[	$run6,		moto_run7	] {
sound (self, CHAN_BODY, "nailgrunt/engine_rev.wav", 1, ATTN_NORM);
ai_run(31);};  // Era 24, agora 31
void()	moto_run7	=[	$run7,		moto_run8	] {ai_run(21);};  // Era 16, agora 21
void()	moto_run8	=[	$run8,		moto_run1	] {ai_run(17);};  // Era 13, agora 17

// Ataque nailgun
void()	moto_atk1	=[	$shoot1,	moto_atk2	] {ai_face();};
void()	moto_atk2	=[	$shoot2,	moto_atk3	] {ai_face();};
void()	moto_atk3	=[	$shoot3,	moto_atk4	] {ai_face();};
void()	moto_atk4	=[	$shoot4,	moto_atk5	] {ai_face();};
void()	moto_atk5	=[	$shoot5,	moto_atk6	] {ai_face();};
void()	moto_atk6	=[	$shoot6,	moto_atk7	] {moto_fire();};
void()	moto_atk7	=[	$shoot7,	moto_atk8	] {ai_face();};
void()	moto_atk8	=[	$shoot8,	moto_atk9	] {ai_face();};
void()	moto_atk9	=[	$shoot5,	moto_atk10	] {ai_face();};
void()	moto_atk10	=[	$shoot6,	moto_atk11	] {moto_fire();};
void()	moto_atk11	=[	$shoot7,	moto_atk12	] {ai_face();};
void()	moto_atk12	=[	$shoot8,	moto_atk13	] {ai_face();};
void()	moto_atk13	=[	$shoot9,	moto_atk14	] {ai_face();};
void()	moto_atk14	=[	$shoot1,	moto_run1	] {ai_face();SUB_CheckRefire (moto_atk1);};

// Ataque MELEE - USA ANIMAÇÃO DE RUN COMO DASH
void()	moto_melee1	=[	$run1,		moto_melee2	] {
ai_charge(33);  // Dash super rápido! (era 25, agora 33)
};
void()	moto_melee2	=[	$run2,		moto_melee3	] {
ai_charge(40);  // ATAQUE! (era 30, agora 40)
moto_melee_attack();
};
void()	moto_melee3	=[	$run3,		moto_melee4	] {ai_charge(24);};  // Era 18, agora 24
void()	moto_melee4	=[	$run4,		moto_run1	] {ai_charge(13);};  // Era 10, agora 13

// Pain (mesmas animações do original)
void()	moto_pain1	=[	$pain1,		moto_pain2	] {};
void()	moto_pain2	=[	$pain2,		moto_pain3	] {};
void()	moto_pain3	=[	$pain3,		moto_pain4	] {};
void()	moto_pain4	=[	$pain4,		moto_pain5	] {};
void()	moto_pain5	=[	$pain5,		moto_pain6	] {};
void()	moto_pain6	=[	$pain6,		moto_run1	] {ai_pain(1);};

void()	moto_painb1	=[	$painb1,	moto_painb2	] {};
void()	moto_painb2	=[	$painb2,	moto_painb3	] {ai_painforward(13);};
void()	moto_painb3	=[	$painb3,	moto_painb4	] {ai_painforward(9);};
void()	moto_painb4	=[	$painb4,	moto_painb5	] {};
void()	moto_painb5	=[	$painb5,	moto_painb6	] {};
void()	moto_painb6	=[	$painb6,	moto_painb7	] {};
void()	moto_painb7	=[	$painb7,	moto_painb8	] {};
void()	moto_painb8	=[	$painb8,	moto_painb9	] {};
void()	moto_painb9	=[	$painb9,	moto_painb10	] {};
void()	moto_painb10	=[	$painb10,	moto_painb11	] {};
void()	moto_painb11	=[	$painb11,	moto_painb12	] {};
void()	moto_painb12	=[	$painb12,	moto_painb13	] {ai_pain(2);};
void()	moto_painb13	=[	$painb13,	moto_painb14	] {};
void()	moto_painb14	=[	$painb14,	moto_run1	] {};

void()	moto_painc1	=[	$painc1,	moto_painc2	] {};
void()	moto_painc2	=[	$painc2,	moto_painc3	] {ai_pain(1);};
void()	moto_painc3	=[	$painc3,	moto_painc4	] {};
void()	moto_painc4	=[	$painc4,	moto_painc5	] {};
void()	moto_painc5	=[	$painc5,	moto_painc6	] {ai_painforward(1);};
void()	moto_painc6	=[	$painc6,	moto_painc7	] {ai_painforward(1);};
void()	moto_painc7	=[	$painc7,	moto_painc8	] {};
void()	moto_painc8	=[	$painc8,	moto_painc9	] {ai_pain(1);};
void()	moto_painc9	=[	$painc9,	moto_painc10	] {ai_painforward(4);};
void()	moto_painc10	=[	$painc10,	moto_painc11	] {ai_painforward(3);};
void()	moto_painc11	=[	$painc11,	moto_painc12	] {ai_painforward(6);};
void()	moto_painc12	=[	$painc12,	moto_painc13	] {ai_painforward(8);};
void()	moto_painc13	=[	$painc13,	moto_run1	] {};

void(entity attacker, float damage) moto_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random ();

	if (r < 0.2)
	{
		self.pain_finished = time + 0.6;
		moto_pain1 ();
		sound (self, CHAN_VOICE, "nailgrunt/pain1.wav", 1, ATTN_NORM);
	}
	else if (r < 0.6)
	{
		self.pain_finished = time + 1.1;
		moto_painb1 ();
		sound (self, CHAN_VOICE, "nailgrunt/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		self.pain_finished = time + 1.1;
		moto_painc1 ();
		sound (self, CHAN_VOICE, "nailgrunt/pain2.wav", 1, ATTN_NORM);
	}
};

// FUNÇÃO DE DISPARO DE NAILS
void() moto_fire =
{
	local vector dir;
	local entity target;
	
    sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    self.effects = self.effects | EF_MUZZLEFLASH;
    
    target = self.enemy;
    dir = target.origin - target.velocity*0.2;
	dir = normalize (dir - self.origin);
    
    launch_spike (self.origin + '0 0 16', dir);
    // Reduzido em 94%: era 6, depois 1, agora ~0.4 (mas mínimo 1 para não ser inútil)
    newmis.dmg = 0.4;  // impacto menor que 1
    
    // IMPORTANTE: Marca o spike para só afetar jogadores
    newmis.owner = self;
    newmis.classname = "moto_spike";
    newmis.touch = moto_spike_touch;  // Touch customizado

	self.attack_finished = time + MOTO_SHOT_COOLDOWN;
};


void() moto_missile =
{
	// Evita entrar na animação de tiro enquanto ainda está no cooldown
	if (time < self.attack_finished)
	{
		self.think = moto_run1;
		self.nextthink = time + 0.1;
		return;
	}

	moto_atk1();
};

// Touch customizado para spikes da moto - SÓ AFETA JOGADORES
void() moto_spike_touch =
{
	local float damg;
	
	if (other == self.owner)
		return;  // Não acerta quem atirou
	
	// SÓ CAUSA DANO EM JOGADORES
	if (other.takedamage && (other.flags & FL_CLIENT))
	{
		damg = self.dmg;
		spawn_touchblood(damg);
		T_Damage(other, self, self.owner, damg);
	}
	
	// Remove o spike
	remove(self);
};

// VERIFICA SE ESTÁ PERTO PARA MELEE
float() moto_check_range_melee =
{
	local vector delta;
	local float len;
	
	delta = self.enemy.origin - self.origin;
	len = vlen(delta);
	
	if (len <= MOTO_MELEE_RANGE)
		return TRUE;
		
	return FALSE;
};

// VERIFICA SE PODE FAZER MELEE (inclui cooldown e se é jogador)
float() moto_check_melee =
{
	local vector delta, forward_dir;
	local float len, dot;
	
	// Só faz melee em jogadores
	if (!(self.enemy.flags & FL_CLIENT))
		return FALSE;
	
	// Verifica cooldown
	if (time < self.melee_cooldown)
		return FALSE;
	
	// Verifica distância
	delta = self.enemy.origin - self.origin;
	len = vlen(delta);
	
	if (len > MOTO_MELEE_RANGE)
		return FALSE;
	
	// NOVO: Prefere atacar quando está na frente ou nas laterais do jogador
	// (ao invés de por trás)
	makevectors(self.enemy.angles);
	forward_dir = v_forward;
	dot = delta * forward_dir;
	
	// Se dot > 0, moto está atrás do jogador (menos ideal)
	// Se dot < 0, moto está na frente do jogador (ideal para atropelamento!)
	// Aumenta chance de melee quando está na frente
	if (dot < 0)
		return TRUE;  // NA FRENTE - sempre tenta melee
	else if (dot > 0 && len < MOTO_MELEE_RANGE * 0.5)
		return TRUE;  // ATRÁS mas muito perto - tenta melee
	
	return FALSE;  // Atrás e não tão perto - não tenta
};

// EXECUTA O ATAQUE MELEE
void() moto_melee_attack =
{
	local vector delta;
	local float ldmg;
	
	// ============================================
	// IMPORTANTE: SÓ ATACA JOGADORES
	// Dash NÃO causa dano em outros monstros!
	// ============================================
	if (!(self.enemy.flags & FL_CLIENT))
		return;
	
	ai_face();
	
	delta = self.enemy.origin - self.origin;
	if (vlen(delta) > MOTO_MELEE_RANGE)
		return;
	
	// Som de impacto da moto
	sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
	
	// Dano base
	ldmg = MOTO_MELEE_DAMAGE;
	
	// Bonus de dano se estiver em alta velocidade (reduzido 60%: era +3, agora +1)
	if (vlen(self.velocity) > 200)
		ldmg = ldmg + 1;
	
	// Causa dano APENAS NO JOGADOR
	T_Damage (self.enemy, self, self, ldmg);
	
	// REMOVIDO: Knockback que empurrava o jogador
	// O jogador agora só toma dano, sem perder controle do movimento
	
	// Define cooldown
	self.melee_cooldown = time + MOTO_MELEE_COOLDOWN;
	
	// Recuo da moto após o impacto
	self.velocity = self.velocity - normalize(delta) * 150;
};

// Death
void()	moto_die1	=[	$death1,	moto_die2	] {};
void()	moto_die2	=[	$death2,	moto_die3	] {};
void()	moto_die3	=[	$death3,	moto_die4	]
{self.solid = SOLID_NOT;self.ammo_nails = 10;DropBackpack();};
void()	moto_die4	=[	$death4,	moto_die5	] {};
void()	moto_die5	=[	$death5,	moto_die6	] {};
void()	moto_die6	=[	$death6,	moto_die7	] {};
void()	moto_die7	=[	$death7,	moto_die8	] {};
void()	moto_die8	=[	$death8,	moto_die9	] {};
void()	moto_die9	=[	$death9,	moto_die10	] {};
void()	moto_die10	=[	$death10,	moto_die10	] {};

void()	moto_cdie1	=[	$deathc1,	moto_cdie2	] {};
void()	moto_cdie2	=[	$deathc2,	moto_cdie3	] {ai_back(5);};
void()	moto_cdie3	=[	$deathc3,	moto_cdie4	]
{self.solid = SOLID_NOT;self.ammo_nails = 10;DropBackpack();ai_back(4);};
void()	moto_cdie4	=[	$deathc4,	moto_cdie5	] {ai_back(13);};
void()	moto_cdie5	=[	$deathc5,	moto_cdie6	] {ai_back(3);};
void()	moto_cdie6	=[	$deathc6,	moto_cdie7	] {ai_back(4);};
void()	moto_cdie7	=[	$deathc7,	moto_cdie8	] {};
void()	moto_cdie8	=[	$deathc8,	moto_cdie9	] {};
void()	moto_cdie9	=[	$deathc9,	moto_cdie10	] {};
void()	moto_cdie10	=[	$deathc10,	moto_cdie11	] {};
void()	moto_cdie11	=[	$deathc11,	moto_cdie11	] {};

void() moto_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		self.ammo_nails = 10;
		DropBackpack();
		return;
	}

// regular death
	sound (self, CHAN_VOICE, "nailgrunt/death1.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		moto_die1 ();
	else
		moto_cdie1 ();
};

/*QUAKED monster_nailgrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush

MOTO DE ASSÉDIO - Velocidade super aumentada, dano muito baixo
- 3x mais rápido caminhando (~120 u/s)
- 2x mais rápido correndo (~180 u/s)
- Dash ultra rápido (40 u/frame)
- Ataque melee FRACO (3 de dano base, +1 se em alta velocidade)
- Nails FRACOS (1 dmg) - apenas para incomodar
- SEM knockback - jogador mantém controle do movimento
- Cooldown de 1.5s entre ataques melee
- Melee NÃO afeta outros monstros, apenas jogadores
- Nails NÃO afetam outros monstros, apenas jogadores (passa direto)
- AI INTELIGENTE: Tenta flanquear para atacar o jogador PELA FRENTE
- FUNÇÃO: Moto de ASSÉDIO - cria pressão mas não mata rápido
- USE EM GRUPOS: Dano individual é baixo, use 5-8 motos para desafio real
*/

void() monster_nailgrunt =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/soldier3.mdl");
	precache_model ("progs/h_guard.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_sound ("nailgrunt/death1.wav");
	precache_sound ("nailgrunt/engine.wav");
	precache_sound ("nailgrunt/engine_rev.wav");
	precache_sound ("nailgrunt/pain1.wav");
	precache_sound ("nailgrunt/pain2.wav");
	precache_sound ("nailgrunt/sight1.wav");
	precache_sound ("player/udeath.wav");
	precache_sound ("weapons/spike2.wav");
	precache_sound ("zombie/z_hit.wav");  // Som de impacto melee

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/soldier3.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 30;

	self.th_stand = moto_stand1;
	self.th_walk = moto_walk1;
	self.th_run = moto_run1;
	self.th_missile = moto_missile;
	self.th_melee = moto_melee1;  // Define ataque melee
	self.th_pain = moto_pain;
	self.th_die = moto_die;

	walkmonster_start ();
};
