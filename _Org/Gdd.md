# Enemy Types

| Working-Title | walking | destroyed by jump | destroyed by shot | misc                                              |
| ------------- | ------- | ----------------- | ----------------- | ------------------------------------------------- |
| Normal guy    | x       | x                 | x                 | -                                                 |
| Fall guy      | -       | -                 | x                 | stucked until detection, falling down             |
| Bounce guy    | x       | -                 | x                 | stepping on this guy will push the player upwards |
| Shooting guy  | -       | x                 | -                 | shooting periodically                             |

## Normal Guy

Just the normal type of enemy. Can harm the player by collision. Can be destroyed by jump and slap.

![](enemy1.png)

## Fall Guy

Static enemy until the player or ghost enters detection range. Then falls from ceiling. Dealing damage on collision.
Could be slapped.

![](enemy2.png)

## Bounce Guy

Touching this one will result in pushing the player upwards - maybe in spikes ;)

![](enemy3.png)

## Shooting Guy

This guy is shooting a projectile on a specific frequency.

![](enemy3.png)

# Required sounds

- [ ] Button Click
- [x] Beam sound
- [x] Jump / Landing?
- [x] Shoot Player
- [x] Checkpoint reached
- [x] portal idle / close
- [x] Hit sound
- [ ] Hit Enemy sound
- [x] Shoot ShootGuy
- [ ] Pop Bounceguy
- [ ] Fallguy
- [ ] Player Hurt
- [ ] Dialogue Popup
- [x] Dialogue letter
- [ ] door open / close
- [x] COIN
- [x] ammo

# Music

Super Secret Tune - Lesser than three (menu?)
Dont be a bitch remix
delicious keys

Highway Slaughter - Cor Metallicum
