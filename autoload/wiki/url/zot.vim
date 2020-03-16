" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
" License:    MIT license
"

function! wiki#url#zot#parse(url) abort " {{{1
  let l:parser = {}

  " Construct find cmd
  if executable('fd') || executable('fdfind')
    let l:parser.fd = (executable('fd') ? 'fd' : 'fdfind')
          \ . ' -t f -e pdf "{citekey}" '
          \ . escape(g:wiki_zotero_root, ' ')
  else
    let l:parser.fd = 'find '
          \ . escape(g:wiki_zotero_root, ' ')
          \ . ' -name "{citekey}*.pdf" -type f'
  endif

  function! l:parser.open(...) abort dict
    let l:files = systemlist(
          \ substitute(self.fd, '{citekey}', self.stripped, ''))
    if v:shell_error != 0
      echo 'wiki: something went wrong!'
      echo 'cmd:' self.fd
      for l:line in l:files
        echo l:line
      endfor
      return
    endif

    if len(l:files) >= 1
      if len(l:files) > 1
        let l:choice = wiki#menu#choose(
              \ map(copy(l:files), 'fnamemodify(v:val, '':t'')'),
              \ {'header': 'multiple citekeys found, please select one:'})
        if l:choice < 0
          echo 'wiki: aborted'
          return
        endif
        let l:file = l:files[l:choice]
      else
        let l:file = l:files[0]
      endif

      call system(g:wiki_viewer['_'] . ' ' . shellescape(l:file) . '&')
    else
      echo 'wiki: could not find Zotero citekey "' . self.stripped . '"'
    endif
  endfunction

  return l:parser
endfunction

" }}}1
