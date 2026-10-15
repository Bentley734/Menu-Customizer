local api=testLoader.exports.gen3transparency;local P=api.selectorPalette;local catalog=api.borderCatalog or assert(loadfile(sourceRoot..'/lib/border_catalog.lua'))()
local names={'RED','BLUE','GREEN','YELLOW','GOLD','SILVER','CRYSTAL'}
assert(#P.gradients.versionEntries==7)
for i,name in ipairs(names)do
 local key='version_'..name:lower();local label=name..' VERSION'
 assert(P.names[#P.names-7+i]==label and P.backgroundNames[#P.backgroundNames-7+i]==label)
 local t=P.color('text',#P.names-8+i);local b=P.color('background',#P.backgroundNames-8+i)
 assert(t.gradient==key and b.gradient==key and t~=b)
 assert(t._speedGroup=='text'and b._speedGroup=='background')
 local frame=catalog.entries[#catalog.entries-7+i];assert(frame.label==label and frame.gradient==key and frame.animation=='gradient')
 local a,c=P.gradients.sample(key,0),P.gradients.sample(key,.25)
 assert(a and c and (a[1]~=c[1]or a[2]~=c[2]or a[3]~=c[3]))
 local z=P.gradients.sample(key,1);for n=1,3 do assert(math.abs(a[n]-z[n])<.00001)end
end
print('PASS seven matching version gradients, text/background/border catalogs, independent rates and cyclic animation')
