%% set up path


[~,computername] = system('hostname');
computername = strtrim(computername);

switch computername,
  
  case 'bransonk-lw1',
    
    addpath E:\Code\JCtrax\misc;
    addpath E:\Code\JCtrax\filehandling;
    addpath('E:\Code\SAGE\MATLABInterface\Trunk\')
    settingsdir = 'E:\Code\FlyBowlAnalysis\settings';
    rootdatadir = 'O:\Olympiad_Screen\fly_bowl\bowl_data';
  
  case 'bransonk-lw2',

    addpath C:\Code\JCtrax\misc;
    addpath C:\Code\JCtrax\filehandling;
    addpath('C:\Code\SAGE\MATLABInterface\Trunk\')
    settingsdir = 'C:\Code\FlyBowlAnalysis\settings';
    rootdatadir = 'O:\Olympiad_Screen\fly_bowl\bowl_data';
    
  case 'bransonk-desktop',
    
    addpath /groups/branson/home/bransonk/tracking/code/JCtrax/misc;
    addpath /groups/branson/home/bransonk/tracking/code/JCtrax/filehandling;
    addpath /groups/branson/bransonlab/projects/olympiad/SAGE/MATLABInterface/Trunk;
    settingsdir = '/groups/branson/bransonlab/projects/olympiad/FlyBowlAnalysis/settings';
    rootdatadir = '/groups/sciserv/flyolympiad/Olympiad_Screen/fly_bowl/bowl_data';

  otherwise
    
    warning('Unknown computer %s. Paths may not be setup correctly',computername);
    addpath C:\Code\JCtrax\misc;
    addpath C:\Code\JCtrax\filehandling;
    addpath('C:\Code\SAGE\MATLABInterface\Trunk\')
    settingsdir = 'C:\Code\FlyBowlAnalysis\settings';
    rootdatadir = 'O:\Olympiad_Screen\fly_bowl\bowl_data';
    
end

%% parameters

analysis_protocol = '20110804';

%% choose experiments

expdir = fullfile(rootdatadir,'pBDPGAL4U_TrpA_Rig1Plate10BowlA_20110714T110950');
data = SAGEListBowlExperiments('daterange',{'20110601T000000'},'automated_pf','F','checkflags',false,'removemissingdata',false,'rootdir',rootdatadir);

expdirs = {data.file_system_path};

%%

expnames = {'GMR_15D07_AE_01_TrpA_Rig1Plate01BowlC_20101021T105348',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlB_20101006T140250',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101012T114429',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101019T153205',...
'GMR_15C02_AE_01_TrpA_Rig1Plate01BowlA_20101012T140234',...
'GMR_16E09_AE_01_TrpA_Rig1Plate01BowlB_20101019T143858',...
'GMR_23E04_AE_01_TrpA_Rig1Plate01BowlA_20101013T105008',...
'GMR_14F08_AE_01_TrpA_Rig1Plate01BowlA_20101014T103007',...
'GMR_21A09_AE_01_TrpA_Rig1Plate01BowlB_20101006T102038',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101019T114311',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101012T145651',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlA_20101012T092212',...
'GMR_14D12_AE_01_TrpA_Rig1Plate01BowlB_20101020T110816',...
'GMR_14G03_AE_01_TrpA_Rig1Plate01BowlA_20101014T151007',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlD_20101020T095324',...
'GMR_17D12_AE_01_TrpA_Rig1Plate01BowlA_20101005T104552',...
'GMR_16F09_AE_01_TrpA_Rig1Plate01BowlD_20101019T134622',...
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlC_20101019T094835',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101013T130257',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlD_20101006T140618',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101013T132915',...
'GMR_14C05_AE_01_TrpA_Rig1Plate01BowlC_20101005T163350',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlC_20101019T101717',...
'GMR_15A04_AE_01_TrpA_Rig1Plate01BowlD_20101013T135558',...
'GMR_13F01_AE_01_TrpA_Rig1Plate01BowlD_20101020T092647',...
'GMR_15H08_AE_01_TrpA_Rig1Plate01BowlB_20101021T145135',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlB_20101012T092217',...
'GMR_14G07_AE_01_TrpA_Rig1Plate01BowlB_20101014T131331',...
'GMR_14A02_AE_01_TrpA_Rig1Plate01BowlD_20101006T143438',...
'GMR_17D11_AE_01_TrpA_Rig1Plate01BowlD_20101020T113208',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlB_20101021T111901',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlA_20101006T132910',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlB_20101006T143417',...
'GMR_16E09_AE_01_TrpA_Rig1Plate01BowlC_20101019T143828',...
'GMR_14F08_AE_01_TrpA_Rig1Plate01BowlD_20101014T102955',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlA_20101021T111856',...
'GMR_14F11_AE_01_TrpA_Rig1Plate01BowlD_20101014T153536',...
'GMR_15H08_AE_01_TrpA_Rig1Plate01BowlC_20101021T145102',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101020T141510',...
'GMR_14G07_AE_01_TrpA_Rig1Plate01BowlD_20101014T131317',...
'GMR_13F07_AE_01_TrpA_Rig1Plate01BowlB_20101019T111623',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101012T145655',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101013T111611',...
'GMR_17H07_AE_01_TrpA_Rig1Plate01BowlD_20101012T130525',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlC_20101007T110121',...
'GMR_12G05_AE_01_TrpA_Rig1Plate01BowlC_20101007T142434',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlD_20101005T144405',...
'GMR_15A04_AE_01_TrpA_Rig1Plate01BowlB_20101013T135558',...
'GMR_14C06_AE_01_TrpA_Rig1Plate01BowlA_20101012T095508',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101019T114325',...
'GMR_18C11_AE_01_TrpA_Rig1Plate01BowlC_20101013T102434',...
'GMR_35F12_AE_01_TrpA_Rig1Plate01BowlB_20101006T105158',...
'GMR_18H11_AE_01_TrpA_Rig1Plate01BowlA_20101019T104552',...
'GMR_20E03_AE_01_TrpA_Rig1Plate01BowlA_20101006T112328',...
'GMR_15B07_AE_01_TrpA_Rig1Plate01BowlC_20101012T142659',...
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlA_20101021T154139',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101013T132915',...
'GMR_15B07_AE_01_TrpA_Rig1Plate01BowlD_20101012T142704',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101013T130304',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlB_20101006T150945',...
'GMR_12G04_AE_01_TrpA_Rig1Plate01BowlC_20101007T152353',...
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlB_20101021T151730',...
'GMR_14A02_AE_01_TrpA_Rig1Plate01BowlC_20101006T143434',...
'GMR_14C03_AE_01_TrpA_Rig1Plate01BowlA_20101006T154117',...
'GMR_14C03_AE_01_TrpA_Rig1Plate01BowlC_20101006T153744',...
'GMR_15H12_AE_01_TrpA_Rig1Plate01BowlA_20101021T140025',...
'GMR_13F07_AE_01_TrpA_Rig1Plate01BowlD_20101019T111559',...
'GMR_15C11_AE_01_TrpA_Rig1Plate01BowlB_20101012T133249',...
'GMR_20A06_AE_01_TrpA_Rig1Plate01BowlC_20101014T100506',...
'GMR_13H04_AE_01_TrpA_Rig1Plate01BowlC_20101007T135231',...
'GMR_19F01_AE_01_TrpA_Rig1Plate01BowlA_20101021T091513',...
'GMR_14G08_AE_01_TrpA_Rig1Plate01BowlC_20101013T151418',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlB_20101006T153729',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101013T132910',...
'GMR_13F01_AE_01_TrpA_Rig1Plate01BowlA_20101020T092709',...
'GMR_14G06_AE_01_TrpA_Rig1Plate01BowlD_20101014T134813',...
'GMR_14C11_AE_01_TrpA_Rig1Plate01BowlB_20101005T150244',...
'GMR_26E01_AE_01_TrpA_Rig1Plate01BowlA_20101014T105510',...
'GMR_14F06_AE_01_TrpA_Rig1Plate01BowlA_20101012T102333',...
'GMR_14H01_AE_01_TrpA_Rig1Plate01BowlA_20101013T144840',...
'GMR_14F11_AE_01_TrpA_Rig1Plate01BowlB_20101014T153550',...
'GMR_14C05_AE_01_TrpA_Rig1Plate01BowlA_20101005T163327',...
'GMR_15D05_AE_01_TrpA_Rig1Plate01BowlD_20101021T142500',...
'GMR_14G05_AE_01_TrpA_Rig1Plate01BowlC_20101014T141451',...
'GMR_15H12_AE_01_TrpA_Rig1Plate01BowlD_20101021T140002',...
'GMR_16B05_AE_01_TrpA_Rig1Plate01BowlD_20101020T134043',...
'GMR_16B02_AE_01_TrpA_Rig1Plate01BowlA_20101021T131228',...
'GMR_14C03_AE_01_TrpA_Rig1Plate01BowlD_20101006T153743',...
'GMR_16F09_AE_01_TrpA_Rig1Plate01BowlB_20101019T134647',...
'GMR_15C06_AE_01_TrpA_Rig1Plate01BowlD_20101021T100447',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlB_20101006T132915',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101021T102923',...
'GMR_14G05_AE_01_TrpA_Rig1Plate01BowlD_20101014T141457',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlC_20101019T092128',...
'GMR_16G08_AE_01_TrpA_Rig1Plate01BowlC_20101019T131208',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlB_20101006T140459',...
'GMR_25H10_AE_01_TrpA_Rig1Plate01BowlA_20101012T111913',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101012T145652',...
'GMR_16E08_AE_01_TrpA_Rig1Plate01BowlC_20101019T141232',...
'GMR_15A04_AE_01_TrpA_Rig1Plate01BowlA_20101013T135552',...
'GMR_16B10_AE_01_TrpA_Rig1Plate01BowlA_20101020T144321',...
'GMR_16B10_AE_01_TrpA_Rig1Plate01BowlA_20101020T151129',...
'GMR_17F11_AE_01_TrpA_Rig1Plate01BowlD_20101020T104318',...
'GMR_20A06_AE_01_TrpA_Rig1Plate01BowlA_20101014T100518',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101021T133605',...
'GMR_12G04_AE_01_TrpA_Rig1Plate01BowlD_20101007T152359',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101005T153237',...
'GMR_16B05_AE_01_TrpA_Rig1Plate01BowlA_20101020T134105',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlD_20101007T113006',...
'GMR_14G03_AE_01_TrpA_Rig1Plate01BowlC_20101014T150952',...
'GMR_18C11_AE_01_TrpA_Rig1Plate01BowlD_20101013T102439',...
'GMR_16E02_AE_01_TrpA_Rig1Plate01BowlD_20101019T150656',...
'GMR_14F09_AE_01_TrpA_Rig1Plate01BowlC_20101012T152224',...
'GMR_12B01_AE_01_TrpA_Rig1Plate01BowlB_20101007T155133',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101005T113210',...
'GMR_13B06_AE_01_TrpA_Rig1Plate01BowlA_20101007T161822',...
'GMR_15C06_AE_01_TrpA_Rig1Plate01BowlA_20101021T100510',...
'GMR_19G01_AE_01_TrpA_Rig1Plate01BowlB_20101007T102720',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101013T130303',...
'GMR_15C11_AE_01_TrpA_Rig1Plate01BowlD_20101012T133252',...
'GMR_12G04_AE_01_TrpA_Rig1Plate01BowlA_20101007T152345',...
'GMR_14F11_AE_01_TrpA_Rig1Plate01BowlC_20101014T153530',...
'GMR_16C09_AE_01_TrpA_Rig1Plate01BowlB_20101020T153929',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101013T111610',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101019T153231',...
'GMR_15D07_AE_01_TrpA_Rig1Plate01BowlA_20101021T105417',...
'GMR_12B01_AE_01_TrpA_Rig1Plate01BowlA_20101007T155126',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101013T111612',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlB_20101007T110109',...
'GMR_14C06_AE_01_TrpA_Rig1Plate01BowlB_20101012T095515',...
'GMR_16C05_AE_01_TrpA_Rig1Plate01BowlD_20101020T151108',...
'GMR_15C11_AE_01_TrpA_Rig1Plate01BowlC_20101012T133246',...
'GMR_22A07_AE_01_TrpA_Rig1Plate01BowlD_20101014T093835',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlA_20101006T153727',...
'GMR_22A05_AE_01_TrpA_Rig1Plate01BowlA_20101012T105159',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101020T101812',...
'GMR_19G01_AE_01_TrpA_Rig1Plate01BowlD_20101007T102737',...
'GMR_14H09_AE_01_TrpA_Rig1Plate01BowlC_20101021T093923',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlB_20101014T112641',...
'GMR_13B06_AE_01_TrpA_Rig1Plate01BowlC_20101007T161829',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlA_20101007T112951',...
'GMR_14H09_AE_01_TrpA_Rig1Plate01BowlB_20101021T093955',...
'GMR_16B04_AE_01_TrpA_Rig1Plate01BowlB_20101020T131302',...
'GMR_17D12_AE_01_TrpA_Rig1Plate01BowlD_20101005T104123',...
'GMR_17D11_AE_01_TrpA_Rig1Plate01BowlA_20101020T113232',...
'GMR_14D12_AE_01_TrpA_Rig1Plate01BowlD_20101020T110749',...
'GMR_16F09_AE_01_TrpA_Rig1Plate01BowlA_20101019T134643',...
'GMR_21A09_AE_01_TrpA_Rig1Plate01BowlA_20101006T102034',...
'GMR_14G08_AE_01_TrpA_Rig1Plate01BowlB_20101013T151423',...
'GMR_14G06_AE_01_TrpA_Rig1Plate01BowlA_20101014T134821',...
'GMR_15D07_AE_01_TrpA_Rig1Plate01BowlD_20101021T105351',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101013T132910',...
'GMR_14G06_AE_01_TrpA_Rig1Plate01BowlC_20101014T134807',...
'GMR_15B07_AE_01_TrpA_Rig1Plate01BowlA_20101012T142657',...
'GMR_13H04_AE_01_TrpA_Rig1Plate01BowlA_20101007T135222',...
'GMR_16C05_AE_01_TrpA_Rig1Plate01BowlC_20101020T151102',...
'GMR_14E10_AE_01_TrpA_Rig1Plate01BowlD_20101005T133529',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101007T145600',...
'GMR_20E03_AE_01_TrpA_Rig1Plate01BowlC_20101006T112338',...
'GMR_16E08_AE_01_TrpA_Rig1Plate01BowlB_20101019T141300',...
'GMR_14G05_AE_01_TrpA_Rig1Plate01BowlB_20101014T141511',...
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlD_20101019T094840',...
'GMR_18H11_AE_01_TrpA_Rig1Plate01BowlB_20101019T104554',...
'GMR_14D05_AE_01_TrpA_Rig1Plate01BowlC_20101005T160331',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlA_20101019T092152',...
'GMR_14D05_AE_01_TrpA_Rig1Plate01BowlD_20101005T160343',...
'GMR_15A04_AE_01_TrpA_Rig1Plate01BowlC_20101013T135552',...
'GMR_22C11_AE_01_TrpA_Rig1Plate01BowlA_20101021T114403',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlC_20101014T112623',...
'GMR_16B04_AE_01_TrpA_Rig1Plate01BowlD_20101020T131236',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlA_20101019T101741',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101012T114424',...
'GMR_14H01_AE_01_TrpA_Rig1Plate01BowlC_20101013T144839',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101020T101842',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlC_20101020T095320',...
'GMR_14D12_AE_01_TrpA_Rig1Plate01BowlC_20101020T110747',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlB_20101020T095350',...
'GMR_14C05_AE_01_TrpA_Rig1Plate01BowlB_20101005T163332',...
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlD_20101021T154115',...
'GMR_14F06_AE_01_TrpA_Rig1Plate01BowlC_20101012T102337',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101012T145657',...
'GMR_16E08_AE_01_TrpA_Rig1Plate01BowlA_20101019T141257',...
'GMR_17F11_AE_01_TrpA_Rig1Plate01BowlB_20101020T104344',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlA_20101014T112638',...
'GMR_22C11_AE_01_TrpA_Rig1Plate01BowlB_20101021T114406',...
'GMR_19G01_AE_01_TrpA_Rig1Plate01BowlC_20101007T102733',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101014T144154',...
'GMR_17D12_AE_01_TrpA_Rig1Plate01BowlC_20101005T104121',...
'GMR_14A02_AE_01_TrpA_Rig1Plate01BowlA_20101006T143832',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlA_20101006T140452',...
'GMR_15D05_AE_01_TrpA_Rig1Plate01BowlB_20101021T142528',...
'GMR_16E02_AE_01_TrpA_Rig1Plate01BowlB_20101019T150721',...
'GMR_14G08_AE_01_TrpA_Rig1Plate01BowlA_20101013T151418',...
'GMR_12E07_AE_01_TrpA_Rig1Plate01BowlA_20101013T095913',...
'GMR_17D11_AE_01_TrpA_Rig1Plate01BowlC_20101020T113205',...
'GMR_20A06_AE_01_TrpA_Rig1Plate01BowlD_20101014T100510',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101007T145549',...
'GMR_14H01_AE_01_TrpA_Rig1Plate01BowlD_20101013T144844',...
'GMR_26E01_AE_01_TrpA_Rig1Plate01BowlB_20101014T105513',...
'GMR_14G05_AE_01_TrpA_Rig1Plate01BowlA_20101014T141506',...
'GMR_13F07_AE_01_TrpA_Rig1Plate01BowlC_20101019T111553',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101020T141505',...
'GMR_14C06_AE_01_TrpA_Rig1Plate01BowlC_20101012T095507',...
'GMR_14F09_AE_01_TrpA_Rig1Plate01BowlA_20101012T152223',...
'GMR_12G05_AE_01_TrpA_Rig1Plate01BowlA_20101007T142424',...
'GMR_21A09_AE_01_TrpA_Rig1Plate01BowlD_20101006T102438',...
'GMR_16E02_AE_01_TrpA_Rig1Plate01BowlC_20101019T150651',...
'GMR_20E03_AE_01_TrpA_Rig1Plate01BowlD_20101006T112343',...
'GMR_14H09_AE_01_TrpA_Rig1Plate01BowlD_20101021T093926',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101019T114334',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101014T144149',...
'GMR_35F12_AE_01_TrpA_Rig1Plate01BowlC_20101006T105217',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlD_20101006T140308',...
'GMR_20A06_AE_01_TrpA_Rig1Plate01BowlB_20101014T100524',...
'GMR_12E07_AE_01_TrpA_Rig1Plate01BowlB_20101013T095917',...
'GMR_12G05_AE_01_TrpA_Rig1Plate01BowlD_20101007T142443',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101012T114434',...
'GMR_16B02_AE_01_TrpA_Rig1Plate01BowlB_20101021T131233',...
'GMR_14G08_AE_01_TrpA_Rig1Plate01BowlD_20101013T151424',...
'GMR_14H07_AE_01_TrpA_Rig1Plate01BowlB_20101013T142234',...
'GMR_25H10_AE_01_TrpA_Rig1Plate01BowlC_20101012T111915',...
'GMR_15D05_AE_01_TrpA_Rig1Plate01BowlA_20101021T142523',...
'GMR_26E01_AE_01_TrpA_Rig1Plate01BowlD_20101014T105459',...
'GMR_15B07_AE_01_TrpA_Rig1Plate01BowlB_20101012T142702',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlA_20101005T142247',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlB_20101019T101748',...
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlC_20101021T151655',...
'GMR_15C02_AE_01_TrpA_Rig1Plate01BowlB_20101012T140237',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101020T101839',...
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlB_20101019T094903',...
'GMR_16B10_AE_01_TrpA_Rig1Plate01BowlD_20101020T144300',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101019T114306',...
'GMR_16C05_AE_01_TrpA_Rig1Plate01BowlB_20101020T151134',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlC_20101006T140304',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlD_20101007T110122',...
'GMR_19F01_AE_01_TrpA_Rig1Plate01BowlC_20101021T091443',...
'GMR_16H07_AE_01_TrpA_Rig1Plate01BowlB_20101012T130523',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlD_20101019T092135',...
'GMR_14D05_AE_01_TrpA_Rig1Plate01BowlB_20101005T160313',...
'GMR_14F09_AE_01_TrpA_Rig1Plate01BowlB_20101012T152226',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlD_20101021T111833',...
'GMR_13F07_AE_01_TrpA_Rig1Plate01BowlA_20101019T111618',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlD_20101005T142306',...
'GMR_16B04_AE_01_TrpA_Rig1Plate01BowlC_20101020T131230',...
'GMR_22A05_AE_01_TrpA_Rig1Plate01BowlB_20101012T105206',...
'GMR_22A05_AE_01_TrpA_Rig1Plate01BowlD_20101012T105210',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101005T153208',...
'GMR_12G05_AE_01_TrpA_Rig1Plate01BowlB_20101007T142435',...
'GMR_16E09_AE_01_TrpA_Rig1Plate01BowlD_20101019T143833',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlC_20101012T092214',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101007T145550',...
'GMR_19G01_AE_01_TrpA_Rig1Plate01BowlA_20101007T102717',...
'GMR_13B10_AE_01_TrpA_Rig1Plate01BowlA_20101007T131455',...
'GMR_16G08_AE_01_TrpA_Rig1Plate01BowlD_20101019T131211',...
'GMR_14E10_AE_01_TrpA_Rig1Plate01BowlA_20101005T133514',...
'GMR_12B01_AE_01_TrpA_Rig1Plate01BowlD_20101007T155143',...
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlC_20101021T154110',...
'GMR_15D05_AE_01_TrpA_Rig1Plate01BowlC_20101021T142454',...
'GMR_16E02_AE_01_TrpA_Rig1Plate01BowlA_20101019T150717',...
'GMR_15C06_AE_01_TrpA_Rig1Plate01BowlB_20101021T100515',...
'GMR_19F01_AE_01_TrpA_Rig1Plate01BowlD_20101021T091448',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlA_20101006T143411',...
'GMR_14F06_AE_01_TrpA_Rig1Plate01BowlD_20101012T102342',...
'GMR_14H07_AE_01_TrpA_Rig1Plate01BowlC_20101013T142226',...
'GMR_26E01_AE_01_TrpA_Rig1Plate01BowlC_20101014T105456',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlA_20101006T150943',...
'GMR_16G08_AE_01_TrpA_Rig1Plate01BowlB_20101019T131236',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlA_20101020T095347',...
'GMR_14C06_AE_01_TrpA_Rig1Plate01BowlD_20101012T095513',...
'GMR_13H04_AE_01_TrpA_Rig1Plate01BowlD_20101007T135242',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101020T141444',...
'GMR_14G03_AE_01_TrpA_Rig1Plate01BowlD_20101014T151001',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101014T144140',...
'GMR_13B10_AE_01_TrpA_Rig1Plate01BowlB_20101007T131459',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlD_20101005T144931',...
'GMR_17D12_AE_01_TrpA_Rig1Plate01BowlB_20101005T104554',...
'GMR_14H01_AE_01_TrpA_Rig1Plate01BowlB_20101013T144844',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101005T153234',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlD_20101006T151000',...
'GMR_17F11_AE_01_TrpA_Rig1Plate01BowlC_20101020T104314',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101021T102854',...
'GMR_35F12_AE_01_TrpA_Rig1Plate01BowlD_20101006T105213',...
'GMR_14C03_AE_01_TrpA_Rig1Plate01BowlB_20101006T154121',...
'GMR_14F08_AE_01_TrpA_Rig1Plate01BowlC_20101014T102952',...
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlD_20101021T151701',...
'GMR_14C11_AE_01_TrpA_Rig1Plate01BowlC_20101005T150302',...
'GMR_14D12_AE_01_TrpA_Rig1Plate01BowlA_20101020T110814',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlA_20101007T110106',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101021T133637',...
'GMR_14A06_AE_01_TrpA_Rig1Plate01BowlC_20101006T151005',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlD_20101014T112627',...
'GMR_15E07_AE_01_TrpA_Rig1Plate01BowlB_20101021T154143',...
'GMR_15C02_AE_01_TrpA_Rig1Plate01BowlC_20101012T140236',...
'GMR_16E09_AE_01_TrpA_Rig1Plate01BowlA_20101019T143854',...
'GMR_13F01_AE_01_TrpA_Rig1Plate01BowlB_20101020T092713',...
'GMR_16C09_AE_01_TrpA_Rig1Plate01BowlC_20101020T153858',...
'GMR_17H07_AE_01_TrpA_Rig1Plate01BowlC_20101012T130521',...
'GMR_16G08_AE_01_TrpA_Rig1Plate01BowlA_20101019T131232',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101019T153202',...
'GMR_22C11_AE_01_TrpA_Rig1Plate01BowlC_20101021T114334',...
'GMR_16B05_AE_01_TrpA_Rig1Plate01BowlC_20101020T134038',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101021T102851',...
'GMR_17D11_AE_01_TrpA_Rig1Plate01BowlB_20101020T113235',...
'GMR_18C11_AE_01_TrpA_Rig1Plate01BowlA_20101013T102434',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101013T130313',...
'GMR_14F06_AE_01_TrpA_Rig1Plate01BowlB_20101012T102339',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlC_20101006T132947',...
'GMR_14D05_AE_01_TrpA_Rig1Plate01BowlA_20101005T160309',...
'GMR_15C11_AE_01_TrpA_Rig1Plate01BowlA_20101012T133244',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlB_20101007T112955',...
'GMR_13B10_AE_01_TrpA_Rig1Plate01BowlD_20101007T131510',...
'GMR_14E10_AE_01_TrpA_Rig1Plate01BowlC_20101005T133528',...
'GMR_16B02_AE_01_TrpA_Rig1Plate01BowlD_20101021T131205',...
'GMR_20A02_AE_01_TrpA_Rig1Plate01BowlD_20101012T092222',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlC_20101007T113002',...
'GMR_21A09_AE_01_TrpA_Rig1Plate01BowlC_20101006T102431',...
'GMR_16B04_AE_01_TrpA_Rig1Plate01BowlA_20101020T131257',...
'GMR_25H10_AE_01_TrpA_Rig1Plate01BowlB_20101012T111919',...
'GMR_14F08_AE_01_TrpA_Rig1Plate01BowlB_20101014T103010',...
'GMR_16F09_AE_01_TrpA_Rig1Plate01BowlC_20101019T134619',...
'GMR_22A05_AE_01_TrpA_Rig1Plate01BowlC_20101012T105204',...
'GMR_13H04_AE_01_TrpA_Rig1Plate01BowlB_20101007T135233',...
'GMR_15H01_AE_01_TrpA_Rig1Plate01BowlD_20101019T101724',...
'GMR_22A07_AE_01_TrpA_Rig1Plate01BowlC_20101014T093831',...
'GMR_23E04_AE_01_TrpA_Rig1Plate01BowlD_20101013T105011',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101007T145542',...
'GMR_12E07_AE_01_TrpA_Rig1Plate01BowlC_20101013T095912',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101021T102920',...
'GMR_22C11_AE_01_TrpA_Rig1Plate01BowlD_20101021T114337',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101005T112738',...
'GMR_16B05_AE_01_TrpA_Rig1Plate01BowlB_20101020T134109',...
'GMR_16H07_AE_01_TrpA_Rig1Plate01BowlA_20101012T130519',...
'GMR_18H11_AE_01_TrpA_Rig1Plate01BowlC_20101019T104527',...
'GMR_14F09_AE_01_TrpA_Rig1Plate01BowlD_20101012T152227',...
'GMR_16B10_AE_01_TrpA_Rig1Plate01BowlC_20101020T144254',...
'GMR_14B02_AE_01_TrpA_Rig1Plate01BowlC_20101006T140613',...
'GMR_12E07_AE_01_TrpA_Rig1Plate01BowlD_20101013T095916',...
'GMR_35F12_AE_01_TrpA_Rig1Plate01BowlA_20101006T105155',...
'GMR_14G07_AE_01_TrpA_Rig1Plate01BowlA_20101014T131325',...
'GMR_14H09_AE_01_TrpA_Rig1Plate01BowlA_20101021T093952',...
'GMR_16C09_AE_01_TrpA_Rig1Plate01BowlA_20101020T153925',...
'GMR_14F11_AE_01_TrpA_Rig1Plate01BowlA_20101014T153545',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlC_20101005T144750',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101005T112740',...
'GMR_14G07_AE_01_TrpA_Rig1Plate01BowlC_20101014T131310',...
'GMR_14A02_AE_01_TrpA_Rig1Plate01BowlB_20101006T143840',...
'GMR_15C06_AE_01_TrpA_Rig1Plate01BowlC_20101021T100442',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlC_20101005T142303',...
'GMR_25H10_AE_01_TrpA_Rig1Plate01BowlD_20101012T111922',...
'GMR_18H11_AE_01_TrpA_Rig1Plate01BowlD_20101019T104533',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlD_20101006T132953',...
'GMR_17D02_AE_01_TrpA_Rig1Plate01BowlA_20101019T094858',...
'GMR_14B07_AE_01_TrpA_Rig1Plate01BowlA_20101006T140246',...
'GMR_15C02_AE_01_TrpA_Rig1Plate01BowlD_20101012T140239',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101005T113209',...
'GMR_42A08_AE_01_TrpA_Rig1Plate01BowlB_20101019T092157',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlD_20101005T144754',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101014T144135',...
'GMR_14G06_AE_01_TrpA_Rig1Plate01BowlB_20101014T134826',...
'GMR_14H07_AE_01_TrpA_Rig1Plate01BowlA_20101013T142230',...
'GMR_15G12_AE_01_TrpA_Rig1Plate01BowlA_20101021T151725',...
'GMR_15D07_AE_01_TrpA_Rig1Plate01BowlB_20101021T105420',...
'GMR_23E04_AE_01_TrpA_Rig1Plate01BowlC_20101013T105008',...
'GMR_16C09_AE_01_TrpA_Rig1Plate01BowlD_20101020T153904',...
'GMR_18C11_AE_01_TrpA_Rig1Plate01BowlB_20101013T102439',...
'GMR_16E08_AE_01_TrpA_Rig1Plate01BowlD_20101019T141236',...
'GMR_12G04_AE_01_TrpA_Rig1Plate01BowlB_20101007T152350',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101020T141438',...
'GMR_16B02_AE_01_TrpA_Rig1Plate01BowlC_20101021T131159',...
'GMR_15H12_AE_01_TrpA_Rig1Plate01BowlB_20101021T140030',...
'GMR_22D03_AE_01_TrpA_Rig1Plate01BowlC_20101021T111827',...
'GMR_19F01_AE_01_TrpA_Rig1Plate01BowlB_20101021T091516',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101020T101817',...
'GMR_13B06_AE_01_TrpA_Rig1Plate01BowlB_20101007T161827',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlB_20101013T111613',...
'GMR_13B10_AE_01_TrpA_Rig1Plate01BowlC_20101007T131507',...
'GMR_16B10_AE_01_TrpA_Rig1Plate01BowlB_20101020T144326',...
'GMR_22A07_AE_01_TrpA_Rig1Plate01BowlB_20101014T093849',...
'GMR_20E03_AE_01_TrpA_Rig1Plate01BowlB_20101006T112333',...
'GMR_12B01_AE_01_TrpA_Rig1Plate01BowlC_20101007T155134',...
'GMR_15H08_AE_01_TrpA_Rig1Plate01BowlD_20101021T145108',...
'GMR_14C05_AE_01_TrpA_Rig1Plate01BowlD_20101005T163355',...
'GMR_15H08_AE_01_TrpA_Rig1Plate01BowlA_20101021T145130',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlC_20101012T114426',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101005T153204',...
'GMR_14G03_AE_01_TrpA_Rig1Plate01BowlB_20101014T151010',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlA_20101019T153227',...
'GMR_22A07_AE_01_TrpA_Rig1Plate01BowlA_20101014T093844',...
'GMR_14E10_AE_01_TrpA_Rig1Plate01BowlB_20101005T133516',...
'pBDPGAL4U_TrpA_Rig1Plate01BowlD_20101021T133611',...
'GMR_15H12_AE_01_TrpA_Rig1Plate01BowlC_20101021T135957',...
'GMR_14C11_AE_01_TrpA_Rig1Plate01BowlD_20101005T150308',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlB_20101005T142250',...
'GMR_17F11_AE_01_TrpA_Rig1Plate01BowlA_20101020T104341',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlC_20101005T144402',...
'GMR_14C11_AE_01_TrpA_Rig1Plate01BowlA_20101005T150239',...
'GMR_14E05_AE_01_TrpA_Rig1Plate01BowlC_20101005T144930',...
'GMR_23E04_AE_01_TrpA_Rig1Plate01BowlB_20101013T105011',...
'GMR_13F01_AE_01_TrpA_Rig1Plate01BowlC_20101020T092643',...
'GMR_22C11_AE_01_TrpA_Rig1Plate10BowlD_20110203T142023',...
'GMR_21A11_AE_01_TrpA_Rig1Plate10BowlD_20110203T145323',...
'GMR_14A02_AE_01_TrpA_Rig1Plate10BowlD_20110204T094352',...
'GMR_35F12_AE_01_TrpA_Rig1Plate10BowlB_20110204T134357',...
'GMR_35F12_AE_01_TrpA_Rig1Plate10BowlA_20110204T134348',...
'pBDPGAL4U_TrpA_Rig1Plate10BowlC_20110204T091154',...
'GMR_42A08_AE_01_TrpA_Rig1Plate10BowlD_20110211T135624',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlA_20110211T113953',...
'pBDPGAL4U_TrpA_Rig1Plate10BowlD_20110217T095514',...
'pBDPGAL4U_TrpA_Rig1Plate13BowlA_20110217T113735',...
'pBDPGAL4U_TrpA_Rig1Plate12BowlD_20110217T110536',...
'pBDPGAL4U_TrpA_Rig1Plate13BowlC_20110217T113723',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlB_20110303T151229',...
'GMR_57F03_AD_01_TrpA_Rig1Plate10BowlC_20110303T150830',...
'GMR_60F01_AE_01_TrpA_Rig1Plate10BowlD_20110304T133339',...
'GMR_72H04_AE_01_TrpA_Rig2Plate14BowlD_20110317T092700',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlD_20110318T090425',...
'GMR_73F07_AE_01_TrpA_Rig2Plate14BowlA_20110318T093246',...
'GMR_73F07_AE_01_TrpA_Rig2Plate14BowlB_20110318T093249',...
'GMR_87D10_AE_01_TrpA_Rig2Plate14BowlA_20110323T145300',...
'pBDPGAL4U_TrpA_Rig1Plate10BowlD_20110330T084514',...
'GMR_65E11_AE_01_TrpA_Rig2Plate14BowlA_20110309T120340',...
'GMR_84B11_AE_01_TrpA_Rig2Plate14BowlD_20110324T105839',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlA_20110408T093806',...
'GMR_69F07_AE_01_TrpA_Rig2Plate14BowlA_20110408T114049',...
'GMR_56G08_AE_01_TrpA_Rig1Plate10BowlB_20110415T133735',...
'GMR_65A10_AE_01_TrpA_Rig1Plate10BowlC_20110415T092955',...
'GMR_77B08_AE_01_TrpA_Rig1Plate10BowlB_20110429T132808',...
'GMR_56H01_AE_01_TrpA_Rig1Plate10BowlD_20110505T154914',...
'GMR_50B06_AE_01_TrpA_Rig2Plate14BowlC_20110505T095839',...
'GMR_47D08_AE_01_TrpA_Rig2Plate14BowlC_20110504T111629',...
'GMR_50B06_AE_01_TrpA_Rig2Plate14BowlB_20110505T095800',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlD_20110506T152332',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlC_20110615T161808',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlD_20110624T092741',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlD_20110624T133716',...
'GMR_45F09_AE_01_TrpA_Rig2Plate14BowlD_20110624T140053',...
'GMR_22E07_AE_01_TrpA_Rig1Plate10BowlD_20110608T130454',...
'pBDPGAL4U_TrpA_Rig2Plate14BowlC_20110624T113420',...
'GMR_51G03_AE_01_TrpA_Rig2Plate14BowlD_20110629T134902',...
'GMR_48G01_AE_01_TrpA_Rig2Plate14BowlD_20110630T091402',...
'GMR_57G11_AD_01_TrpA_Rig1Plate10BowlA_20110701T160353',...
'GMR_65G11_AE_01_TrpA_Rig2Plate14BowlA_20110708T110216',...
'pBDPGAL4U_TrpA_Rig1Plate10BowlA_20110720T144927',...
'GMR_28D01_AE_01_TrpA_Rig2Plate14BowlC_20110615T131720',...
'GMR_13F07_AE_01_TrpA_Rig1Plate10BowlD_20110729T130112',...
'GMR_13F07_AE_01_TrpA_Rig1Plate10BowlB_20110729T130255',...
'GMR_11B03_AE_01_TrpA_Rig2Plate11BowlA_20110729T101725',...
'GMR_13F07_AE_01_TrpA_Rig1Plate10BowlA_20110729T130258',...
'GMR_18B10_AE_01_TrpA_Rig2Plate17BowlC_20110803T164337',...
'GMR_14H11_AE_01_TrpA_Rig1Plate15BowlA_20110803T110345',...
'GMR_14H11_AE_01_TrpA_Rig1Plate15BowlB_20110803T110335',...
'GMR_14F03_AE_01_TrpA_Rig2Plate17BowlA_20110803T092216',...
'GMR_18H10_AE_01_TrpA_Rig1Plate15BowlB_20110804T150419',...
'GMR_18H10_AE_01_TrpA_Rig1Plate15BowlD_20110804T150323',...
'GMR_16F08_AE_01_TrpA_Rig1Plate15BowlD_20110805T094536',...
'GMR_16F08_AE_01_TrpA_Rig1Plate15BowlA_20110805T094625',...
'pBDPGAL4U_TrpA_Rig1Plate15BowlB_20110810T142102',...
'GMR_20F02_AE_01_TrpA_Rig2Plate17BowlA_20110811T094737',...
'GMR_22C04_AE_01_TrpA_Rig2Plate17BowlC_20110810T150256',...
'GMR_22G08_AE_01_TrpA_Rig1Plate15BowlD_20110811T141345',...
'GMR_22G11_AE_01_TrpA_Rig2Plate17BowlD_20110811T142645',...
'GMR_22G11_AE_01_TrpA_Rig2Plate17BowlC_20110811T142650',...
'GMR_24B03_AE_01_TrpA_Rig1Plate15BowlA_20110812T152719',...
'pBDPGAL4U_TrpA_Rig1Plate15BowlC_20110805T092134',...
'pBDPGAL4U_TrpA_Rig1Plate15BowlD_20110811T091311',...
'pBDPGAL4U_TrpA_Rig2Plate17BowlC_20110815T113912',...
'GMR_16H04_AE_01_TrpA_Rig2Plate17BowlC_20110805T104316',...
'GMR_19F02_AE_01_TrpA_Rig2Plate17BowlC_20110805T131334',...
'GMR_16F05_AE_01_TrpA_Rig2Plate17BowlC_20110805T092931',...
'pBDPGAL4U_TrpA_Rig2Plate17BowlC_20110805T154200',...
'GMR_19G08_AE_01_TrpA_Rig2Plate17BowlC_20110805T143843',...
'GMR_21E09_AE_01_TrpA_Rig2Plate17BowlC_20110812T101216',...
'GMR_50H05_AE_01_TrpA_Rig1Plate15BowlD_20110815T104531',...
'GMR_50H05_AE_01_CTRL_CantonS_1101243_0016_Rig1Plate15BowlD_20110815T115636',...
'GMR_24G01_AE_01_TrpA_Rig2Plate17BowlA_20110817T095920',...
'GMR_26F09_AE_01_TrpA_Rig2Plate17BowlC_20110817T133222',...
'GMR_24G01_AE_01_TrpA_Rig2Plate17BowlD_20110817T100301',...
'GMR_26F09_AE_01_TrpA_Rig2Plate17BowlA_20110817T132852',...
'GMR_28C04_AE_01_TrpA_Rig1Plate15BowlB_20110818T142109',...
'GMR_27E07_AE_01_TrpA_Rig2Plate17BowlA_20110818T130532',...
'GMR_28A07_AE_01_TrpA_Rig2Plate17BowlC_20110818T141745',...
'GMR_28C04_AE_01_TrpA_Rig1Plate15BowlA_20110818T142105',...
'GMR_28C04_AE_01_TrpA_Rig1Plate15BowlD_20110818T141933',...
'GMR_25C02_AE_01_TrpA_Rig2Plate17BowlA_20110818T091842',...
'GMR_29A07_AE_01_TrpA_Rig2Plate17BowlA_20110819T132944',...
'GMR_26D10_AE_01_TrpA_Rig2Plate17BowlA_20110819T112938',...
'GMR_25H08_AE_01_TrpA_Rig1Plate15BowlD_20110819T092712',...
'GMR_31B09_AE_01_TrpA_Rig2Plate17BowlA_20110825T101911',...
'GMR_35A01_AE_01_TrpA_Rig1Plate15BowlC_20110826T131622',...
'GMR_32B08_AE_01_TrpA_Rig2Plate17BowlA_20110826T104150',...
'GMR_39D07_AE_01_TrpA_Rig2Plate17BowlC_20110831T133322',...
'pBDPGAL4U_TrpA_Rig1Plate15BowlC_20110901T090508',...
'GMR_40F04_AE_01_TrpA_Rig1Plate15BowlC_20110901T135602',...
'GMR_40F04_AE_01_TrpA_Rig1Plate15BowlB_20110901T135733',...
'GMR_40C07_AE_01_TrpA_Rig1Plate15BowlD_20110916T103920',...
'GMR_82E08_AE_01_TrpA_Rig1Plate15BowlB_20110921T105940',...
'GMR_82E08_AE_01_TrpA_Rig1Plate15BowlC_20110921T110415',...
'GMR_46C04_AE_01_TrpA_Rig1Plate15BowlA_20110922T134254',...
'GMR_48A07_AE_01_TrpA_Rig2Plate17BowlA_20110928T092804',...
'GMR_50E12_AE_01_TrpA_Rig2Plate17BowlD_20110928T134357',...
'GMR_49F09_AE_01_TrpA_Rig2Plate17BowlB_20110930T092453',...
'GMR_55B03_AE_01_TrpA_Rig2Plate17BowlD_20111006T084731',...
'GMR_61C09_AD_01_TrpA_Rig2Plate17BowlD_20111006T153722',...
'pBDPGAL4U_TrpA_Rig2Plate17BowlA_20111007T100215',...
'pBDPGAL4U_TrpA_Rig2Plate17BowlC_20111007T140348'};

expdirs = cell(size(expnames));
for i = 1:numel(expnames),
  expdirs{i} = fullfile(rootdatadir,expnames{i});
end

%%

success = [];
msg = {};
iserror = {};
success_c = [];
msg_c = {};
iserror_c = {};

datalocparamsfile = fullfile(settingsdir,analysis_protocol,'dataloc_params.txt');
dataloc_params = ReadParams(datalocparamsfile);

errors_seen = [];
errors_seen_c = [];
for i = 1:numel(expdirs),
  expdir = expdirs{i};
  %disp(data(i).experiment_name);
  [~,expname] = fileparts(expdir);
  disp(expname);
  [success(i),msg{i},iserror{i}] = FlyBowlAutomaticChecks_Incoming(expdir,'settingsdir',settingsdir,'analysis_protocol',analysis_protocol,'debug',true);

  automatedchecksincomingfile = fullfile(expdir,dataloc_params.automaticchecksincomingresultsfilestr);
  automatedchecks_incoming = ReadParams(automatedchecksincomingfile);
  disp(automatedchecks_incoming);

  if ~success(i),
    if any(~ismember(find(iserror{i},1),errors_seen)),
      input('');
      errors_seen = union(errors_seen,find(iserror{i},1));
    end
  end
%   [success_c(i),msg_c{i},iserror_c{i}] = FlyBowlAutomaticChecks_Complete(expdir,'settingsdir',settingsdir,'analysis_protocol',analysis_protocol,'debug',true);
%   if ~success_c(i),
%     if any(~ismember(find(iserror_c{i},1),errors_seen_c)),
%       input('');
%       errors_seen_c = union(errors_seen_c,find(iserror_c{i},1));
%     end
%   end
end