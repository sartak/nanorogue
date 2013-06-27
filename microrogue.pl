#!/usr/bin/perl
use Curses;

my $hyscr = 10;
my $hxscr = 19;
my $xsee = 18;
my $ysee = 8;
my $X = 200;
my $Y = 98;
my $hy = $Y/2;
my $hx = $X/2;
my $t = 1;
my $s = 0;

$h=100;
initscr;
keypad(stdscr,1);
start_color;
init_pair$_,$_,noecho for 1..8;

for$y(0..$Y){$dungeon[$_][$y]=!$_|$_==$X||rand(4)<1?'#':'.'for 0..$X}
for(0..$X){$dungeon[$_][0]=$dungeon[$_][$Y]='#'}
$dungeon[$hx][$hy]='.';

sub is_okay
{
  my ($x, $y) = @_;
  !($dungeon[$x][$y]eq'#'||($x==$hx&&$y==$hy)||$monster{$x,$y}[1])
}

sub distance
{
  my ($x1, $y1, $x2, $y2) = @_;
  sqrt(($x1-$x2)**2+($y1-$y2)**2);
}

sub sign { $_[0] > 0 ? 1 : -1 }

sub in_los
{
  my ($x1, $y1, $x2, $y2, $r) = @_;
  return 0 if distance($x1,$y1,$x2,$y2)>$r;

  my $dx = $x2 - $x1;
  my $dy = $y2 - $y1;
  my $ax = abs($dx)<<1;
  my $ay = abs($dy)<<1;
  my $sx = sign($dx);
  my $sy = sign($dy);

  if ($ax > $ay)
  {
    my $t = $ay - ($ax >> 1);
    do
    {
      goto X if$x1==$x2&&$y1==$y2;
      if ($t >= 0)
      {
        $y1 += $sy;
        $t  -= $ax;
      }
      $x1 += $sx;
      $t  += $ay;
    }
    until$dungeon[$x1][$y1]eq'#';
  }
  else
  {
    my $t = $ax - ($ay >> 1);
    do
    {
      goto X if$x1==$x2&&$y1==$y2;
      if ($t >= 0)
      {
        $x1 += $sx;
        $t  -= $ay;
      }
      $y1 += $sy;
      $t  += $ax;
    }
    until $dungeon[$x1][$y1] eq '#';
  }
  X:
  return $x1==$x2&&$y1==$y2;
}

sub gen_aux
{
  my ($x, $y);
  my $tries = 0;
  do
  {
    $x = 1 + int rand ($X-1);
    $y = 1 + int rand ($Y-1);
    return if++$tries>99
  }
  until is_okay($x,$y);
  $l=$_[0]>34?34:int pop;
  $monster{$x,$y}=[((rand(2)<1)?A_BOLD:0)|COLOR_PAIR(2+int rand 5),1+$l,++$id];
}


sub draw
{
  move 2, 5+$xsee*2;
  addstr"HP:$h";clrtoeol;
  move 3, 5+$xsee*2;
  addstr"T:$t";
  move 4, 5+$xsee*2;
  addstr"S:$s";
  move 5, 5+$xsee*2;
  printw"B:%.2f%%",100*$b/($X*$Y);

  for my $y ($hy-$ysee..$hy+$ysee)
  {
    for my $x ($hx-$xsee..$hx+$xsee)
    {
      move 2+$y - $hy + $ysee, 1+$x - $hx + $xsee;
      delch;
      my $c = ' ';
      if ($x >= 0 && $y >= 0 && $x <= $X && $y <= $Y)
      {
        if (in_los($x, $y, $hx, $hy, 9))
        {
          $seen[$x][$y] |= 1;
          if (exists$monster{$x,$y})
          {
            $c = $monster{$x,$y}[0]|((48..57,65..90)[$monster{$x,$y}[1]])
          }
          else
          {
            $c = ord($dungeon[$x][$y]);
            $c |= $seen[$x][$y]&2?COLOR_PAIR(1):$c-46?COLOR_PAIR(3):0;
          }
        }
        elsif ($seen[$x][$y]&1)
        {
          $c = A_BOLD|COLOR_PAIR(9)|ord($dungeon[$x][$y])
        }
      }
      insch$c
    }
  }
  move $hyscr, $hxscr;
  delch;
  insch('@');
}

