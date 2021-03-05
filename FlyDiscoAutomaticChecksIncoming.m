function [success,msgs,iserror] = FlyDiscoAutomaticChecksIncoming(expdir,varargin)

version = '0.2.1';

success = true;
msgs = {};

datetime_format = 'yyyymmddTHHMMSS';

[analysis_protocol,settingsdir,datalocparamsfilestr,DEBUG,min_barcode_expdatestr,logfid] = ...
  myparse(varargin,...
  'analysis_protocol','current_bubble',...
  'settingsdir','/groups/branson/home/robiea/Code_versioned/FlyBubbleAnalysis/settings',...
  'datalocparamsfilestr','dataloc_params.txt',...
  'debug',false,...
  'min_barcode_expdatestr','20110301T000000',...
  'logfid',[]);
min_barcode_expdatenum = datenum(min_barcode_expdatestr,datetime_format);

%% parameters
datalocparamsfile = fullfile(settingsdir,analysis_protocol,datalocparamsfilestr);
dataloc_params = ReadParams(datalocparamsfile);

% %%
% logger = PipelineLogger(expdir,mfilename(),dataloc_params,...
%   'automaticchecks_incoming_logfilestr',settingsdir,analysis_protocol,...
%   'logfid',logfid,'debug',DEBUG,'versionstr',version);

try
paramsfile = fullfile(settingsdir,analysis_protocol,dataloc_params.automaticchecksincomingparamsfilestr);
check_params = ReadParams(paramsfile);
if ~iscell(check_params.control_line_names),
  check_params.control_line_names = {check_params.control_line_names};
end
metadatafile = fullfile(expdir,dataloc_params.metadatafilestr);
moviefile = fullfile(expdir,dataloc_params.moviefilestr);
protocolfile = fullfile(expdir,dataloc_params.ledprotocolfilestr);
temperaturefile = fullfile(expdir,dataloc_params.temperaturefilestr); %#ok<NASGU>
outfile = fullfile(expdir,dataloc_params.automaticchecksincomingresultsfilestr);

% order matters here: higher up categories have higher priority
categories = {'flag_aborted_set_to_1',...
  'missing_video',...
  'missing_metadata_file',...
  'missing_metadata_fields',...
  'short_video',...
  'bad_video_timestamps',...
  'missing_capture_files',...
  'flag_redo_set_to_1',...
  'fliesloaded_time_too_short',...
  'fliesloaded_time_too_long',...
  'shiftflytemp_time_too_long',...
  'no_barcode',...
  'incoming_checks_other'};
category2idx = struct;
for i = 1:numel(categories),
  category2idx.(categories{i}) = i;
end
iserror = false(1,numel(categories));

%% check for notstarted
[~,expname] = fileparts(expdir);
if ~isempty(regexp(expname,'notstarted','once')),
  iserror(category2idx.missing_video) = true;
  success = false;
  msgs{end+1} = 'Capture not started';
end

%% read metadata

ismetadata = exist(metadatafile,'file');
if ~ismetadata,
  success = false;
  msgs{end+1} = 'Missing Metadata.xml file';
  iserror(category2idx.missing_metadata_file) = true;
  metadata = struct;
else
  try
    metadata = ReadMetadataFile(metadatafile);
  catch %#ok<CTCH>
    msgs{end+1} = 'Error reading Metadata file';
    success = false;
  end
end
  

%% check for metadata fields

required_fns = {'flag_aborted','flag_redo','seconds_fliesloaded','seconds_shiftflytemp',...
  'screen_type','line','cross_barcode'};
if isfield(check_params,'required_fns'),
  required_fns = check_params.required_fns;
end
ismissingfn = ~ismember(required_fns,fieldnames(metadata));
if any(ismissingfn),
  success = false;
  msgs{end+1} = ['Missing metadata fields:',sprintf(' %s',required_fns{ismissingfn})];
  iserror(category2idx.missing_metadata_fields) = true;
end

%% check for flags

if isfield(metadata,'flag_aborted') && metadata.flag_aborted ~= 0,
  success = false;
  msgs{end+1} = 'Experiment aborted.';
  iserror(category2idx.flag_aborted_set_to_1) = true;
end

if isfield(metadata,'flag_redo') && metadata.flag_redo ~= 0,
  success = false;
  msgs{end+1} = 'Redo flag set to 1.';
  iserror(category2idx.flag_redo_set_to_1) = true;
end

%% check loading time

