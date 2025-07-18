File
{
**** INPUT FILES
Grid = "@tdr@"
Parameter = "@parameter@"

**** OUTPUT FILES
Plot = "n@node@_des.tdr"
Current = "n@node@_des.plt"
}

Electrode {
{ Name="n_contact_1" Voltage=0 eRecVelocity = 1.0000e+07  hRecVelocity = 1.0000e+07}
{ Name="ground_contact" Resist=1e9 Voltage=@V_Start@ eRecVelocity = 1.0000e+07  hRecVelocity = 1.0000e+07}
}

Physics{
 Fermi
  EffectiveIntrinsicDensity(Slotboom)


   Mobility(
   * CarrierCarrierScattering
      DopingDependence
	 
     * PhuMob
      HighFieldSaturation( GradQuasiFermi )
      Enormal
   )
   

   
   Recombination(
      SRH( DopingDependence )
      SurfaceSRH
     * Auger
     * Avalanche(Okuto)
    *    Band2Band(E2)
    Avalanche( Eparallel )
   )           
}  

Plot {
eDensity hDensity   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector eLifetime hLifetime
eDriftVelocity/Vector hDriftVelocity/Vector 
 AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
  eIonIntegral hIonIntegral MeanIonIntegral eAlphaAvalanche hAlphaAvalanche
Potential SpaceCharge ElectricField/Vector
eMobility hMobility eVelocity/Vector hVelocity/Vector
Doping DonorConcentration AcceptorConcentration
InsulatorElectricField 
SurfaceRecombination
}

Math {
Wallclock
ParallelLicense (Wait)
Number_of_Threads = 8
Extrapolate
RelErrControl
NotDamped=50
Iterations=30

}


Solve {
  
  Coupled (Iterations=100) { Poisson }
  Coupled { Poisson Electron Hole }

  NewCurrent = "REV___"

  Quasistationary (
    Goal { Name = "ground_contact" Voltage = @V_Stop@ }
  )
  {
    Coupled { Poisson Electron Hole }
    Plot (Time = (0; 0.05; 0.1; 0.15; 0.25; 0.5; 0.75; 1.0) NoOverwrite)
  }

}