sub gen
{
  clear if!($t&63);
  if (($t & 7) == 0)
  {
    $h<100&&++$h;
    gen_aux(rand$t/75)
  }
  foreach (keys %monster)
  {
    my ($x, $y) = split /$;/, $_;
    next if ($d=distance($hx,$hy,$x,$y))>12;
    if ($d < 2)
    {
      pline("The beast hits!");
      if (($h-=1+int rand$monster{$x,$y}[1])<1)
      {
        pline("You die...");
        pline(" "x60);
        die;
      }
    }
    else
    {
      ($m=$monster{$x,$y}[1])&&$m<35&&rand(99)<1&&++$monster{$x,$y}[1];
      $nx = $x-1 + int rand 3;
      $ny = $y-1 + int rand 3;
      if (is_okay($nx, $ny))
      {
        $monster{$nx,$ny}=$monster{$x,$y};
        delete$monster{$x,$y}
      }
    }
  }
}

sub move_generator
{
  my ($dx, $dy) = @_;
  return sub
  {
    if (exists$monster{$hx+$dx,$hy+$dy})
    {
      if(!($u=--$monster{$hx+$dx,$hy+$dy}[1]))
      {
        pline("Splat!");
        $r=1+rand 2;
        $dungeon[$hx+$dx][$hy+$dy]='%';
        for $y ($hy+$dy-9..$hy+$dy+9)
        {
          for $x ($hx+$dx-9..$hx+$dx+9)
          {
            next unless in_los($x,$y,$hx+$dx,$hy+$dy,$r);
            ++$b if($seen[$x][$y]&2)==0;
            $seen[$x][$y] |= 2;
            $monster{$x,$y}[0]=COLOR_PAIR(COLOR_RED)if exists$monster{$x,$y};
          }
        $seen[$hx+$dx][$hy+$dy]=3;
        }
        delete$monster{$hx+$dx,$hy+$dy};
      }
      else
      {
        pline("You hit the beast.")
      }
      if (($s+=1+$u<<2)>999)
      {
        pline('A voice booms: "Now now, that is quite enough!"');
        pline("You ascend to the status of MilliRogue..");
        pline(" "x60);
        die;
      }
      1
    }
    elsif ($dungeon[$hx+$dx][$hy+$dy] eq '#')
    {
      0
    }
    else
    {
      $hx += $dx;
      $hy += $dy;
      1
    }
  }
}

my $playing = 1;

@commands{qw{ . h j k l
                        y u b n q :
              s 4 2 8 6   
                        7 9 1 3 Q #
              5 260 258 259 261 }} = 
  (sub{1},
   move_generator(-1,  0),
   move_generator( 0,  1),
   move_generator( 0, -1),
   move_generator( 1,  0),
   move_generator(-1, -1),
   move_generator( 1, -1),
   move_generator(-1,  1),
   move_generator( 1,  1),
   sub{$playing=0},
   sub{draw;move 0,0;addstr": ";echo;getnstr($x,76);noecho}
   )x3;

gen_aux 0 for 1..$X*$Y>>4;
sub pline
{
  $l=pop;
  $L = '' if$l eq '';
  move 0, 0;
  if ($L&&length($L.$l)>71)
  {
    draw;
    move 0,0;
    addstr(substr($L,0,-2)."--More--");
    1 until getch=~/[ q\n\r]/;
    move 0,0;
    $L='';
  }
  $L.=$l.'  ' if $l =~ /\S/;
  addstr $L;
  clrtoeol;
}
while ($playing)
{
  gen if$T;
  draw;
  my $c = getch;
  delch;
  insch($dungeon[$hx][$hy]);
  pline("");

  if (exists$commands{$c})
  {
    $t+=$T=$commands{$c}->()
  }
  else
  {
    $T=pline("Huh?");
  }
}

END { endwin }


