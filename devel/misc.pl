#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;

use Smart::Comments;

use lib 'devel/lib';

{
  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (fraction => '5/29',
                                            polygonal => 3);
  my $iter;
  #   $iter = $gen->values_make_pronic(1);
  #   $iter = $gen->values_make_perrin(0);
  #   $iter = $gen->values_make_padovan(0);
  #   $iter = $gen->values_make_twin_primes_2(6,100);
  #   $iter = $gen->values_make_fraction(5,29);
  #   $iter = $gen->values_make_pi_bits();
  #   $iter = $gen->values_make_polygonal();
  # $iter = $gen->values_make_aronson(1, 500);
  #   $iter = $gen->values_make_semi_primes(1,500);
  # $iter = $gen->values_make_pentagonal(1,500);
  # $iter = $gen->values_make_pentagonal_second(1,500);
  # $iter = $gen->values_make_sophie_germain_primes(1,200);
  # my $values_class = $gen->values_class('CountPrimeFactors');
  my $values_class = $gen->values_class('TwinPrimes2');
  my $values_obj = $values_class->new (fraction => '1/3',
                                       polygonal => 3,
                                       lo => 1,
                                       hi => 50);
  $|=1;
  foreach (1 .. 50) {
    my ($n,$count1) = $values_obj->next;
    if (! defined $n) {
      print "undef\n";
      last;
    }
    print "$n,";
    if (defined $count1) {
      print " $count1\n";
    }
  }
  exit 0;
}

{
  require Gtk2;
  Gtk2->init;
  my $toplevel = Gtk2::Window->new('toplevel');
  $toplevel->signal_connect (destroy => sub { Gtk2->main_quit });
  my $ebox = Gtk2::EventBox->new;
  ### border: $ebox->get('border-width')
  my $button = Gtk2::Button->new; # ('button', 0, 100, 1);
  $button->set (relief => 'none');
  # $button->style_set_property
  ### border: $button->get('border-width')
  $toplevel->add ($button);
  my $arrow = Gtk2::Arrow->new ('up', 'out');
  $arrow->set_size_request (5,5);
  ### xpad: $arrow->get('xpad')
  ### ypad: $arrow->get('ypad')
  $button->add ($arrow);
  $toplevel->show_all;
  Gtk2->main;
  exit 0;
}

{
  require App::MathImage::Values::PrimeQuadraticHonaker;
  require B::Concise;
  B::Concise::compile('-exec',\&App::MathImage::Values::PrimeQuadraticHonaker::pred)->();
  exit 0;
}


{
  require Math::Prime::XS;
  local $, = "\n";
  print Math::Prime::XS::sieve_primes(2,3);
  exit 0;
}
{
  require App::MathImage::Values::ChampernowneBinary;
  my $values_obj = App::MathImage::Values::ChampernowneBinary->new;
  print $values_obj->pred(2),"\n";
  print $values_obj->pred(3),"\n";
  print $values_obj->pred(4),"\n";
  # print $values_obj->pred(5),"\n";
  print $values_obj->pred(6),"\n";
  exit 0;
}

{
  # # use Memoize;
  # # memoize('bell_number');
  # my @bell;
  # sub bell_number {
  #   my $n = shift;
  #   if ($n < @bell) {
  #     return $bell[$n];
  #   }
  #   return undef if $n < 0;
  #   return 1     if $n == 0;
  #   my $bell = 0;
  #   for (0 .. $n - 1) {
  #     my $bin = Math::Symbolic::AuxFunctions::binomial_coeff( $n - 1, $_ );
  #     $bell += bell_number($_) * $bin;
  #     ### $bin
  #     ### $bell
  #   }
  #   ### return: $bell
  #   $bell[$n] = $bell;
  #   return $bell;
  # }

  require Math::Symbolic::AuxFunctions;
  foreach my $i (1 .. 50) {
    my $b = Math::Symbolic::AuxFunctions::bell_number($i);
    # my $b = bell_number($i);
    printf "%2d  %f\n", $i, $b;
  }
  exit 0;
}
{
  require Module::Util;
  my @modules = Module::Util::find_in_namespace
    ('App::MathImage::Values');
  ### @modules
  exit 0;
}


