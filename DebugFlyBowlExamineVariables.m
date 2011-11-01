%% set up paths

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

analysis_protocol = '20111005';
vartype = 'experiment';
dataset = 'score';
% period = 2;
% loadcacheddata = true;
% datafilename = 'DataCurationSheets/ExperimentData_20110409to20110416.mat';
% username = 'bransonk';

%% which experiments

% d = now;
% format = 'yyyymmddTHHMMSS';
% maxdatenum = d - min_days_prev;
% mindatenum = d - max_days_prev;
% mindatestr = datestr(mindatenum,format);
% maxdatestr = datestr(maxdatenum,format);

% maxdatestr = '20111021T000000'
% period = 120

params = {'settingsdir',settingsdir,...
  'analysis_protocol',analysis_protocol,...
  'rootdatadir',rootdatadir,...
  'dataset',dataset,...
  'checkflags',true,...
  'screen_type','primary'};
%   'maxdatenum',datenum(maxdatestr,format),...
%   'period',period,...
%   'loadcacheddata',loadcacheddata,...
%   'datafilename',datafilename,...
%   'username',username};
%   'plotgroup','set',...

%% 

[handles,data] = FlyBowlExamineVariables(vartype,params{:});
