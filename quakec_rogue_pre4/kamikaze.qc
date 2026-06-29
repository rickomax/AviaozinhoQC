// ==========================================================
// MONSTER_KAMIKAZE (standalone, vanilla-friendly)
// ==========================================================
// - Corre em direção ao player e explode:
//      • por proximidade (82 unidades)
//      • por contato direto com o PLAYER (não outros monstros)
//      • com 1 hit de qualquer arma (versão padrão)
//      • após 3 hits do player (versão TANQUE, spawnflag 1)
// - Explosão padrão:  30 de dano, raio 160
// - Explosão tanque:  40 de dano, raio 160
// - Versão tanque é forte contra monstros (recebe metade)
// - Gibs em dobro ao explodir
// - Grito contínuo enquanto persegue o jogador
//
// SPAWNFLAGS:
//   1 = TANQUE → 125 de vida, explode com 3 hits, mais dano
// ==========================================================


// ------------------------ CAMPOS --------------------------

.float kam_hits;        // contador de tiros do player
.float kam_nextscream;  // cooldown para o grito contínuo


// --------------------- CONSTANTES -------------------------

float KAMIKAZE_ARM_DISTANCE = 82;
float KAMIKAZE_BLAST_DAMAGE = 30;
float KAMIKAZE_BLAST_RADIUS = 160;
float KAMIKAZE_THINK_TIME   = 0.1;

// spawnflag: versão tanque (125 hp, 3 hits, explosão mais forte)
float KAMIKAZE_TANK              = 1;
float KAMIKAZE_TANK_BLAST_DAMAGE = 40;
float KAMIKAZE_TANK_BLAST_RADIUS = 160;

// frames do modelo
float KAMIKAZE_FIRST_FRAME = 0;
float KAMIKAZE_LAST_FRAME  = 17;
float KAMIKAZE_IDLE_FRAME  = 0;


// ---------------- DANO EM ÁREA CUSTOM ---------------------
// Para o player: aplica dano direto na health para contornar
// o pain_finished (imunidade temporária pós-hit do Quake C).
// Kamikazes vizinhos NÃO recebem T_Damage aqui — eles são
// detonados via touch/proximidade quando a onda de explosão
// chega neles, evitando que o enemy deles seja corrompido.

void(vector org, float radius, float damage, entity attacker) Kamikaze_RadiusDamage =
{
    local entity ent;
    local float  dist;
    local float  points;

    ent = findradius(org, radius);

    while (ent)
    {
        // ignora outros kamikazes — eles explodem por touch/proximidade
        // ignora gibs (FL_FLY = flag de gib no Quake C vanilla)
        if (ent.takedamage && ent.classname != "monster_kamikaze"
            && !(ent.flags & FL_FLY))
        {
            dist   = vlen(org - (ent.origin + (ent.mins + ent.maxs) * 0.5));
            points = damage * (1 - dist / radius);

            if (points > 0)
            {
                if (ent.classname == "player")
                {
                    ent.health = ent.health - points;
                    ent.velocity = ent.velocity + normalize(ent.origin - org) * points * 12;

                    if (ent.health <= 0)
                    {
                        ent.health        = -99;
                        ent.pain_finished = 0;
                        T_Damage(ent, world, attacker, 1);
                    }
                    else
                    {
                        ent.pain_finished = 0;
                        if (ent.th_pain)
                            ent.th_pain(attacker, points);
                    }
                }
                else
                {
                    T_Damage(ent, world, attacker, points);
                }
            }
        }
        ent = ent.chain;
    }
};


// forward declaration — kamikaze_explode é definida depois do touch
void() kamikaze_explode;


// ------------------------ TOUCH ---------------------------
// Regras de toque:
// • Toca player              → explode sempre
// • Toca outro kamikaze      → explode só se o player está
//                              dentro do raio (cadeia útil)
// • Toca gib/corpse          → IGNORA (FL_FLY = gib flag)
// • Toca monstro vivo        → explode
// • Toca world/brush         → ignora

void() kamikaze_touch =
{
    local float player_dist;

    if (other == world)
        return;

    // ignora gibs e corpos no chão (FL_FLY é a flag de gib vanilla)
    if (other.flags & FL_FLY)
        return;

    // ignora entidades sem vida (corpos de monstros mortos)
    if (other.health <= 0 && other.classname != "player")
        return;

    // contato direto com o player: explode sempre
    if (other.classname == "player")
    {
        kamikaze_explode();
        return;
    }

    // contato com outro kamikaze: só explode se o player
    // estiver dentro do raio desta posição
    if (other.classname == "monster_kamikaze")
    {
        if (!self.enemy || self.enemy.health <= 0)
            return;

        player_dist = vlen(self.origin - self.enemy.origin);

        if (player_dist <= KAMIKAZE_BLAST_RADIUS)
            kamikaze_explode();

        return;
    }

    // monstro vivo ou outra entidade que tome dano
    if (other.takedamage)
        kamikaze_explode();
};


// ---------------------- GIBS EXTRA ------------------------

void() kamikaze_gibs =
{
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);
    ThrowHead("progs/h_gib.mdl", -20);
};


// ------------------- GRITO CONTÍNUO -----------------------

