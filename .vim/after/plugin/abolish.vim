" These can't go in .vimrc since plugins are loaded after
if !exists(":Abolish")
  finish
endif

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
