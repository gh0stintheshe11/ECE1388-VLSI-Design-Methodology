[ ==README.jaro.quickstart_IC6 - jaro - April 2018 ]
[ Note that some of these instructions might be outdated as they were
  mostly taken from the IC5 version of the "quickstart" file. ]

This document is a quick summary of how to perform some 
of the basic tasks required during design.  

- create a work directory; protect it; changedir to it:
	mkdir $HOME/CRN65GP
	chmod go-rwx $HOME/CRN65GP
	cd $HOME/CRN65GP

- start the IC tools
	source /CMC/tools/CSHRCs/Cadence.IC617
	startCds -t ic6-crn65gp
  This will copy a few files and make symbolic links to
  a few directories if they don't already exist, including
	cds.lib
	display.drf
	assura_tech.lib
	models/
	Assura/
	Calibre/
  It will also copy a sample ".cdsinit" to your workdir, for 
  easlier loading of process corners and for Mentor Calibre set-up

- if you need to convert your IC5 libraries to IC6, review
	/CMC/doc/IC5-to-IC6
  (I'm still working on a few issues in this docuemnt for tsmc_65nm.)

- If you want to use standard cell and I/O libraries, add these four lines 
  to the file "cds.lib":

	DEFINE tcbn65gplus    /CMC/kits/tsmc_65nm_libs/OA_libs/tcbn65gplus/tcbn65gplus_200a/TSMCHOME/digital/Back_End/cdk_OA/tcbn65gplus
	DEFINE tpan65gpgv2od3 /CMC/kits/tsmc_65nm_libs/OA_libs/tpan65gpgv2od3/tpan65gpgv2od3_200b/TSMCHOME/digital/Back_End/cdk_OA/tpan65gpgv2od3
	DEFINE tpbn65v        /CMC/kits/tsmc_65nm_libs/OA_libs/tpbn65v/tpbn65v_200b/TSMCHOME/digital/Back_End/cdk_OA/tpbn65v
	DEFINE tpfn65gpgv2od3 /CMC/kits/tsmc_65nm_libs/OA_libs/tpfn65gpgv2od3/tpfn65gpgv2od3_200c/TSMCHOME/digital/Back_End/cdk_OA/tpfn65gpgv2od3

- create a design library; attach it to the library "tsmcN65"
- create your schematic testbench, using devices from the tsmcN65
  library if they exist; otherwise you should be able to use devices
  from "analogLib".  (Don't forget to place a "gnd" symbol.)
- [optional] create a config view for simulation
- start Tools=>AnalogEnvironment ("AE")
  - default simulator is spectre; if you want to use hspice, use
  	Setup=>Simulator/Directory/Host...
    and select "hspiceD" as the simulator
  - you should not need to set up model files; these should be
    set up automagically for you
- If you want to use process corners:
  If you ever used STM design-kits, their initialization will have
  created a directory named "menus" in your home directory.  (This is
  how STM creates their special "Artist=>Tools=>*SetupCorners..." menu
  items.) Unfortunately, when they do this, it messes up the menus for
  other technology design sessions.  Remove that directory by typing
  at a terminal window (very carefully)
	cd $HOME ; rm -rf menus
  Open your design; open Artist; use Artist=>Tools=>Corners...
  You should see the corners and all of the files.

- In layouts: 
  - For layout pins to be transferred properly to verification
    tools, each pin must have its name attached in the same pin layer; to 
    do this, you can
    - select the appropriate pin layer in the LSW
    - create pin, type the terminal name, turn on "Display Pin Name",
      click "Display Pin Name Option...", and beside
      "Layer", select the pin layer, with layer-purpose "pin" (or,
      click the box "use pin layer"), click OK.
    - in the layout window, place the pin and then place its name
      with its origin somewhere on the pin
    Now, in verification tools (e.g. Calibre-LVS), this pin will be
    netlisted as a port, and can be used to compare with schematic pins.
  - you might want to set your drawing grid to 0.01-micron

- Verification: This kit does *not* use the Cadence "diva" verification
  tools; instead, it supposedly supports Mentor/Calibre and Cadence/Assura
  for verification.
  - Calibre DRC
  - Calibre LVS
  - Calibre PEX (parasisitc extraction, using Calibre-xRC)
  - Assura RCX
  Rather than force you to figure out all of the options, I set up some
  basic "runsets" for each of the Calibre tools.  When you load these
  runsets, please poke through all of the settings and verify that they
  do what you want (and not what I think you want).

- Calibre-DRC:
  - open a layout, select Calibre=>RunDRC...
  - when prompted to load a runset,
    - navigate to Calibre/drc/=drc.runset_jaro
    - verify settings
    - run DRC
  - there are two other runsets you must use, to check
    antenna DRC (Calibre/drc/=drc_antenna.runset_jaro) and
    antenna_mim DRC (Calibre/drc/=drc_antenna_mim.runset_jaro)

- Calibre-LVS
  - open a layout, select Calibre=>RunLVS...
  - when prompted to load a runset,
    - navigate to Calibre/lvs/=lvs.runset_jaro
    - verify settings
    - run LVS

- Calibre-PEX
  - open a layout, select Calibre=>RunPEX...
  - when prompted to load a runset,
    - navigate to Calibre/rcx/=rcx.runset_jaro
    - verify settings
    - run PEX
    - when prompted to convert to "calview", examine the options and click OK
  This will create a "calibre" cellview for your layout, which will include
  parasitics.  This should be usable in simulations, but I have not tested
  that (yet).  Have a look at the documents under PDK/Calibre/
  for additional details on viewing parasitics using Calibre/RVE

- Assura-RCX: untested.  Feel free to play with this;
  some files are available under /CMC/kits/tsmc65nm/CRN65GP/PDK/Assura/
  If you can make it work, I would be happy to collect your experiences
  and publish them here, giving due credit

- DRC rules: A quick summary of the Calibre DRC rules used is available
  at /CMC/kits/cmos65nm/==README.jaro.calibredrc_summary.CRN65GP
  which was generated using
	cd /CMC/kits/tsmc65nm/CRN65LP/PDK/Calibre/drc
	grep '{ @' calibre.drc > ==README.jaro.calibredrc_summary
  Please be discreet with any hardcopy, as some of this info could
  be sensitive.  (No guarantees that it holds all of the rules, but
  it looks complete to me.)
  Let me know if you find something missing...)

- Monte Carlo simulations: I think we've got this figured out now.
  Here's what (we think) we know:
  Monte Carlo sims can be run for mismatch, or process variation,
  or both.

  For "Process-Only" Monte Carlo siumulations:
  - under ADE=>Setup=ModelLibraries...
    - enable sections "stat" for process variations, then
    - enable and "mc" and disable the corner section "tt"
      (or for other devices, enable "mc_xxx" and disable "tt_xxx")
  - select ADE=>Tools=>MonteCarlo...
    - select number of runs
    - set "Analysis Variation" to "Process Only"
    - turn on "Save data between runs"
    - select Simulation=>Run
    - when complete, you should see a family of plots

  Monte Carlo sims for mismatch require that you use "macro"
  versions of the devices, so instead of using "nch" or "pch",
  you use "nch_mac" and "pch_mac" devices. (I don't see equivalents
  for RF devices, though; not sure what to do for those.)
  This is a pain for circuits with lots of devices, but I can't
  see any other way. So... here's what I did:

  Say I have an inverter schematic and layout; they pass LVS.
  I copy "inverter/schematic" to a new cellview,
  "inverter/schematic_mac", and replace all the "pch" with "pch_mac",
  and all the "nch" with "nch_mac".  (I wonder if I can run
  LVS using the "_mac" versions of the devices?  No time to check
  that right now...)
  
  For simulations, I create a config view, and I can swap between
  the "schematic" and "schematic_mac" views, depending on which I
  want to simulate: "schematic" for normal sims, and "schematic_mac"
  for mismatch Monte Carlo sims.
  
  Now, in ADE, to run "mismatch-only" Monte Carlo simulations
  - under ADE=>Setup=>ModelLibraries...
    - add and enable "stat_mis"
    - enable your corner of choice, say "tt"
  - select ADE=>Tools=>MonteCarlo...
    - select number of runs
    - set "Analysis Variation" to "Process only"
    - turn on "Save data between runs"
    - select Simulation=>Run...
    - when complete, you should see a family of plots

Review this file occasionally ... I'll keep adding to it.  -- jaro