if isfield(metadata,'seconds_fliesloaded'),
  if metadata.seconds_fliesloaded < check_params.min_seconds_fliesloaded,
    success = false;
    msgs{end+1} = sprintf('Load time = %f < %f seconds.',metadata.seconds_fliesloaded,check_params.min_seconds_fliesloaded);
    iserror(category2idx.fliesloaded_time_too_short) = true;
  end
  if metadata.seconds_fliesloaded > check_params.max_seconds_fliesloaded,
    success = false;
    msgs{end+1} = sprintf('Load time = %f > %f seconds.',metadata.seconds_fliesloaded,check_params.max_seconds_fliesloaded);
    iserror(category2idx.fliesloaded_time_too_long) = true;
  end
end

%% check shiftflytemp time
% if isfield(metadata,'seconds_shiftlytemp') && ...
%     metadata.seconds_shiftflytemp > check_params.max_seconds_shiftflytemp,
%   success = false;
%   msgs{end+1} = sprintf('Shift fly temp time = %f > %f seconds.',metadata.seconds_shiftflytemp,check_params.max_seconds_shiftflytemp);
%   iserror(category2idx.shiftflytemp_time_too_long) = true;
% end

%% check for primary screen: all other checks are only for screen data

if ~isfield(metadata,'screen_type'),
  % should already be captured in missing metadata fields
%   success = false;
%   msgs{end+1} = 'screen_type not stored in Metadata file';
  isscreen = false;
else
  isscreen = strcmpi(metadata.screen_type,'non_olympiad_branson_cx');
end

%% check barcode

if isfield(metadata,'exp_datetime') && ~isempty(metadata.exp_datetime) ,
  exp_datenum = datenum(metadata.exp_datetime,datetime_format);
else
  exp_datenum = nan;
end


%% check video length

headerinfo = [];
if exist(moviefile,'file'),
  try
    headerinfo = ufmf_read_header(moviefile);
    if ~isfield(headerinfo,'nframes'),
      error('No field nframes in UFMF header');
    end
    nframes = headerinfo.nframes;
     if exist(protocolfile,'file')
      protocolinfo = load(protocolfile);
      if ~isfield(protocolinfo.protocol,'duration')
        error('No duration field in protocol file')
      end
      exptime = sum(protocolinfo.protocol.duration)/1000;
      expframes = exptime/(1/check_params.frame_rate);
      min_frames = expframes - (expframes*.05); % some buffer in short movie length
      if nframes < min_frames,
        success = false;
        msgs{end+1} = sprintf('Video contains %d < %d frames.',nframes,check_params.min_ufmf_diagnostics_summary_nframes);
        iserror(category2idx.short_video) = true;
      end
     elseif nframes < check_params.min_ufmf_diagnostics_summary_nframes,
      success = false;
      msgs{end+1} = sprintf('Video contains %d < %d frames.',nframes,check_params.min_ufmf_diagnostics_summary_nframes);
      iserror(category2idx.short_video) = true;
    end
  catch ME,
    success = false;
    msgs{end+1} = sprintf('Error reading nframes from movie header: %s',getReport(ME,'extended','hyperlinks','off'));
    iserror(category2idx.incoming_checks_other) = true;    
  end
end

%% check for bad timestamps

if ~isempty(headerinfo),

  if ~isfield(headerinfo,'timestamps'),
    msgs{end+1} = 'No field timestamps in UFMF header';
    success = false;
    iserror(category2idx.incoming_checks_other) = true;    
  else
    dt = diff(headerinfo.timestamps);
    nneg = nnz(dt <= 0);
    if nneg > 0,
      success = false;
      msgs{end+1} = sprintf('%d frames in movie with non-increasing timestamps',nneg);
      iserror(category2idx.bad_video_timestamps) = true;
    end
  end
  
end

%%

if isscreen,

%exp_datenum = datenum(metadata.exp_datetime,datetime_format);
  
if (~ismember(metadata.line,check_params.control_line_names) || ...
    (exp_datenum >= min_barcode_expdatenum)) && ...
    metadata.cross_barcode < 0,
  success = false;
  msgs{end+1} = 'Barcode = -1 and line_name indicates not control';
  iserror(category2idx.no_barcode) = true;
end

%% check temperature
% 
% if ~exist(temperaturefile,'file'),
%   warning('Temperature file %s does not exist',temperaturefile);
% else
%   try
%     tempdata = importdata(temperaturefile,',');
%   catch ME,
%     warning('Error importing temperature stream: %s',getReport(ME));
%   end
%   if isempty(tempdata),
%     warning('No temperature readings recorded.');
%     temp = [];
%   elseif size(tempdata,2) < 2,
%     warning('Temperature data could not be read');
%     temp = [];
%   else
%     temp = tempdata(:,2);
%     if isempty(temp),
%       warning('No temperature readings recorded.');
%     else
%       if max(temp) > check_params.max_temp,
%         success = false;
%         msgs{end+1} = sprintf('Max temperature = %f > %f.',max(temp),check_params.max_temp);
%       end
%       if numel(temp) < 2,
%         warning('Only one temperature recorded.');
%       else
%         if max(temp) - min(temp) > check_params.max_tempdiff,
%           success = false;
%           msgs{end+1} = sprintf('Temperature change = %f > %f.',max(temp) - min(temp),check_params.max_tempdiff);
%         end
%       end
%     end
%   end
% end

