Matlab code repository for:

Defining the temporal structure of REM sleep: A minute-scale fluctuation across brain and body in mice and humans

Lezio S. Bueno-Junior 1, Maxwell S. Ruckstuhl 1, Miranda M. Lim 1,2, Brendon O. Watson 1

1 Department of Psychiatry, University of Michigan Medical School, Ann Arbor, MI 48109, USA
2 Veterans Affairs Portland Health Care System, Portland, OR 97239, USA
3 Department of Neurology, Oregon Health and Science University, Portland, OR 97239, USA

Major dependencies:
	- buzcode (https://github.com/buzsakilab/buzcode)
	- DeepLabCut (Nath et al., 2019)
	- edfread.m

Below is the list of key functions sorted by processing steps and the corresponding figures in the paper. This list is not exhaustive and does not reproduce the figure subplots.

Preprocessing and Figure 1C-D
	- /Preproc/REM_EphysPreproc.m
	- /Preproc/REM_VideoEpoching.m
	- /Preproc/REM_DLCcoordsSingleEpoch.m
	- /Preproc/read_Intan_RHD2000_file_MOD_LB.m
	- /Preproc/REM_TstampsFromDigitalin.m
	- /Preproc/REM_EpisodeTrimmer.m
	- /Helpers/REM_InterpToNewLength.m
	- /Helpers/REM_FigEdits.m
	- /Helpers/REM_ColorbarEdits.m

Figure 2
	- /Preproc/REM_EpisodeTrimmer.m
	- /FacialMov/REM_EyeDataSingleEpoch.m
	- /FacialMov/REM_WhiskerDataSingleEpoch.m
	- /SpectrDistr/REM_DistrHist.m
	- /Wrappers/REM_EpochLoop.m
	- /Wrappers/REM_SessionLoopForEpochs.m
	- /Helpers/REM_JointZscNorm.m
	- HartigansDipSignifTest.m (external: Mechler, 2002)

Figure 3
	- /SpectrDistr/REM_WavelSpectr.m
	- /SpectrDistr/REM_ThetaFreqAndPower.m
	- /SpectrDistr/REM_InfraslowPSD.m
	- /Helpers/REM_JointZscNorm.m
	- /SpectrDistr/REM_DistrHist.m
	- /Wrappers/REM_EpochLoop.m
	- /Wrappers/REM_SessionLoopForEpochs.m
	- fitrm, ranova, multcompare (Matlab)
	- HartigansDipSignifTest.m (external: Mechler, 2002)

Figure 4
	- /Wrappers/REM_EpochLoop.m
	- /Wrappers/REM_SessionLoopForEpochs.m
	- /Helpers/REM_InterpToNewLength.m
	- corrcoef (Matlab)
	- /FacialMov/REM_GMMclustering3D.m
	- fitrm, ranova, multcompare (Matlab)
	- /Phase/REM_InfraslowPhase.m
	- /Phase/REM_FacialMovPhasePref.m
	- /Phase/REM_PhasePrefNormalization.m
	- CircStat toolbox (external: Berens, 2009)

Figure 5
	- /Phase/REM_CoarseInfraslowPhase.m
	- /CFC/REM_CFCmap.m
	- /CFC/REM_CFCsummValues.m
	- /CFC/REM_MultiChannelMultiEpochCFC.m
	- /Wrappers/REM_SessionLoopForCFC.m
	- Kilosort2 (Stringer et al., 2019)
	- phy (https://github.com/cortex-lab/phy/)
	- bz_GetSpikes.m (https://github.com/buzsakilab/buzcode)
	- /Phase/REM_MultiChnSpkPhase.m
	- /Phase/REM_MultiChnSpkCirc.m
	- /Wrappers/REM_SpkRatesPerInfraslowPhase.m
	- CircStat toolbox (external: Berens, 2009)

Figure 6 (does not include algorithmic staging of human sleep, as we used existing epochs from a polysomnography technician)
	- /Preproc/REM_HumanEDFtoLFP.m
	- /Helpers/REM_InterpToNewLength.m
	- /SpectrDistr/REM_WavelSpectr.m
	- /SpectrDistr/REM_HumanPhysiolRate.m
	- /FacialMov/REM_HumanEOGamplit.m
	- /SpectrDistr/REM_DistrHist.m
	- /SpectrDistr/REM_InfraslowPSD.m
	- /Helpers/REM_JointZscNorm.m
	- fitrm, ranova, multcompare (Matlab)
	- HartigansDipSignifTest.m (external: Mechler, 2002)
	- /Phase/REM_InfraslowPhase.m
	- /Phase/REM_FacialMovPhasePref.m
	- /Phase/REM_PhasePrefNormalization.m
	- CircStat toolbox (external: Berens, 2009)
	
