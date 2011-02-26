% [succeeded,aviname] = make_ctrax_result_movie('param',value,...)
% Options:
% 'moviename': name of raw movie to annotate
% 'trxname': name of mat file containing trajectories, or struct of
% trajectories
% 'aviname': name of movie to output to
% 'colors': colors to plot each fly
% 'nzoomr': number of rows of zoom fly boxes
% 'nzoomc': number of columns of zoom fly boxes
% 'boxradius': radius of the zoom fly box in pixels
% 'taillength': number of frames of trajectory to plot behind each fly
% 'zoomflies': flies to zoom in on
% 'fps': frames per second of output movie
% 'maxnframes': number of frames to output
% 'firstframe': first frame to output
% 'compression': compressor to use when outputting (pc only, will be set to
% 'none' for linux). 
% 'figpos': position of figure
% if any parameters are not given, the user will be prompted for these
function [succeeded,aviname,figpos] = make_ctrax_result_movie(varargin)

succeeded = false;
defaults.boxradius = 1.5;
defaults.taillength = 100;
defaults.fps = 20;
defaults.zoomflies = [];
defaults.nzoomr = 5;
defaults.nzoomc = 3;
defaults.compression = 'None';
allowedcompressions = {'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', 'RLE', 'None','Uncompressed AVI','Motion JPEG AVI'};
useVideoWriter = exist('VideoWriter','file');
mencoderoptions = '';
mencoder_maxnframes = inf;
[moviename,trxname,aviname,colors,zoomflies,nzoomr,nzoomc,boxradius,...
  taillength,fps,maxnframes,firstframes,compression,figpos,movietitle,...
  useVideoWriter,mencoderoptions,mencoder_maxnframes,...
  avifileTempDataFile] = ...
  myparse(varargin,'moviename','','trxname','','aviname','','colors',[],'zoomflies',[],'nzoomr',nan,'nzoomc',nan,...
  'boxradius',nan,'taillength',nan,'fps',nan,'maxnframes',nan,'firstframes',[],'compression','',...
  'figpos',[],'movietitle','','useVideoWriter',useVideoWriter,...
  'mencoderoptions',mencoderoptions,'mencoder_maxnframes',mencoder_maxnframes,...
  'avifileTempDataFile','');

if ~ischar(compression),
  compression = '';
end
if ~isempty(compression) && ~any(strcmpi(compression,allowedcompressions)),
  fprintf('Unknown compressor %s\n',compression);
  compression = '';
end

if ~ischar(moviename) || isempty(moviename) || ~exist(moviename,'file'),
  fprintf('Choose raw movie to annotate\n');
  helpmsg = 'Choose raw movie to annotate';
  [movienameonly,moviepath] = uigetfilehelp({'*.fmf';'*.sbfmf';'*.avi'},'Choose raw movie to annotate','','helpmsg',helpmsg);
  if ~ischar(movienameonly),
    return;
  end
  moviename = [moviepath,movienameonly];
else
  [moviepath,movienameonly] = split_path_and_filename(moviename);
end
[readframe,nframes,fid] = get_readframe_fcn(moviename);
if fid < 0,
  uiwait(msgbox(sprintf('Could not read in movie %s',moviename)));
  return;
end

if ~ischar(trxname) && isstruct(trxname),
  trx = trxname;
else
  if ~ischar(trxname) || isempty(trxname) || ~exist(trxname,'file'),
    fprintf('Choose mat file containing flies'' trajectories corresponding to movie %s\n',moviename);
    [~,ext] = splitext(moviename);
    trxname = [moviename(1:end-length(ext)+1),'mat'];
    helpmsg = sprintf('Choose trx file to annotate the movie %s with',moviename);
    [trxnameonly,trxpath] = uigetfilehelp('*.mat',sprintf('Choose trx file for %s',movienameonly),trxname,'helpmsg',helpmsg);
    if ~ischar(trxnameonly),
      return;
    end
    trxname = [trxpath,trxnameonly];
  end
  [trx,trxname,loadsucceeded,timestamps] = load_tracks(trxname);
  if ~loadsucceeded,
    return;
  end
end

