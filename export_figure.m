function export_figure(fig_handle_vec,  ...
                    Expand,filenames,resolution,pictureFormat_cVec,dimScale)   %Optional arguments

if nargin<2
    Expand='';
end

if nargin<4
    resolution=600;
elseif isempty(resolution)
    resolution=600;
end

if nargin<5
    pictureFormat_cVec={'pdf'};
elseif isempty(pictureFormat_cVec)
    pictureFormat_cVec={'pdf'};
else
    if ~iscell(pictureFormat_cVec)
        error('pictureFormat must be cell array of strings.')
    end
end

if nargin<6
    dimScale=[];
end

printFlag_cVec=cell(size(pictureFormat_cVec));
for n=1:length(pictureFormat_cVec)
    if strcmpi(pictureFormat_cVec{n},'emf')
        if ispc
            printFlag_cVec{n}='meta';
        else
            error('Matlab cannot export emf except under Windows.');
        end
    else
        printFlag_cVec{n}=lower(pictureFormat_cVec{n});
    end
end

if min(size(fig_handle_vec,1),size(fig_handle_vec,2))~=1
    error('h must be 1 D vector'),
end

if ~iscellstr(filenames)
    error('filenames must be a cell string of the same length as h_vec');
end
    
if nargin>2
    if length(fig_handle_vec)~=length(filenames)
        error('h & filenames must be of the same length');
    end
end

if ~isempty(Expand)
    if ischar(Expand)
        if (~strcmpi(Expand,'||') && ~strcmpi(Expand,'=='))
            error('you must input ''||'' or ''==''')    
        end
    end
end

for i=1:length(fig_handle_vec)
    f_OriginalUnit=get(fig_handle_vec(i),'Units');
    set(fig_handle_vec(i),'papertype','A4');
    if ~isempty(Expand)
        if ischar(Expand)
            if strcmpi(Expand(1:2),'||')
                 set(fig_handle_vec(i), 'PaperOrientation', 'portrait');
            elseif strcmpi(Expand(1:2),'==')
               set(fig_handle_vec(i), 'PaperOrientation', 'landscape');
            end
        end
        
        if ischar(Expand)
            if strcmpi(Expand,'||') || strcmpi(Expand,'==')
                a=get(fig_handle_vec(i),'papersize');
                set(fig_handle_vec(i), 'PaperPositionMode', 'manual');
                set(fig_handle_vec(i),'PaperPosition',[0 0 a(1) a(2)]);
                set(fig_handle_vec(i),'Units',get(fig_handle_vec(i),'PaperUnits'));
                set(fig_handle_vec(i),'Position',[0 0 a(1) a(2)]);
                set(fig_handle_vec(i),'Units',f_OriginalUnit);
                set(0,'CurrentFigure',fig_handle_vec(i)),
                drawnow
            else
                set(fig_handle_vec(i), 'PaperPositionMode', 'auto');
            end
        end
        if ~isempty(dimScale)
            pos=get(fig_handle_vec(i),'PaperPosition');
            set(fig_handle_vec(i), 'PaperPositionMode', 'manual');
            set(fig_handle_vec(i),'PaperPosition',[pos(1:2),pos(3:4).*dimScale/max(dimScale)]);
        end
    end
end

for i=1:length(fig_handle_vec)
    for n=1:length(printFlag_cVec)
        if any(strcmp(printFlag_cVec{n},{'emf','pdf','eps','epsc','svg'}))
            renderer='-painters';
        elseif any(strcmp(printFlag_cVec{n},{'png','jpg'}))
            renderer='-opengl';
        end
        if nargin<3
           print(['-r',int2str(resolution)], renderer, ['-d',printFlag_cVec{n}],['-f',int2str(double(fig_handle_vec(i)))]);
        else
           print(['-r',int2str(resolution)], renderer, ['-d',printFlag_cVec{n}],['-f',int2str(double(fig_handle_vec(i)))],[filenames{i},'.',pictureFormat_cVec{n}]);
        end
    end
end

%If "strawberry perl" and Miketex is installed
if nargin>=3
    temp_env=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH', '')
    
    if any(strcmpi(pictureFormat_cVec,'pdf'))
        [status,~]=system('where pdfcrop');
        if status,warning('pdfcrop is not installed. Please install it through TeXLive or MiKTeX.'),end
    end
    
    if any(strcmpi(pictureFormat_cVec,'png')) || any(strcmpi(pictureFormat_cVec,'jpg'))
        if ispc
            [status,~]=system('where magick');
            if status,warning('Imagemagick is not installed.'),end
        else
            [status,~]=system('where convert');
            if status,warning('Imagemagick is not installed.'),end
        end
    end

    for n=1:length(pictureFormat_cVec)
        if strcmpi(pictureFormat_cVec{n},'pdf')
            for i=1:length(fig_handle_vec)
               system(['pdfcrop "',filenames{i},'.pdf" "',filenames{i},'.pdf"']);
            end
        elseif any(strcmpi(pictureFormat_cVec{n},{'png','jpg'}))
            for i=1:length(fig_handle_vec)
                system(['magick convert "',filenames{i},'.',pictureFormat_cVec{n},'" -trim "',filenames{i},'.',pictureFormat_cVec{n},'"']);
            end
        end
    end
    setenv('LD_LIBRARY_PATH', temp_env)
end