{
  require Module::Util;
  my @modules = Module::Util::find_in_namespace('');
  print scalar(@modules),"\n";

  require Pod::Simple::Search;
  my $s = Pod::Simple::Search->new;
  $s->verbose(1);
  # $s->survey;
  print $s->find ('Math::PlanePath::SquareSpiral'),"\n";
  exit 0;
}

{
  require Gtk2;
  my $color = Gtk2::Gdk::Color->new(0x1234, 0x5678, 0x9ABC);
  print $color->to_string,"\n";

  require Gtk2::Ex::Units;
  Gtk2->init;
  print "",Gtk2::Ex::Units::width(Gtk2::Gdk::Screen->get_default,"1mm"),"\n";
  exit 0;
}


{
  sub base3 {
    my ($n) = @_;
    my $str = '';
    while ($n) {
      $str = ($n % 3) . $str;
      $n = int($n/3);
    }
    return $str;
  }
  foreach my $n (1 .. 20) {
    printf "%2d %4s\n", $n, base3($n);
  }

  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (fraction => '5/29',
                                            polygonal => 3);
  my $iter = $gen->values_make_ternary_without_2;
  foreach my $i (1 .. 20) {
    my $count = 0;
    my $n = $iter->();
    printf "%2d %4s\n", $n, base3($n);
  }
  exit 0;
}

{
  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (fraction => '5/29',
                                            polygonal => 3);
  foreach my $limit (2*2, 4*4, 8*8, 16*16) {
    my $iter = $gen->values_make_karatsuba(1,$limit);
    my $count = 0;
    while ($iter->() <= $limit) {
      $count++;
    }
    print "$limit  $count\n";
  }
  exit 0;
}

{
  require Math::Trig;
  my $x;
  foreach (my $i = 1; $i < 10000000; $i++) {
    my $multiple = $i * 7;
    my $r = 0.5/sin(Math::Trig::pi()/$multiple);
    $x //= $r-1;
    if ($r - $x < 1) {
      printf "%2d %3d %8.3f  %6.3f\n", $i, $multiple, $r, $i*$x;
      die $i;
    }
    $x = $r;
  }
  exit 0;
}

{
  require POSIX;
  require Math::Trig;
  my $r = 1;
  my $theta = 0;
  my $ang = 0;
  foreach my $n (1 .. 100) {
    printf "%2d  ang=%.3f  %.3f %.3f %.3f\n",
      $n, $ang, $r, $ang, POSIX::fmod($ang, 2*3.14159);
    $ang = Math::Trig::asin(1/$r) / (2*3.14159);
    $theta += $ang;
    $r += $ang;
  }
  exit 0;
}

{
  require Math::BigInt;
  Math::BigInt->import (try => 'GMP');

  my $k = 2;
  my $bits = 50;
  my $num = Math::BigInt->new($k);
  $num->blsft ($bits);
  ### num: "$num"
  $num->bsqrt();
  ### num: "$num"
  my $str = $num->as_bin;
  ### $str

  $num = Math::BigInt->new(1);
  $num->blsft (length($str)-1);
  ### num: "$num"

  exit 0;
}


{
  require String::Parity;
  require String::BitCount;
  my $i = 0xFFFF01;
  my $s = pack('N', $i);
  $s = "\x{7FF}";
  my $b = [unpack('%32b*', $s)];
  my $p = 0; #String::Parity::isOddParity($s);
  my $c = 0; # String::BitCount::BitCount($s);
  ### $i
  ### $s
  ### $b
  ### $p
  ### $c
  exit 0;
}


{
  require Image::Xpm;
  my $image = Image::Xpm->new (-width => 10,
                               -height => 10);

  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (width => 10,
                                            height => 10,
                                            values => 'Squares',
                                            scale => 1,
                                            foreground => 'white',
                                            background => 'black');
  $gen->draw_Image_start ($image);
  do {
    $image->save ('/dev/stdout');
  } while ($gen->draw_Image_steps (2));
  exit 0;
}

{
  require Path::Class;
  require Scalar::Util;
  my $dir = Path::Class::dir('/', 'tmp');
  ### $dir
  my $reftype = Scalar::Util::reftype($dir);
  ### $reftype
  exit 0;
}
{
  require Scalar::Util;
  @ARGV = ('--values=xyz');
  Getopt::Long::GetOptions
      ('values=s'  => sub {
         my ($name, $value) = @_;
         ### $name
         ### ref: ref($name)
         my $reftype = Scalar::Util::reftype($name);
         ### $reftype
         ### $value
         ### ref: ref($value)
       });
  exit 0;
}