% output avi
haveaviname = false;
if ischar(aviname) && ~isempty(aviname)
  [~,ext] = splitext(aviname);
  if strcmpi(ext,'.avi'),
    haveaviname = true;
  end
end
if ~haveaviname,
  fprintf('Choose avi file to output annotated version of %s\n',moviename);
  [base,~] = splitext(movienameonly);
  aviname = [moviepath,'ctraxresults_',base,'.avi'];
  helpmsg = {};
  helpmsg{1} = 'Choose avi file to write annotated movie to.';
  helpmsg{2} = sprintf('Raw movie input: %s',moviename);
  helpmsg{3} = sprintf('Trx file name input: %s',trxname);
  [avinameonly,avipath] = uiputfilehelp('*.mat',sprintf('Choose output avi for %s',movienameonly),aviname,'helpmsg',helpmsg);
  if ~ischar(avinameonly),
    return;
  end
  aviname = [avipath,avinameonly];
end

% set undefined parameters
nids = length(trx);

nzoom = length(zoomflies);
if nzoom > 0,
  if max(zoomflies) > nids || min(zoomflies) < 1,
    uiwait(msgbox('Illegal values for zoomflies'));
    return;
  end
end

prompts = {};
defaultanswers = {};
if isnan(nzoomr),
  prompts{end+1} = 'Number of rows of zoomed fly boxes';
  defaultanswers{end+1} = num2str(defaults.nzoomr);
end
if isnan(nzoomc) && nzoom == 0,
  prompts{end+1} = 'Number of columns of zoomed fly boxes';
  defaultanswers{end+1} = num2str(defaults.nzoomc);
end
if isnan(boxradius),
  prompts{end+1} = 'Radius of zoomed fly box (in pixels)';
  defaultanswers{end+1} = num2str(ceil(mean([trx.a])*4*defaults.boxradius));
end
if isnan(taillength),
  prompts{end+1} = 'Length of plotted tail trajectory (in frames)';
  defaultanswers{end+1} = num2str(defaults.taillength);
end
if isnan(fps) && isfield(trx,'fps'),
  fps = trx(1).fps;
end
if isnan(fps),
  prompts{end+1} = 'Output movie frames per second';
  defaultanswers{end+1} = num2str(defaults.fps);
end
if isnan(maxnframes),
  prompts{end+1} = 'Max number of frames to output';
  defaultanswers{end+1} = num2str(nframes);
end
if isempty(firstframes),
  prompts{end+1} = 'First frame to output';
  defaultanswers{end+1} = num2str(1);
end

compressionprompt = ['Compressor (must be one of ',...
  sprintf('%s, ',allowedcompressions{1:end-1}),allowedcompressions{end},')'];
if ~ispc && ~useVideoWriter,
  compression = 'None';
elseif isempty(compression),
  prompts{end+1} = compressionprompt;
  defaultanswers{end+1} = defaults.compression;
end