void() kamikaze_scream =
{
    if (time < self.kam_nextscream)
        return;
    sound(self, CHAN_VOICE, "kamikaze/scream.wav", 1, ATTN_NORM);
    self.kam_nextscream = time + 1.5;
};


// ---------------------- EXPLOSÃO --------------------------

void() kamikaze_explode =
{
    local vector org;
    local entity real_attacker;
    local float  blast_damage;
    local float  blast_radius;

    if (self.solid == SOLID_NOT)
        return;

    // captura tudo ANTES de mutar qualquer campo do self
    org = self.origin + '0 0 16';

    if (self.enemy)
        real_attacker = self.enemy;
    else
        real_attacker = world;

    if (self.spawnflags & KAMIKAZE_TANK)
    {
        blast_damage = KAMIKAZE_TANK_BLAST_DAMAGE;
        blast_radius = KAMIKAZE_TANK_BLAST_RADIUS;
    }
    else
    {
        blast_damage = KAMIKAZE_BLAST_DAMAGE;
        blast_radius = KAMIKAZE_BLAST_RADIUS;
    }

    self.solid      = SOLID_NOT;
    self.takedamage = DAMAGE_NO;
    self.velocity   = '0 0 0';

    if (self.health > 0)
    {
        self.health = 0;
        killed_monsters = killed_monsters + 1;
        WriteByte(MSG_BROADCAST, SVC_KILLEDMONSTER);
    }

    kamikaze_gibs();

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, org_x);
    WriteCoord(MSG_BROADCAST, org_y);
    WriteCoord(MSG_BROADCAST, org_z);

    Kamikaze_RadiusDamage(org, blast_radius, blast_damage, real_attacker);

    remove(self);
};


// --------------------- PROXIMIDADE ------------------------

void() kamikaze_checkdistance =
{
    local float dist;

    if (!self.enemy || self.enemy.health <= 0)
        return;

    dist = vlen(self.origin - self.enemy.origin);

    if (dist <= KAMIKAZE_ARM_DISTANCE)
        kamikaze_explode();
};


// ------------------------ IDLE ----------------------------

void() kamikaze_idle =
{
    if (self.frame < KAMIKAZE_FIRST_FRAME || self.frame > 4)
        self.frame = KAMIKAZE_IDLE_FRAME;
    else
        self.frame++;

    if (FindTarget())
        return;

    ai_stand();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_idle;
};


// ------------------------ WALK ----------------------------

void() kamikaze_walk =
{
    if (!self.enemy || self.enemy.health <= 0)
    {
        if (!FindTarget())
        {
            self.think     = kamikaze_idle;
            self.nextthink = time + KAMIKAZE_THINK_TIME;
            return;
        }
    }

    if (self.frame < 5 || self.frame > KAMIKAZE_LAST_FRAME)
        self.frame = 5;
    else
        self.frame++;

    if (self.frame >= 0 && self.frame <= 4)
        self.frame = 5;

    ai_run(20);

    kamikaze_scream();
    kamikaze_checkdistance();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_walk;
};


// -------------------- PAIN & DIE --------------------------
//
// VERSÃO PADRÃO (sem spawnflag 1):
//   • Morre com 1 hit de qualquer arma/fonte → explode
//
// VERSÃO TANQUE (spawnflag 1 = KAMIKAZE_TANK):
//   • Player causa hits que contam; explode com 3
//   • NPCs causam metade do dano e não contam pro contador
//

void(entity attacker, float damage) kamikaze_pain =
{
    if (self.spawnflags & KAMIKAZE_TANK)
    {
        // dano de outros monstros: devolve metade (mais resistente)
        if (attacker && (attacker.flags & FL_MONSTER) && attacker.classname != "player")
        {
            self.health = self.health + (damage * 0.5);
            return;
        }

        self.kam_hits = self.kam_hits + 1;

        if (self.kam_hits >= 3)
            kamikaze_explode();

        return;
    }

    // versão padrão: qualquer hit explode
    if (attacker && attacker != world)
        self.enemy = attacker;
    kamikaze_explode();
};

void() kamikaze_die =
{
    kamikaze_explode();
};


// ------------------------ SPAWN ---------------------------

void() monster_kamikaze =
{
    precache_model("progs/kamikaze.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_model("progs/h_gib.mdl");
    precache_sound("kamikaze/scream.wav");

    self.movetype   = MOVETYPE_STEP;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;
    self.flags      = FL_MONSTER;

    setmodel(self, "progs/kamikaze.mdl");
    setsize(self, '-20 -20 -24', '20 20 40');

    self.th_stand = kamikaze_idle;
    self.th_walk  = kamikaze_walk;
    self.th_run   = kamikaze_walk;
    self.th_pain  = kamikaze_pain;
    self.th_die   = kamikaze_die;

    self.touch = kamikaze_touch;

    self.kam_hits       = 0;
    self.kam_nextscream = 0;
    self.classname      = "monster_kamikaze";
    self.frame          = KAMIKAZE_IDLE_FRAME;

    if (self.spawnflags & KAMIKAZE_TANK)
        self.health = 125;
    else
        self.health = 1;

    walkmonster_start();
};