end

%% check for missing files

fn = dataloc_params.moviefilestr;
isfile = exist(fullfile(expdir,fn),'file');
if ~isfile,
  iserror(category2idx.missing_video) = true;
end
if isfield(check_params,'required_files_mindatestr'),
  mindatenum = nan(size(check_params.required_files_mindatestr));
  for i = 1:numel(check_params.required_files_mindatestr),
    if ~isempty(check_params.required_files_mindatestr{i}),
      mindatenum(i) = datenum(check_params.required_files_mindatestr{i},datetime_format);
    end
  end
else
  mindatenum = [];
end

for i = 1:numel(check_params.required_files),
  if i <= numel(mindatenum) && ~isnan(mindatenum(i)) && ...
      (isnan(exp_datenum) || exp_datenum < mindatenum(i)),
    continue;
  end
  fn = check_params.required_files{i};
  if any(fn == '*'),
    isfile = ~isempty(dir(fullfile(expdir,fn)));
  else
    isfile = exist(fullfile(expdir,fn),'file');
  end
  if ~isfile,
    msgs{end+1} = sprintf('Missing file %s',fn); %#ok<AGROW>
    success = false;
    iserror(category2idx.missing_capture_files) = true;
  end
end

%% check for missing desired files

if isfield(check_params,'desired_files'),
  for i = 1:numel(check_params.desired_files),
    fn = check_params.desired_files{i};
    if any(fn == '*'),
      isfile = ~isempty(dir(fullfile(expdir,fn)));
    else
      isfile = exist(fullfile(expdir,fn),'file');
    end
    if ~isfile,
      msgs{end+1} = sprintf('Missing desired file %s',fn); %#ok<AGROW>
    end
  end
end

%% output results to file

if DEBUG,
  fid = 1;
else
  if exist(outfile,'file'),
    try
      delete(outfile);
    catch ME,
      warning('FlyBubbleAutomaticChecksIncoming:output',...
        'Could not delete file %s:\n %s',outfile,getReport(ME));
    end
  end
  fid = fopen(outfile,'w');
end
if fid < 0,
  warning('FlyBubbleAutomaticChecksIncoming:output',...
    'Could not open automatic checks results file %s for writing, just printing to stdout.',outfile);
  fid = 1;
end
if success,
  fprintf(fid,'automated_pf,U\n');
else
  fprintf(fid,'automated_pf,F\n');
  i = find(iserror,1);
  if isempty(i),
    s = 'incoming_checks_other';
  else
    s = categories{i};
  end
  fprintf(fid,'automated_pf_category,%s\n',s);
end
if ~isempty(msgs),
  fprintf(fid,'notes_curation,');
  s = sprintf('%s\\n',msgs{:});
  s = s(1:end-2);
  fprintf(fid,'%s\n',s);
end
% runInfo = logger.runInfo;
% fprintf(fid,'version,%s\n',version);
% fprintf(fid,'timestamp,%s\n',runInfo.timestamp);
% fprintf(fid,'analysis_protocol,%s\n',runInfo.analysis_protocol);
% fprintf(fid,'linked_analysis_protocol,%s\n',runInfo.linked_analysis_protocol);

if ~DEBUG && fid > 1,
  fclose(fid);
end

catch ME,
  success = false;
  msgs = {getReport(ME)};
end

%% save info to mat file

filename = fullfile(expdir,dataloc_params.automaticchecksincominginfomatfilestr);
fprintf('Saving debug info to file %s...\n',filename);

%aciinfo = runInfo;
aciinfo = struct() ;
aciinfo.paramsfile = paramsfile;
aciinfo.check_params = check_params;
aciinfo.version = version;
aciinfo.iserror = iserror;
aciinfo.categories = categories;
aciinfo.msgs = msgs;
aciinfo.success = success; 

if exist(filename,'file'),
  try %#ok<TRYNC>
    delete(filename);
  end
end
try
  save(filename,'-struct','aciinfo');
catch ME,
  warning('FlyBubbleAutomaticChecksIncoming:save',...
    'Could not save information to file %s: %s',filename,getReport(ME));
end

  
%% print results to log file
fprintf('success = %d\n',success);
if isempty(msgs),
  fprintf('No error or warning messages.\n');
else
  fprintf('Warning/error messages:\n');
  fprintf('%s\n',msgs{:});
end
%logger.close();
