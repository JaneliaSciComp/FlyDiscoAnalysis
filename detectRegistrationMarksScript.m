[expdirs,expdir_reads,expdir_writes,experiments,rootreaddir,rootwritedir] = ...
  getExperimentDirs('protocol','RegistrationTest20110125');
movieFileStr = 'movie.ufmf';
annFileStr = 'movie.ufmf.ann';
params = {...
  'bkgdNSampleFrames',10,...
  'method','circle',...
  'circleImageType','canny',...
  'circleRLim',[.475,.51],...
  'circleXLim',[.475,.525],...
  'circleYLim',[.475,.525],...
  'circleImageThresh',1,...
  'circleCannyThresh',[.15,.25],...
  'circleCannySigma',1,...
  'circleNXTry',50,...
  'circleNYTry',50,...
  'circleNRTry',50,...
  'circleRadius_mm',127/2,...
  'maxDistCornerFrac_BowlLabel',.175,...
  'featureRadius',11,...
  'pairDist_mm',133,...
  'bowlMarkerPairTheta_true',-3*pi/4,...
  'debug',true,...
  'nr',1024,'nc',1024};

% diameter in mm: 127

%%

clear registrationData;

for i = 1:length(expdirs),
  movieName = fullfile(expdir_reads{i},movieFileStr);
  annName = fullfile(expdir_reads{i},annFileStr);
  %if ~exist(annName,'file'),
  %  fprintf('Ann file %s does not exist, skipping.\n',annName);
  %  continue;
  %end
  registrationData(i) = detectRegistrationMarks('movieName',movieName,params{:});
  input(strrep(sprintf('movie %s: ',movieName),'\','\\'));
end