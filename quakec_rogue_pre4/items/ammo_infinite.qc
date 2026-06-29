/*
================================================================================
    ammo_infinite.qc  –  Spawn de munição infinita (não some ao ser tocado)

    Uso no editor (TrenchBroom / JACK / etc.):
        item_shells         spawnflag bit 2  (valor 4) → "infinite"
        item_spikes         spawnflag bit 2  (valor 4) → "infinite"
        item_rockets        spawnflag bit 2  (valor 4) → "infinite"
        item_lava_spikes    spawnflag bit 2  (valor 4) → "infinite"
        item_multi_rockets  spawnflag bit 2  (valor 4) → "infinite"
        item_cells          spawnflag bit 2  (valor 4) → "infinite"

    Quando "infinite" está ativo:
      - O modelo nunca desaparece.
      - Nenhum cooldown por jogador  (pode re-pegar imediatamente se não
        estiver no cap – comportamento tipo corredor).
      - Em single-player funciona igual a deathmatch: reaparece na hora.

    WEAPON_BIG2  = 1  (já definido em items.qc – big box)
    AMMO_INFINITE = 4  ← novo flag definido aqui

    O .fgd já tem os dois flags originais; basta adicionar a linha:
        4 : "Infinite (never disappears)"
    nas entidades de ammo. Exemplo no fim deste arquivo (comentário FGD).
================================================================================
*/

// ---------------------------------------------------------------------------
// Constante de flag  (bit 2 → valor 4; bits 0 e 1 já são usados por WEAPON_BIG2
// e pelo flag "Dropped" interno do engine)
// ---------------------------------------------------------------------------
float AMMO_INFINITE = 4;

// ---------------------------------------------------------------------------
// ammo_infinite_touch
//
// Substitui ammo_touch quando AMMO_INFINITE está ativo na entidade.
// Dá a munição, toca o som, mas NUNCA remove o modelo nem seta solid=NOT.
// ---------------------------------------------------------------------------
void() ammo_infinite_touch =
{
    local entity  stemp;
    local float   best;

    if (other.classname != "player")
        return;
    if (other.health <= 0)
        return;

    // --- mesma lógica de weapon upgrade de ammo_touch ---
    stemp = self;
    self  = other;
    best  = W_BestWeapon();
    self  = stemp;

    // shotgun shells
    if (self.weapon == 1)
    {
        if (other.ammo_shells1 >= 200)
            return;
        other.ammo_shells1 = other.ammo_shells1 + self.aflag;
    }

    // nails / spikes
    if (self.weapon == 2)
    {
        if (other.ammo_nails1 >= 335)
            return;
        other.ammo_nails1 = other.ammo_nails1 + self.aflag;
    }

    // rockets
    if (self.weapon == 3)
    {
        if (other.ammo_rockets1 >= 100)
            return;
        other.ammo_rockets1 = other.ammo_rockets1 + self.aflag;
    }

    // cells
    if (self.weapon == 4)
    {
        if (other.ammo_cells1 >= 100)
            return;
        other.ammo_cells1 = other.ammo_cells1 + self.aflag;
    }

    // lava nails
    if (self.weapon == 5)
    {
        if (other.ammo_lava_nails >= 200)
            return;
        other.ammo_lava_nails = other.ammo_lava_nails + self.aflag;
    }

    // multi rockets
    if (self.weapon == 6)
    {
        if (other.ammo_multi_rockets >= 100)
            return;
        other.ammo_multi_rockets = other.ammo_multi_rockets + self.aflag;
    }

    // plasma / cells-alt
    if (self.weapon == 7)
    {
        if (other.ammo_plasma >= 100)
            return;
        other.ammo_plasma = other.ammo_plasma + self.aflag;
    }

    EnableComboWeapons(other);
    UpdateAmmoCounts(other);
    bound_other_ammo();

    sprint(other, "$qc_got_item");
    sprint(other, self.netname);
    sprint(other, "\n");

    sound(other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
    stuffcmd(other, "bf\n");

    // troca de arma se necessário
    if (other.weapon == best && (W_WantsToChangeWeapon(other, 0, 1) == 1))
    {
        stemp = self;
        self  = other;
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        self = stemp;
    }

    stemp = self;
    self  = other;
    W_SetCurrentAmmo();
    self = stemp;

    // ---------------------------------------------------------------
    // NÃO remove modelo / NÃO seta SOLID_NOT  ← diferença principal
    // O item continua visível e coletável imediatamente.
    // ---------------------------------------------------------------

    activator = other;
    SUB_UseTargets();
};

// ---------------------------------------------------------------------------
// Ammo_SetInfiniteTouch
//
// Chamada pelos spawners de ammo logo depois de definir self.touch.
// Se o flag AMMO_INFINITE estiver ativo, substitui o touch pela versão
// infinita.
// ---------------------------------------------------------------------------
void() Ammo_SetInfiniteTouch =
{
    if (self.spawnflags & AMMO_INFINITE)
        self.touch = ammo_infinite_touch;
};

/*
================================================================================
FGD snippet – adicione estas linhas dentro de cada entidade de ammo no seu .fgd
para que o TrenchBroom / JACK mostre o checkbox "Infinite":

Exemplo para item_shells:
@PointClass size(0 0 0, 32 32 56) color(0 128 204) model({{ spawnflags & 1 -> "maps/b_shell1.bsp", "maps/b_shell0.bsp" }}) = item_shells : "Shotgun Shells"
[
    spawnflags(flags) =
    [
        1 : "Big box (40 shells)" : 0
        4 : "Infinite (never disappears)" : 0
    ]
]

Repita para item_spikes, item_rockets, item_lava_spikes,
item_multi_rockets, item_cells — apenas mude o nome e a descrição.
================================================================================
*/
