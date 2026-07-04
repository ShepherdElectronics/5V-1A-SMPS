# Build guide

Source file: `Build guide.docx`

## Extracted Text

Isolation Transformer Bench BoxDetailed Build Guide

Rebuilt revision 2

Purpose. This document is for boxing your existing mains isolation transformer into a permanent bench tool for powering offline prototypes. Exact manufacturer part numbers are used wherever they are available from your uploaded Digi-Key paperwork.

1. Exact parts list for this build

Known exact parts.

Required exact parts

Function | Manufacturer | Mfr Part Number | Distributor / Order ID | Build note
IEC mains inlet | Qualtek | 701W-X2/02 | Q207-ND | Panel-mount IEC C14 inlet for AC input.
Line fuse | Littelfuse | 0313.500HXP | F2538-ND | 0.5 A, 250 VAC, 3AB/3AG glass fuse.
Inline fuse holder | Littelfuse | 01500322HXF | 18-01500322HXF-ND | Use only if your enclosure layout needs an inline holder instead of a panel holder.
AC power cord | Qualtek | 211011-01 | Q941-ND | 6 ft NEMA 5-15P power cord.
Protective-earth ring lug | Panduit | P10-6R-D | 298-15104-ND | Use for the chassis earth bond to a machine screw and lock washer.
Isolation Transformer | Triad N-68X | N-68X | N-68X | Isolation Transformer

Optional exact parts you can include

Function | Manufacturer | Mfr Part Number | Distributor / Order ID | Build note
18–22 AWG crimp splice | 3M | 94785 | 94785-01-ND | Useful for insulated internal splices.
14–16 AWG crimp splice | 3M | 94788 | 94788-01-ND | Use if your transformer leads are heavier.
MOV, 175 VAC class | Panasonic | ERZ-V14D271 | P7220-ND | Line-to-neutral surge absorber for 120 VAC service.
MOV, 250 VAC class | Panasonic | ERZ-V14D391 | P7266-ND | Only use instead of the 271 part if you intentionally chose the higher-voltage MOV option.
Inrush limiter | Cantherm | MF72-005D9 | 317-1158-ND | 5 Ω cold resistance, 3 A; conservative NTC option.
Inrush limiter, larger | Cantherm | MF72-005D11 | 317-1177-ND | 5 Ω cold resistance, 4 A; use only if your transformer startup current needs it.
X-capacitor | KEMET | PME271MB6100KR30 | 399-7489-ND | 0.1 µF, 275 VAC, across line and neutral.
Y-capacitor | Murata | DE6E3KJ222MA4B | 490-DE6E3KJ222MA4B-ND | Usually omit for a fully floating output box; do not add from isolated output to earth.

2. User-supplied items still required

Plastic enclosure sized for the transformer, inlet, switch, and output binding posts.

One mains-rated power switch (if used).

Two insulated banana binding posts for the floating isolated output.

One earth/ground binding post if you want a front-panel PE reference point bonded to chassis only.

Hook-up wire, heat-shrink, machine screws, lock washers, panel labels, and strain relief as needed.

3. Functional requirements for the finished box

The isolated output must remain floating. Neither secondary lead is tied to chassis earth.

The hot conductor must be fused and switched before the transformer primary.

Protective earth from the IEC inlet must bond to any exposed conductive chassis hardware and optionally to a dedicated PE binding post.

Primary wiring and secondary wiring must be physically separated inside the enclosure.

All mains wiring must be fully insulated and strain relieved.

4. Wiring architecture

PRIMARY SIDE (mains referenced)IEC inlet hot (L)  -> fuse -> switch -> transformer primary lead AIEC inlet neutral (N) -> transformer primary lead BIEC inlet earth (PE) -> ring lug -> chassis bond -> optional PE front postSECONDARY SIDE (floating)transformer secondary lead 1 -> banana post OUT Atransformer secondary lead 2 -> banana post OUT BIMPORTANTDo not bond either secondary lead to PE or to the enclosure.

5. Recommended panel layout

Rear panel: IEC inlet, fuse access if applicable, and any strain relief. Keep all mains-entry hardware together.

Front panel: Power switch, isolated output banana posts, and optional PE binding post.

Internal placement: Put the transformer as low and centered as practical. Keep primary leads on one side of the box and secondary leads on the opposite side. Cross only at right angles if unavoidable.

6. Build procedure

Step 1 – Mark and cut the enclosure

Measure the transformer footprint first. Dry fit it inside the plastic enclosure and verify that the lid closes without pinching wires.

Mark the IEC inlet opening from the actual Qualtek 701W-X2/02 body, not from a guessed rectangle. File slowly until the inlet fits cleanly.

Mark the switch cutout and the three front-panel posts: OUT A, OUT B, and optional PE.

Deburr every cut edge. Plastic burrs can cut insulation over time.

Step 2 – Mount the transformer

Bolt the transformer down firmly. If its laminations or frame can contact conductive hardware, add insulating shoulder washers or sheet as needed.

Orient the leads so the primary side naturally routes toward the IEC inlet and the secondary side naturally routes toward the banana posts.

Do not rely on epoxy alone as the structural mount for the transformer. Use mechanical fasteners wherever possible.

Step 3 – Install the inlet, switch, and posts

Install the Qualtek 701W-X2/02 IEC inlet.

Install the mains switch.

Install the two insulated banana posts for the floating output.

Install the PE post only if you want a front-panel chassis/earth reference. This post is not one side of the output.

Step 4 – Make the protective-earth bond first

