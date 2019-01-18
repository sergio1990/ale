" Author: Sergey Gernyak <sergeg1990@gmail.com>
" Description: avrgcc linter for c files

call ale#Set('c_avrgcc_executable', 'avr-gcc')
call ale#Set('c_avrgcc_options', '-mmcu='.get(g:, 'ale_avrgcc_mmcu', ''))

function! ale_linters#c#avrgcc#GetCommand(buffer, output) abort
    let l:cflags = ale#c#GetCFlags(a:buffer, a:output)

    " -iquote with the directory the file is in makes #include work for
    "  headers in the same directory.
    return '%e -S -x c -fsyntax-only'
    \   . ' -iquote ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ale#Pad(l:cflags)
    \   . ale#Pad(ale#Var(a:buffer, 'c_avrgcc_options')) . ' -'
endfunction

call ale#linter#Define('c', {
\   'name': 'avrgcc',
\   'output_stream': 'stderr',
\   'executable_callback': ale#VarFunc('c_avrgcc_executable'),
\   'command_chain': [
\       {'callback': 'ale#c#GetMakeCommand', 'output_stream': 'stdout'},
\       {'callback': 'ale_linters#c#avrgcc#GetCommand'}
\   ],
\   'callback': 'ale#handlers#gcc#HandleGCCFormatWithIncludes',
\})
