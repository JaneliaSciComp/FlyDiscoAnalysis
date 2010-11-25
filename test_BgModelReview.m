addpath /groups/branson/bransonlab/projects/JCtrax/misc/;
addpath /groups/branson/bransonlab/projects/JCtrax/filehandling/;

rootdir = '/groups/branson/home/bransonk/tracking/data/drive_flyolympiad/Olympiad_Screen/fly_bowl/bowl_data';
expdirs = {
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlA_20101021T154139'
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlB_20101021T154143'
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlC_20101021T154110'
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlD_20101021T154115'
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlA_20101021T151725'
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlB_20101021T151730'
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlC_20101021T151655'
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlD_20101021T151701'
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlA_20101019T094858'
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlB_20101019T094903'
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlC_20101019T094835'
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlD_20101019T094840'
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlA_20101019T092152'
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlB_20101019T092157'
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlC_20101019T092128'
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlD_20101019T092135'
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101019T114325'
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101019T153227'
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101021T102920'
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101021T133637'
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101019T114334'
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101019T153231'
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101020T141510'
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101021T102923'
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101019T114306'
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101019T153202'
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101021T102851'
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101021T133605'
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101019T114311'
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101019T153205'
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101021T102854'
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101021T133611'
}';
BgModelReview(expdirs,'rootdir',rootdir);