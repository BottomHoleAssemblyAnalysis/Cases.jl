function savefigs(figname, obj, pdir=mktempdir())
  println(pdir)
  fexts = [".pdf", ".svg", ".tex"]
  for ext in fexts
    isfile(name * ext) && rm(name * ext)
  end
  pgfsave( joinpath(pdir, figname * ".pdf"), obj)
  run(`pdf2svg $(joinpath(pdir, figname * ".pdf")) $(joinpath(pdir, figname * ".svg"))`)
  pgfsave(joinpath(pdir, figname * ".tex"), obj);
  return nothing
end