if ~isempty(prompts),
  while true,
    answers = inputdlg(prompts,'make_ctrax_result_movie parameters',1,defaultanswers);
    if isempty(answers),
      return;
    end
    failed = false;
    for i = 1:length(answers),
      if strcmp(prompts{i},compressionprompt)
        j = strmatch(answers{i},allowedcompressions);
        if isempty(j),
          uiwait(msgbox(sprintf('Illegal compressor: %s',answers{i})));
          failed = true;
          break;
        end
        compression = allowedcompressions{j};
        answers{i} = allowedcompressions{j};
        defaultanswers{i} = compression;
        continue;
      end
      answers{i} = str2double(answers{i});
      if isempty(answers{i}) || answers{i} < 0,
        uiwait(msgbox('All answers must be positive numbers'));
        failed = true;
        break;
      end
      switch prompts{i},
        case 'Number of rows of zoomed fly boxes',
          nzoomr = ceil(answers{i});
          
          % check that nzoomr is not too big
          if nzoom > 0,
            if ~isnan(nzoomc) && nzoomr > ceil(nzoom / nzoomc),
              fprintf('nzoomr = %d > ceil(nzoom = %d / nzoomc = %d), decreasing nzoomr\n',nzoomr,nzoom,nzoomc);
              nzoomr = ceil(nzoom/nzoomc);
            elseif nzoomr > nzoom,
              fprintf('nzoomr = %d > nflies to plot = %d, decreasing nzoomr\n',nzoomr,nzoom);
              nzoomr = nzoom;
            end
          else
            if ~isnan(nzoomc) && nzoomr > ceil(nids / nzoomc),
              fprintf('nzoomr = %d > ceil(nflies = %d / nzoomc = %d), decreasing nzoomr\n',nzoomr,nids,nzoomc);
              nzoomr = ceil(nids/nzoomc);
            elseif nzoomr > nids,
              fprintf('nzoomr = %d > nflies = %d, decreasing nzoomr\n',nzoomr,nids);
              nzoomr = nids;
            end
          end
          answers{i} = nzoomr;
        case 'Number of columns of zoomed fly boxes',
          nzoomc = ceil(answers{i});
          % check that nzoomr is not too big
          if nzoom > 0,
            if ~isnan(nzoomr) && nzoomc > ceil(nzoom / nzoomr),
              fprintf('nzoomc = %d > ceil(nzoom = %d / nzoomr = %d), decreasing nzoomc\n',nzoomc,nzoom,nzoomr);
              nzoomc = ceil(nzoom/nzoomr);
            elseif nzoomc > nzoom,
              fprintf('nzoomc = %d > nflies to plot = %d, decreasing nzoomc\n',nzoomc,nzoom);
              nzoomc = nzoom;
            end
          else
            if ~isnan(nzoomr) && nzoomc > ceil(nids / nzoomr),
              fprintf('nzoomc = %d > ceil(nflies = %d / nzoomr = %d), decreasing nzoomc\n',nzoomc,nids,nzoomr);
              nzoomc = ceil(nids/nzoomr);
            elseif nzoomc > nids,
              fprintf('nzoomc = %d > nflies = %d, decreasing nzoomc\n',nzoomc,nids);
              nzoomc = nids;
            end
          end
          answers{i} = nzoomc;
        case 'Radius of zoomed fly box (in pixels)',
          boxradius = ceil(answers{i});
          answers{i} = boxradius;
        case 'Length of plotted tail trajectory (in frames)',
          taillength = ceil(answers{i});
          answers{i} = taillength;
        case 'Output movie frames per second',
          fps = answers{i};
          answers{i} = fps;
        case 'Max number of frames to output',
          maxnframes = min(ceil(answers{i}),nframes);
          answers{i} = maxnframes;
        case 'First frame to output',
          firstframes = max(1,ceil(answers{i}));
          answers{i} = firstframes;
      end
      defaultanswers{i} = num2str(answers{i});
    end
    if failed,
      continue;
    end
    break;
  end
end

if nzoom > 0,
  nzoomc = ceil(nzoom/nzoomr);
end
endframes = min(nframes,firstframes+maxnframes-1);
im = readframe(firstframes(1));
[nr,nc,ncolors] = size(im);

% choose some random flies to zoom in on
nzoom = nzoomr*nzoomc;

nframesoverlap = zeros(1,numel(trx));
for i = 1:numel(firstframes),
  nframesoverlap = nframesoverlap + ...
      max(0,min(endframes(i),[trx.endframe])-max(firstframes(i),[trx.firstframe]) + 1);
end
fliesmaybeplot = find(nframesoverlap > 0);

if isempty(zoomflies),
  if length(fliesmaybeplot) < nzoom,
    zoomflies = [fliesmaybeplot,nan(1,nzoom-length(fliesmaybeplot))];
    fprintf('Not enough flies to plot\n');
  else
    fliesmaybeplot = fliesmaybeplot(randperm(length(fliesmaybeplot)));
    [~,flieswithmostframes] = sort(-nframesoverlap(fliesmaybeplot));
    zoomflies = sort(fliesmaybeplot(flieswithmostframes(1:nzoom)));
  end
elseif nzoom > length(zoomflies),
  zoomflies = [zoomflies,nan(1,nzoom-length(zoomflies))];
end
zoomflies = reshape(zoomflies,[nzoomr,nzoomc]);
rowszoom = floor(nr/nzoomr);


