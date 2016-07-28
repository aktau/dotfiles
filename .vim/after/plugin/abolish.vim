" These can't go in .vimrc since plugins are loaded after
if !exists(":Abolish")
  finish
endif

" Both existant and existent exist. However, non-existent doesn't. So it is
" better to convert existant to existent (can't abolish words with dashes in
" them).
Abolish ac{,c}es{,s}{i,a}ble                         a{cc}e{ss}{i}ble
Abolish dis{,s}ap{,p}ear{,s,ing}                     dis{,}ap{p}ear{}
Abolish cancelation                                  cancellation
Abolish over{,r}id{e,de,des,ing,ding,en,den}         over{r}id{e,e,es,ing,ing,den,den}
Abolish critiscism                                   criticism
Abolish embar{,r}as{,s}ing                           embarrassing
Abolish existant                                     existent
Abolish garbace                                      garbage
Abolish worksapce                                    workspace
Abolish oc{,c}ur{,s,red,ed}                          oc{c}ur{,s,red,red}
Abolish exmaple{,s}                                  example{}
Abolish mil{,l}isecond{,s}                           mil{l}isecond{}
Abolish com{,m}it{,t}{ed,ing}                        com{m}it{t}{}
Abolish defin{a,i,o}t{,e,i,o}l{i,y}                  defin{i}t{e}l{y}
Abolish wierd{,ed}                                   weird{}
Abolish mis{,s}pel{,l}ing{,s}                        mis{s}pel{l}ing{}
Abolish an{e,o}ursym{,s}                             an{e}urysm{}
Abolish dif{,f}er{,e}nt{,ly,y}                       dif{f}er{e}nt{,ly,ly}
Abolish suc{,c}esful{,ly,y}                          suc{c}essful{,ly,ly}
Abolish itnerface{,s}                                interface{}
Abolish arugment{,s}                                 argument{}
Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or} {despe,sepa}rat{}
Abolish afterword{,s}                                afterward{}
Abolish anomol{y,ies}                                anomal{}
Abolish austrail{a,an,ia,ian}                        austral{ia,ian}
Abolish cal{a,e}nder{,s}                             cal{e}ndar{}
Abolish {c,m}arraige{,s}                             {}arriage{}
Abolish {,in}consistan{cy,cies,t,tly}                {}consisten{}
Abolish delimeter{,s}                                delimiter{}
Abolish {,non}existan{ce,t}                          {}existen{}
Abolish d{e,i}screp{e,a}nc{y,ies}                    d{i}screp{a}nc{}
Abolish euphamis{m,ms,tic,tically}                   euphemis{}
Abolish excersize{s}                                 exercise{}
Abolish hense                                        hence
Abolish {,re}impliment{,s,ing,ed,ation}              {}implement{}
Abolish improvment{,s}                               improvement{}
Abolish inherant{,ly}                                inherent{}
Abolish lastest                                      latest
Abolish {les,compar,compari}sion{,s}                 {les,compari,compari}son{}
Abolish {,un}nec{ce,ces,e}sar{y,ily}                 {}nec{es}sar{}
Abolish {,un}orgin{,al}                              {}origin{}
Abolish persistan{ce,t,tly}                          persisten{}
Abolish referesh{,es}                                refresh{}
Abolish {,ir}releven{ce,cy,t,tly}                    {}relevan{}
Abolish rec{co,com,o}mend{,s,ed,ing,ation}           rec{om}mend{}
Abolish reproducable                                 reproducible
Abolish resouce{,s}                                  resource{}
Abolish restraunt{,s}                                restaurant{}
Abolish segument{,s,ed,ation}                        segment{}
Abolish o{c,cc}a{s,ss}ion{,al,ally}                  o{cc}a{s}ion{}
