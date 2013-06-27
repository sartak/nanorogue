use Curses;initscr;END{endwin;print"You ",$D?"die.":"win!"," D:$d T:$t S:$s
"}$B=A_BOLD;init_pair$_,$_,noecho for start_color..8;$h=100;sub C{move@_}sub
I{delch;insch@_}sub P{addstr@_;clrtoeol}sub l{C 0,0;P@_}sub R{1+int rand pop}sub
D{C@_;I+(($c=$m{$_[1],$_[0]})>9?38:$c?ord($c):46)|($c?COLOR_PAIR(R 6)|((1<R
3)?0:$B):0)}sub M{($l=$x+$_[0])>78|$l<1|($u=$y+$_[1])>22|$u<1?--$t|l"Stop!":$m{$
l,$u}?${$s+=5*$d;($j=--$m{$l,$u})?($h-=R$j)>(l"You engage the beast.")||($D=1):l
"Splat!";D$u,$l}:($x=$l,$y=$u)}sub G{${C$_,1;addstr"."x78}for clear..22;${$a=R
78;$b=R 22;$m{$a,$b}+=R$d/2;D$b,$a}for%m=()..R 2*++$d;$X=R 78;$Y=R
22;$m{$x,$y}=$m{$X,$Y}=C$Y,$X;I$B|62;l"Going down!"}@C{qw{q h j k l y u b n > .
Q 4 2 8 6 7 9 1 3}}=(qw{$D++ M(-1,0) M(0,1) M(0,-1) M(1,0) M(-1,-1)
M(1,-1) M(-1,1) M(1,1) $y-$Y|$x-$X?l"Here..?":G 1})x2;G;$x=$y=2;$s=$t=l"";${C 23
,0;$t%30|$h>99||++$h;P"H:$h D:$d T:$t";C$y,$x;I"@";$c=$C{+getch};I$y-$Y|$x-$X?46
:$B|62;l"";$c?++$t|eval$c:l"Huh?"}until$D|$s>1e4