% colors of the flies
if isempty(colors),
  zoomfliesreal = zoomflies(~isnan(zoomflies));
  colors0 = jet(nids);
  fliesnotplot = setdiff(1:nids,fliesmaybeplot);
  fliesnotzoom = setdiff(fliesmaybeplot,zoomfliesreal(:)');
  colors = nan(nids,3);
  coloridx = round(linspace(1,size(colors0,1),numel(zoomfliesreal)));
  colors(zoomfliesreal(:),:) = colors0(coloridx,:);
  colors0(coloridx,:) = [];
  if ~isempty(fliesnotzoom),
    coloridx = round(linspace(1,size(colors0,1),numel(fliesnotzoom)));
    colors(fliesnotzoom,:) = colors0(coloridx,:);
    colors0(coloridx,:) = [];
  end
  if ~isempty(fliesnotplot),
    colors(fliesnotplot,:) = colors0;
  end
elseif size(colors,1) ~= nids,
  colors = colors(modrange(0:nids-1,size(colors,1))+1,:);
end

figure(1);
clf;
hold on;
hax = gca;
set(hax,'position',[0,0,1,1]);
axis off;

% corners of zoom boxes in plotted image coords
x0 = nc+(0:nzoomc-1)*rowszoom+1;
y0 = (0:nzoomr-1)*rowszoom+1;
x1 = x0 + rowszoom - 1;
y1 = y0 + rowszoom - 1;

% relative frame offset
nframesoff = getstructarrayfield(trx,'firstframe') - 1;

% pre-allocate
himzoom = zeros(nzoomr,nzoomc);
htail = zeros(1,nids);
htri = zeros(1,nids);
scalefactor = rowszoom / (2*boxradius+1);
hzoom = zeros(nzoomr,nzoomc);

mencoder_nframes = 0;

for segi = 1:numel(firstframes),
  firstframe = firstframes(segi);
  endframe = endframes(segi);

  for frame = firstframe:endframe,
    if mod(frame - firstframe,20) == 0,
      fprintf('frame %d\n',frame);
    end
    
    % relative frame
    idx = frame - nframesoff;
    
    isalive = frame >= getstructarrayfield(trx,'firstframe') & ...
      frame <= getstructarrayfield(trx,'endframe');
    
    % draw the unzoomed image
    im = uint8(readframe(frame));
    if ncolors == 1,
      im = repmat(im,[1,1,3]);
    end
    if frame == firstframes(1),
      him = image([1,nc],[1,nr],im);
      axis image;
      axis([.5,x1(end)+.5,.5,y1(end)+.5]);
      axis off;
    else
      set(him,'cdata',im);
    end
    
    % draw frame number text box
    framestr = sprintf('Frame %d, t = %.2f s',frame,timestamps(frame)-timestamps(1));
    if ~isempty(movietitle),
      framestr = {framestr,movietitle}; %#ok<AGROW>
    end
    if frame == firstframes(1),
      htext = text(.5,.5,framestr,'Parent',hax,'BackgroundColor','k','Color','g','VerticalAlignment','bottom','interpreter','none');
    else
      set(htext,'String',framestr);
    end
    
    % draw the zoomed image
    for i = 1:nzoomr,
      for j = 1:nzoomc,
        fly = zoomflies(i,j);
        
        % fly not visible?
        if isnan(fly) || ~isalive(fly),
          if frame == firstframes(1),
            himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(uint8(123),[boxradius*2+1,boxradius*2+1,3]));
          else
            set(himzoom(i,j),'cdata',repmat(uint8(123),[boxradius*2+1,boxradius*2+1,3]));
          end
          continue;
        end
        
        % grab a box around (x,y)
        x = round(trx(fly).x(idx(fly)));
        y = round(trx(fly).y(idx(fly)));
        boxradx1 = min(boxradius,x-1);
        boxradx2 = min(boxradius,size(im,2)-x);
        boxrady1 = min(boxradius,y-1);
        boxrady2 = min(boxradius,size(im,1)-y);
        box = uint8(zeros(2*boxradius+1));
        box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
          boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
          im(y-boxrady1:y+boxrady2,x-boxradx1:x+boxradx2);
        if frame == firstframes(1),
          himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        else
          set(himzoom(i,j),'cdata',repmat(box,[1,1,3]));
        end
        
      end
    end;
    
    % plot the zoomed out position
    if frame == firstframes(1),
      for fly = 1:nids,
        if isalive(fly),
          i0 = max(1,idx(fly)-taillength);
          htail(fly) = plot(trx(fly).x(i0:idx(fly)),trx(fly).y(i0:idx(fly)),...
            '-','color',colors(fly,:));
          htri(fly) = drawflyo(trx(fly),idx(fly));
          set(htri(fly),'color',colors(fly,:));
        else
          htail(fly) = plot(nan,nan,'-','color',colors(fly,:));
          htri(fly) = plot(nan,nan,'-','color',colors(fly,:));
        end
      end
    else
      for fly = 1:nids,
        if isalive(fly),
          i0 = max(1,idx(fly)-taillength);
          set(htail(fly),'xdata',trx(fly).x(i0:idx(fly)),...
            'ydata',trx(fly).y(i0:idx(fly)));
          updatefly(htri(fly),trx(fly),idx(fly));
        else
          set(htail(fly),'xdata',[],'ydata',[]);
          set(htri(fly),'xdata',[],'ydata',[]);
        end
      end
    end
    
    % plot the zoomed views
    for i = 1:nzoomr,
      for j = 1:nzoomc,
        fly = zoomflies(i,j);
        if ~isnan(fly) && isalive(fly),
          x = trx(fly).x(idx(fly));
          y = trx(fly).y(idx(fly));
          x = boxradius + (x - round(x))+.5;
          y = boxradius + (y - round(y))+.5;
          x = x * scalefactor;
          y = y * scalefactor;
          x = x + x0(j) - 1;
          y = y + y0(i) - 1;
          a = trx(fly).a(idx(fly))*scalefactor;
          b = trx(fly).b(idx(fly))*scalefactor;
          theta = trx(fly).theta(idx(fly));
          if frame == firstframes(1),
            hzoom(i,j) = drawflyo(x,y,theta,a,b);
            set(hzoom(i,j),'color',colors(fly,:));
          else
            updatefly(hzoom(i,j),x,y,theta,a,b);
          end
        else
          if frame == firstframes(1),
            if ~isnan(fly),
              hzoom(i,j) = plot(nan,nan,'-','color',colors(fly,:));
            end
          else
            if ~isnan(fly),
              set(hzoom(i,j),'xdata',[],'ydata',[]);
            end
          end
        end
      end
    end
    
    if frame == firstframes(1),
      if ~isempty(figpos),
        set(1,'Position',figpos);
      else
        input('Resize figure 1 to the desired size, hit enter when done.');
        figpos = get(1,'Position');
      end
      set(1,'visible','off');
      if useVideoWriter,
        if strcmpi(compression,'None') || strcmpi(compression,'Uncompressed AVI'),
          profile = 'Uncompressed AVI';
        else
          profile = 'Motion JPEG AVI';
        end
        aviobj = VideoWriter(aviname,profile);
        set(aviobj,'FrameRate',fps);
        if ~strcmpi(profile,'Uncompressed AVI'),
          set(aviobj,'Quality',100);
        end
        open(aviobj);
      else
        if isempty(avifileTempDataFile),
          aviobj = avifile(aviname,'fps',fps,'quality',100,'compression',compression); %#ok<TNMLP>
        else
          aviobj = myavifile(aviname,'fps',fps,'quality',100,'compression',compression,...
            'TempDataFile',avifileTempDataFile); 
          fprintf('Temporary data file for avi writing: %s\n',aviobj.TempDataFile);
        end
      end
    end
    
    if frame == firstframes(1),
      fr = getframe_invisible(hax);
      [height,width,~] = size(fr);
    else
      fr = getframe_invisible(hax,[height,width]);
    end
    if useVideoWriter,
      writeVideo(aviobj,fr);
    else
      aviobj = addframe(aviobj,fr);
    end
    set(1,'Position',figpos);
    
  end
  
end
  
if useVideoWriter,
  close(aviobj);
else
  aviobj = close(aviobj); %#ok<NASGU>
end
if fid > 0,
  fclose(fid);
end

succeeded = true;