{
  require Getopt::Long;
  require Scalar::Util;
  @ARGV = ('--values=xyz');
  Getopt::Long::GetOptions
      ('values=s'  => sub {
         my ($name, $value) = @_;
         ### $name
         ### ref: ref($name)
         my $reftype = Scalar::Util::reftype($name);
         ### $reftype
         ### $value
         ### ref: ref($value)
       });
  exit 0;
}

{
  my $subr = sub {
    my ($s) = @_;
    return $s*(16*$s - 56) + 50;
     return 3*$s*$s - 4*$s + 2;
    return 2*$s*$s - 2*$s + 2;
    return $s*$s + .5;
    return $s*$s - $s + 1;
    return $s*($s+1)*.5 + 0.5;
  };
  my $back = sub {
    my ($n) = @_;
    return (7 + sqrt($n - 1)) / 4;
    return (2 + sqrt(3*$n - 2)) / 3;
    return .5 + sqrt(.5*$n-.75);
    return sqrt ($n - .5);
    # return -.5 + sqrt(2*$n - .75);
    #    return int((sqrt(4*$n-1) - 1) / 2);
  };
  my $prev = 0;
  foreach (1..15) {
    my $this = $subr->($_);
    printf("%2d  %.2f  %.2f  %.2f\n", $_, $this, $this-$prev,$back->($this));
    $prev = $this;
  }
  for (my $n = 1; $n < 100; $n++) {
    printf "%.2f  %.2f\n", $n,$back->($n);
  }
  exit 0;
}
{
  my $phi = (1 + sqrt(5)) / 2;
  my $phiphi = $phi**2;
  foreach my $i (0 .. 50) {
    my $n = $i * $phiphi;
    printf "%2d  %8.4f  %s\n",
      $i, $n,
      ($n - int($n) < 0.5 ? "X" : "");
  }
  exit 0;
}






{
  my $xs = 'x' x 100_000;
  sub noop {}
  require Devel::TimeThis;
  {
    my $str = $xs;
    my $time = Devel::TimeThis->new('ord1');
    foreach my $i (0 .. length($str)-1) {
      noop (ord(substr($str,$i,1)));
    }
  }
  {
    my $str = $xs;
    my $time = Devel::TimeThis->new('ord all');
    foreach my $i (0 .. length($str)-1) {
      noop (ord(substr($str,$i)));
    }
  }
  {
    my $str = $xs;
    my $time = Devel::TimeThis->new('substr1');
    while ($str) {
      $str = substr ($str, 1);
      noop(ord($str));
    }
    print "$str\n";
  }
  {
    my $str = $xs;
    my $time = Devel::TimeThis->new('4-arg');
    while ($str) {
      substr ($str, 0,1, '');
      noop(ord($str));
    }
    print "$str\n";
  }

  exit 0;
}
{
  require Math::Libm;
  my $pi = Math::Libm::M_PI();
  $pi *= 2**30;
  print $pi,"\n";
  printf ("%b", $pi);
  exit 0;
}


{
  require Math::Libm;
  require Math::PlanePath::VogelFloret;
  my $pathobj = Math::PlanePath::VogelFloret->new;
  my @ns = (1, 4);
  my @points = map { [$pathobj->n_to_xy($_)] } @ns;
  my $min_d = 999;
  my ($min_i, $min_j);
  foreach my $i (0 .. $#points-1) {
    foreach my $j ($i+1 .. $#points) {
      my $d = Math::Libm::hypot ($points[$i]->[0] - $points[$j]->[0],
                                 $points[$i]->[1] - $points[$j]->[1]);
      if ($d < 2) {
        print "$i $j  $d\n";
      }
      if ($d < $min_d) {
        $min_d = $d;
        $min_i = $i;
        $min_j = $j;
      }
    }
  }
  ### @points

  print "i=$min_i  ni=$ns[$min_i],nj=$ns[$min_j]  min_d=$min_d\n";
  print "x $points[$min_i]->[0]  $points[$min_j]->[0],  diff ",
    $points[$min_i]->[0] - $points[$min_j]->[0],"\n";
  print "y $points[$min_i]->[1]  $points[$min_j]->[1],  diff ",
    $points[$min_i]->[1] - $points[$min_j]->[1],"\n";

  #   print "1 to 4   $points[0]->[0],$points[0]->[1]   $points[3]->[0],$points[3]->[1]\n";
  #   print $points[0]->[0] - $points[3]->[0],"\n";
  #   print $points[0]->[1] - $points[3]->[1],"\n";
  exit 0;
}

