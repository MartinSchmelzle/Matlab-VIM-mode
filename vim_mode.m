%Set up the figure
% May be the position property  should be individually tweaked to avoid visibility
fh = figure(...
    'name', 'Press a key', ...
    'keypressfcn', 'set(gcbf, ''Userdata'', get(gcbf, ''Currentkey'')) ; uiresume ', ...
    'windowstyle', 'modal', ...
    'numbertitle', 'off', ...
    'position', [0 0 1 1], ... % really small in the corner
    'userdata', 'timeout');

%while Vim mode is active
while true
    %get Editor window
    activeEditor = matlab.desktop.editor.getActive;
    %get cursor location
    cursor_row=activeEditor.Selection(1);
    cursor_column=activeEditor.Selection(2);
    %insert cursor
    activeEditor.Text=insert_letter(activeEditor,'|',cursor_row,cursor_column);
    activeEditor.Selection=[cursor_row,cursor_column,cursor_row,cursor_column];
    
    %get the keyboard input
    keyboard_input=getkey_2(fh);
    %remove cursor
    activeEditor.Text=remove_letter(activeEditor,cursor_row,cursor_column);
    activeEditor.Selection=[cursor_row,cursor_column,cursor_row,cursor_column];
    %run the function to do something with it
    if keyboard_input=='i'
        break;
    elseif keyboard_input=='a'
        newPosition = activeEditor.Selection(2) + 1; % Assuming infinite right movement is allowed
        activeEditor.Selection = [activeEditor.Selection(1), newPosition, activeEditor.Selection(1), newPosition];
        break;
    else
        process_input(keyboard_input,activeEditor,fh);
    end
end

if ishandle(fh)
    delete(fh) ;
end


function success=process_input(keyboard_input,activeEditor,fh)
%This function processes the user's keyboard input. All the keybindings are
%here.
    currentPosition = activeEditor.Selection(1:2); % Assuming no selection for simplicity
    %disp(keyboard_input);
    switch keyboard_input
        case 'k'
            newPosition = max(currentPosition(1) - 1, 1); % Prevent moving above first line
            activeEditor.Selection = [newPosition, currentPosition(2), newPosition, currentPosition(2)];
        case 'uparrow'
            newPosition = max(currentPosition(1) - 1, 1); % Prevent moving above first line
            activeEditor.Selection = [newPosition, currentPosition(2), newPosition, currentPosition(2)];
        case 'j'
            newPosition = currentPosition(1) + 1; % Add logic to prevent moving beyond the last line
            activeEditor.Selection = [newPosition, currentPosition(2), newPosition, currentPosition(2)];
        case 'downarrow'
            newPosition = currentPosition(1) + 1; % Add logic to prevent moving beyond the last line
            activeEditor.Selection = [newPosition, currentPosition(2), newPosition, currentPosition(2)];
        case 'h'
            newPosition = max(currentPosition(2) - 1, 1); % Prevent moving before first column
            activeEditor.Selection = [currentPosition(1), newPosition, currentPosition(1), newPosition];
        case 'leftarrow'
            newPosition = max(currentPosition(2) - 1, 1); % Prevent moving before first column
            activeEditor.Selection = [currentPosition(1), newPosition, currentPosition(1), newPosition];
        case 'l'
            newPosition = currentPosition(2) + 1; % Assuming infinite right movement is allowed
            activeEditor.Selection = [currentPosition(1), newPosition, currentPosition(1), newPosition];
        case 'rightarrow'
            newPosition = currentPosition(2) + 1; % Assuming infinite right movement is allowed
            activeEditor.Selection = [currentPosition(1), newPosition, currentPosition(1), newPosition];
        case 'g'
            keyboard_input_2=getkey_2(fh);
            switch keyboard_input_2
                case 'g'
                    activeEditor.Selection = [1, currentPosition(2), 1, currentPosition(2)];
            end
        case 'd'
            keyboard_input_2=getkey_2(fh);
            switch keyboard_input_2
                case 'd'
                    a=activeEditor.Selection;
                    lines=matlab.desktop.editor.textToLines(activeEditor.Text);
                    lines(activeEditor.Selection(1))=[];
                    activeEditor.Text=matlab.desktop.editor.linesToText(lines);
                    activeEditor.Selection=a;
            end
        case 'shift'
            keyboard_input_2=getkey_2(fh);
            switch keyboard_input_2
                case 'g'
                    newPosition = length(matlab.desktop.editor.textToLines(activeEditor.Text));
                    activeEditor.Selection = [newPosition, currentPosition(2), newPosition, currentPosition(2)];
            end
    end
end

function newtext=insert_letter(activeEditor,letter,row,column)
%This function inserts a letter at the specified location
    oldtext=activeEditor.Text;
    index = matlab.desktop.editor.positionInLineToIndex(activeEditor, row, column);
    newtext=[oldtext(1:index-1),letter,oldtext(index:end)];
end

function newtext = remove_letter(activeEditor,row,column) 
    %This function removes a letter from a specified location
    oldtext=activeEditor.Text;
    index = matlab.desktop.editor.positionInLineToIndex(activeEditor, row,column);
    newtext=[oldtext(1:index-1),oldtext(index+1:end)];
end

function ch = getkey_2(fh)
    % GETKEY - get a keypress
    %This is a modified version of getkey by Jos van der Geest in which N=1 and
    %non-ascii='non-ascii'.
    %I also removed time-related info
    %Also the figure is an input parameter now
    
    % Wait for something to happen, usually a key press so uiresume is executed
    uiwait;
    key = get(fh,'Userdata');   % and the key itself
   
    %%Key Release
    %change figure callback functions
    set(fh,'KeyPressFcn','');
    set(fh,'KeyReleaseFcn', 'set(gcbf, ''UserData'', []);uiresume');
    
    uiwait;
    get(fh,'Userdata');
    
    %change figure back
    set(fh,'KeyReleaseFcn','');
    set(fh,'KeyPressFcn', 'set(gcbf, ''Userdata'', get(gcbf, ''Currentkey'')) ; uiresume ');
    
    ch=key;
end
