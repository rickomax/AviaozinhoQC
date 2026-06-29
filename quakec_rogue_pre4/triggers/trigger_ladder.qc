/*
===============================================================================
trigger_ladder
===============================================================================
*/

void() ladder_touch =
{
    if (other.classname != "player")
        return;

    // if the trigger has an angles field, check player's facing direction
    if (self.movedir != '0 0 0')
    {
        makevectors (other.angles);
        if (v_forward * self.movedir < 0)
            return;        // not facing the right way
    }
    other.on_ladder = 1;
    other.gravity = 0.0000001; //zero doesnt seem to work
}

/*QUAKED trigger_ladder (.5 .5 .5) ?
invisible ladder entity. when player is touching this entity, he can climb by pushing 'jump'

Keys:

"angle" the direction player must be facing to climb ladder
*/
void() trigger_ladder =
{
    InitTrigger ();
    self.touch = ladder_touch;
};