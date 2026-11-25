# Aerial Robotics – Lab 3: Crazyflie

Positions- och höjdreglering av en Crazyflie-drönare med Vicon-återkoppling, byggd i Simulink och flugen i den fysiska labben.
Drönaren flyger tre banor (Task 3): en **fyrkant**, en **cirkel** och en **cirkel lutad 45°**.

---

## Regulatorn

Drönarens egen firmware sköter attityden. Ovanpå den ligger en förenklad kaskadreglering i Simulink (`export_ros2_template.slx`, ROS 2):

| Styr | Regulator | Formel |
|---|---|---|
| Höjd → thrust | PD + feedforward | `T = T0·(1 + 0.42·(z* − z) − 0.35·ż)` |
| x/y → pitch | P på positionsfel + hastighetsdämpning | `pitch = 0.3·(e_x − v_x)` |
| x/y → roll | P på positionsfel + hastighetsdämpning | `roll = −0.4·(e_y − v_y)` |
| Riktning → yaw rate | P | `yaw_rate = 0.2·atan2(sin(ψ* − ψ), cos(ψ* − ψ))` |

Positionsfelet räknas i drönarens egen ram. Både drönarens position och referensen roteras med `rot2(ψ)ᵀ`:

```
[e_x; e_y] = rot2(ψ)ᵀ · [x* − x; y* − y]
           = [ cosψ·(x* − x) + sinψ·(y* − y);
              −sinψ·(x* − x) + cosψ·(y* − y)]
```

`v_x` och `v_y` är hastigheten från odometrin. Minustecknet på roll ligger i publishern (Gain −1), eftersom positiv roll lutar drönaren mot −y.

**Begränsningar och enheter**
- Thrust: `T` begränsas till 0–1 och skickas som `T · 60000` PWM. Med `T0 = 0.71` blir svävthrusten ungefär 42 600 PWM.
- Pitch och roll: ±1 rad, yaw rate: ±1 rad/s. Alla tre görs om från radianer till grader i publishern.
- Höjdreferensen går via en NödSwitch, en Rate Limiter (±0.2 m/s) och en begränsning till 0–1.8 m, vilket ger mjuk start och nödlandning.

---

## Resultat – Task 3

Röd streckad linje = referens, blå linje = uppmätt bana (Vicon).

### Fyrkant

<table>
  <tr>
    <td align="center"><img src="v2/davidochgustav/Fyrkant_plot.jpg" width="420"><br><sub>Bana i XY-planet</sub></td>
    <td align="center"><img src="v2/davidochgustav/fyrkant_3d.png" width="420"><br><sub>Bana i 3D – lyft, fyrkant på 1 m höjd, landning</sub></td>
  </tr>
</table>

### Cirkel

<table>
  <tr>
    <td align="center"><img src="v2/davidochgustav/Cirkel_plot.jpg" width="420"><br><sub>Bana i XY-planet</sub></td>
    <td align="center"><img src="v2/davidochgustav/cirkel_3d.png" width="420"><br><sub>Bana i 3D</sub></td>
  </tr>
</table>

### Lutad cirkel (45°)

<table>
  <tr>
    <td align="center"><img src="v2/davidochgustav/lutad.jpg" width="420"><br><sub>Bana i XY-planet – uppifrån blir den lutade cirkeln en ellips</sub></td>
    <td align="center"><img src="v2/davidochgustav/lutad_3d.png" width="420"><br><sub>Bana i 3D – cirkeln lutad 45°</sub></td>
  </tr>
</table>

---

## Filer

Allt ligger i `v2/davidochgustav/`.

| Fil | Innehåll |
|---|---|
| `export_lab12.slx` | Modell för Task 1–2 (sväva och flyga till punkter) |
| `export_lab3.slx`, `task3.slx` | Modell för Task 3 (följer en referensbana) |
| `fyrkant_task3.slx`, `Cirkel_task3.slx` | Modellerna som användes för respektive bana |
| `export_parameter_test.slx` | Test för att hitta svävthrusten T0 |
| `task3_physical.m`, `export_task3.m` | Bygger referensbanorna och plottar resultatet |
| `plot_lab12.m`, `task3plot.m` | Plottskript |
| `fyrkant.mat`, `cirkel.mat`, `lutad.mat` | Loggad data från flygningarna |

### Köra en bana

1. Läs av drönarens startposition från Vicon och skriv in `x0`, `y0`, `yaw0` i banskriptet.
2. Välj `bana` (`'fyrkant'`, `'cirkel'` eller `'lutad'`) och kör sektion 1.
3. Kör Simulink-modellen, slå upp StartSwitch och NödSwitch.
4. När drönaren har landat: stoppa och kör sektion 2 för att plotta.