{
  require Math::PlanePath::SquareSpiral;
  require Math::PlanePath::Diagonals;
  my $path = Math::PlanePath::SquareSpiral->new;
  # my $path = Math::PlanePath::Diagonals->new;
  # print $path->rect_to_n_range (0,0, 5,0);
  foreach (1 .. 1_000_000) {
    $path->n_to_xy ($_);
  }
  exit 0;
}

{
  require Math::Prime::TiedArray;
  tie my @primes, 'Math::Prime::TiedArray';
  local $, = "\n";
  print @primes[0..5000];
  exit 0;
}

{
  require Image::Base;
  require Image::Xbm;
  my $image = Image::Xbm->new (-width => 100,
                               -height => 100);
  $image->ellipse(50,50, 150,150, 1);
  $image->save('/tmp/x.xbm');
  exit 0;
}
{
  require Image::Base;
  require Image::Xpm;
  my $image = Image::Xpm->new (-width => 10,
                               -height => 10);
  $image->ellipse(5,5, 15,15, 'white');
  $image->save('/dev/stdout');
  exit 0;
}



{
  require Math::Fibonacci;
  require POSIX;
  my $phi = (1 + sqrt(5)) / 2;
  foreach my $i (1 .. 1000) {
    my $theta = $i / ($phi*$phi);
    my $frac = $theta - POSIX::floor($theta);
    if ($frac < 0.02 || $frac > 0.98) {
      printf("%2d  %1.3f  %5.3f\n",
             $i, $frac, $theta);
    }
  }
  exit 0;
}

{
  require Math::Fibonacci;
  require POSIX;
  my $phi = (1 + sqrt(5)) / 2;
  foreach my $i (1 .. 40) {
    my $f = Math::Fibonacci::term($i);
    my $theta = $f / ($phi*$phi);
    my $frac = $theta - POSIX::floor($theta);
    printf("%2d  %10.2f  %5.2f  %1.3f  %5.3f\n",
           $i, $f, sqrt($f), $frac, $theta);
  }
  exit 0;
}
{
  require Math::Fibonacci;
  my @f = Math::Fibonacci::series(90);
  local $, = ' ';
  print @f,"\n";

  foreach my $i (1 .. $#f) {
    if ($f[$i] > $f[$i]) {
      print "$i\n";
    }
  }
  my @add = (1, 1);
  for (;;) {
    my $n = $add[-1] + $add[-2];
    if ($n > 2**53) {
      last;
    }
    push @add, $n;
  }
  print "add count ",scalar(@add),"\n";
  foreach my $i (0 .. $#add) {
    if ($f[$i] != $add[$i]) {
      print "diff $i    $f[$i] != $add[$i]    log ",log($add[$i])/log(2),"\n";
    }
  }
  exit 0;
}

{
  require Math::PlanePath::SacksSpiral;
  foreach my $i (0 .. 40) {
    my $n;
    $n = $i*$i + $i;
    $n = $i*$i;
    my ($x, $y) = Math::PlanePath::SacksSpiral->n_to_xy($n);
    printf "%d  %d, %d\n", $i, $x, $y;
  }
  exit 0;
}

{
  require GD;
  require App::MathImage::Generator;
  my $gen = App::MathImage::Generator->new (scale => 20);
  my $gd = GD::Image->new (100,100);
  $gen->draw_GD ($gd);
  require File::Slurp;
  File::Slurp::write_file ('/tmp/x.png', $gd->png);
  system ('xzgv /tmp/x.png');
  exit 0;
}



#     my $count = POSIX::ceil (log($n_pixels * sqrt(5)) / log(PHI));
#     @add = Math::Fibonacci::series ($count);
#     if ($option_verbose) {
#       print "fibonacci $count add to $add[-1]\n";
#     }