Run a green wire from the IEC earth terminal to a dedicated chassis bonding screw using the Panduit P10-6R-D ring lug.

Use a machine screw, external-tooth lock washer, flat washer, and nut. In a metal enclosure, bond to bare metal. In a plastic enclosure, bond the PE post and any exposed metal hardware together without touching the floating secondary.

Keep this earth bond short, direct, and mechanically secure. This is the most important safety connection in the box.

Step 5 – Wire the primary

Route IEC hot (L) to the fuse, then from the fuse to the power switch, then from the switch to one primary lead of the transformer.

Route IEC neutral (N) directly to the other primary lead.

Insulate every exposed mains connection with heat-shrink or insulated terminals.

Twist the hot and neutral primary wires together loosely to keep the wiring neat and reduce loop area.

Step 6 – Add optional line-entry parts if desired (DON’T)

If you want surge suppression, wire the Panasonic ERZ-V14D271 MOV across line and neutral after the inlet. Use the ERZ-V14D391 only if you intentionally chose that higher-voltage option instead.

If you want lower turn-on surge, place the MF72-005D9 or MF72-005D11 NTC in series with the hot path before the transformer primary.

If you want a basic EMI line shunt, place the KEMET PME271MB6100KR30 0.1 µF X-cap across line and neutral.

Do not add a Y-cap from output to earth if your goal is a truly floating isolated output for bench debug.

Step 7 – Wire the secondary

Connect one secondary lead directly to isolated banana post OUT A.

Connect the other secondary lead directly to isolated banana post OUT B.

Do not connect either secondary lead to the chassis, the PE post, or the IEC earth terminal.

If your transformer has multiple secondaries or taps, clearly label the exact output voltage and which pair is used.

Step 8 – Dress and secure the wiring

Bundle primary wiring separately from secondary wiring. Do not run them in the same bundle.

Use adhesive tie mounts or screw mounts to keep wires from moving into sharp edges or hot surfaces.

Leave enough service loop to remove the lid later, but not so much that wires can flop into the wrong section.

Step 9 – Label the front and rear panels

Minimum labels recommended: AC INPUT 120 VAC; ISOLATED OUTPUT – FLOATING; NOT FOR PERSONNEL PROTECTION; PE / CHASSIS EARTH for the earth post only.

Step 10 – Unpowered verification before first energization

Check continuity from IEC earth to the chassis bond and to the PE post.

Check that there is no continuity from either output banana post to earth.

Check that there is no direct continuity from primary leads to secondary leads.

Verify that the switch opens the hot path, not the neutral path.

Verify that line and neutral are not shorted.

Step 11 – First power-up

Insert the correct fuse: Littelfuse 0313.500HXP unless your transformer requires a different value based on measured current and nameplate data.

Power the box with no load connected.

Measure the output AC voltage across OUT A and OUT B.

Measure from OUT A to earth and from OUT B to earth. Each side may show stray capacitive voltage on a high-impedance meter, but there should not be a hard earth bond.

Listen and smell for abnormal hum, overheating, or insulation issues.

Step 12 – Loaded verification

Connect a modest resistive load, not your best prototype first.

Confirm the secondary voltage stays in the expected range under load.

Allow the transformer to run long enough to verify temperature rise is reasonable.

Only after this should you use the box for offline SMPS bench debugging.

7. Exact connection map

From | To | Use exact part if known | Notes
IEC earth pin | Chassis bond screw | Panduit P10-6R-D ring lug | Shortest and most secure connection in the box.
Chassis bond screw | Optional front PE post | User-supplied wire / hardware | PE post is chassis earth only.
IEC line / hot | Fuse input | Littelfuse 0313.500HXP | Fuse the hot leg.
Fuse output | Power switch input | User-supplied switch | Keep insulated.
Power switch output | Transformer primary lead A | User-supplied wire | Mains referenced.
IEC neutral | Transformer primary lead B | User-supplied wire | Do not switch the neutral instead of hot.
Transformer secondary lead 1 | OUT A banana post | User-supplied binding post | Floating output.
Transformer secondary lead 2 | OUT B banana post | User-supplied binding post | Floating output.

8. What not to do

Do not bond one side of the isolated output to earth unless you intentionally want to lose the floating-output benefit.

Do not use the Y-capacitor from either isolated output terminal to earth for this application if your goal is floating bench debug.

Do not rely on glue alone for transformer mounting, mains terminations, or strain relief.

Do not place primary and secondary conductors under the same heat-shrink sleeve or tie bundle.

Do not assume the 0.5 A fuse is always correct if your transformer’s measured inrush or steady-state current says otherwise.

9. Commissioning checklist

Check item | Pass / Fail | Notes
Earth bond secure and low resistance | ☐ Pass   ☐ Fail | 
No continuity from OUT A to earth | ☐ Pass   ☐ Fail | 
No continuity from OUT B to earth | ☐ Pass   ☐ Fail | 
Switch interrupts hot conductor | ☐ Pass   ☐ Fail | 
Fuse installed in hot path | ☐ Pass   ☐ Fail | 
Primary and secondary physically separated | ☐ Pass   ☐ Fail | 
No exposed mains metal | ☐ Pass   ☐ Fail | 
No abnormal no-load hum or heat | ☐ Pass   ☐ Fail | 
Correct AC voltage at OUT A / OUT B | ☐ Pass   ☐ Fail | 

Final note. This guide uses exact part numbers only where the uploaded paperwork actually identified them. The enclosure, switch, transformer model, and output binding posts were not identified by exact part number in the uploaded files, so they remain user-supplied by necessity.

