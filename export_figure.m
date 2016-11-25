function export_figure(fig_handle_vec,  ...
                    Expand,filenames,resolution,pictureFormat)   %Optional arguments

if nargin<2
    Expand='';
end

if nargin<4
    resolution=600;
elseif isempty(resolution)
    resolution=600;
end

if nargin<5
    pictureFormat={'pdf'};
else
    if ~iscell(pictureFormat)
        error('pictureFormat must be cell array of strings.')
    end
end

printFlag=cell(size(pictureFormat));
for n=1:length(pictureFormat)
    if strcmpi(pictureFormat{n},'emf')
        if ispc
            printFlag{n}='meta';
        else
            error('Matlab cannot export emf except under Windows.');
        end
    else
        printFlag{n}=lower(pictureFormat{n});
    end
end

if min(size(fig_handle_vec,1),size(fig_handle_vec,2))~=1,
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
        elseif isnumeric(Expand)
            pos=get(fig_handle_vec(i),'PaperPosition');
            set(fig_handle_vec(i), 'PaperPositionMode', 'manual');
            set(fig_handle_vec(i),'PaperPosition',[pos(1:2),pos(3:4)*Expand]);

        end
    end
end

for i=1:length(fig_handle_vec),
    for n=1:length(printFlag)
        if nargin<3
           print(['-r',int2str(resolution)], '-painters', ['-d',printFlag{n}],['-f',int2str(double(fig_handle_vec(i)))]);
           %print(['-r',int2str(resolution)], '-painters', ['-d',printFlag{n}],['-f',int2str(get(fig_handle_vec(i),'Number'))]);
        else
           print(['-r',int2str(resolution)], '-painters', ['-d',printFlag{n}],['-f',int2str(double(fig_handle_vec(i)))],[filenames{i},['.',pictureFormat{n}]]);
%           print(['-r',int2str(resolution)], '-painters', ['-d',printFlag{n}],['-f',int2str(get(fig_handle_vec(i),'Number'))],[filenames{i},['.',pictureFormat{n}]]);
        end
    end
end

% %If "strawberry perl" and Miketex is installed
if nargin>=3 %&& ispc
    temp_env=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH', '')
    for n=1:length(pictureFormat)
        if strcmpi(pictureFormat{n},'pdf')
           for i=1:length(fig_handle_vec),
               system(['pdfcrop "',filenames{i},'.pdf" "',filenames{i},'.pdf"']);
           end

           break;
        end
    end
    setenv('LD_LIBRARY_PATH', temp_env)
end