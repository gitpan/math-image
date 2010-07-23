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

package App::MathImage::Generator;
use 5.004;
use strict;
use warnings;
use Carp;
use POSIX ();
use Module::Util;
use List::Util qw(min max);
use App::MathImage::Image::Base::Other;

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 11;

sub new {
  my $class = shift;
  ### Generator new(): @_
  return bless { values     => 'primes',  # defaults
                 path       => 'SquareSpiral',
                 scale      => 1,
                 width      => 10,
                 height     => 10,
                 foreground => 'white',
                 background => 'black',
                 fraction   => '5/29',
                 sqrt       => '2',
                 polygonal  => 6,
                 multiples  => 90,
                 pyramid_step => 2,
                 path_wider   => 0,
                 expression   => '3*x^2 + x + 2',
                 prime_quadratic => 'all',
                 @_ }, $class;
}

use constant values_choices
  => (qw(primes
         twin_primes
         twin_primes_1
         twin_primes_2
         semi_primes
         semi_primes_odd
         squares
         pronic
         triangular
         pentagonal
         pentagonal_second
         pentagonal_generalized
         polygonal
         cubes
         tetrahedral
         perrin
         padovan
         fibonacci
         lucas_numbers
         odd
         even
         all
         pi_bits
         ln2_bits
         fraction_bits
         sqrt_bits
         aronson
         thue_morse_evil
         thue_morse_odious
         champernowne_binary
         champernowne_binary_lsb
         prime_quadratic_euler
         prime_quadratic_legendre
         prime_quadratic_honaker
         multiples),

      (defined (Module::Util::find_installed('Math::Symbolic'))
       ? ('expression') : ()),

      qw(lines),
     );

use constant path_choices => qw(SquareSpiral
                                SacksSpiral
                                VogelFloret
                                DiamondSpiral
                                PentSpiral
                                PentSpiralSkewed
                                HexSpiral
                                HexSpiralSkewed
                                HeptSpiralSkewed
                                TriangleSpiral
                                TriangleSpiralSkewed
                                KnightSpiral
                                PyramidRows
                                PyramidSides
                                PyramidSpiral
                                Corner
                                Diagonals
                                Rows
                                Columns);

sub random_options {
  my @choices;
  foreach my $path (App::MathImage::Generator->path_choices) {
    foreach my $values (App::MathImage::Generator->values_choices) {
      if ($values eq 'all' || $values eq 'odd' || $values eq 'even') {
        next unless $path eq 'SacksSpiral' || $path eq 'VogelFloret';
      }

      # next if $values eq 'perrin' || $values eq 'podovan';

      if ($values eq 'squares') {
        next if $path eq 'Corner'; # just a line across the bottom
      }
      if ($values eq 'pronic') {
        next if $path eq 'PyramidSides' # just a vertical
          || $path eq 'PyramidRows';    # just a vertical
      }
      if ($values eq 'triangular') {
        next if
          $path eq 'Diagonals' # just a line across the bottom
            || $path eq 'DiamondSpiral';  # just a centre horizontal line
      }

      push @choices, [ path => $path, values => $values ];
    }
  }

  my @scales = (1, 3, 5, 10, 15, 20);
  my $scale = $scales[int(rand(scalar(@scales)))];

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);
  my @primes = Math::Prime::XS::sieve_primes(10,100);
  my $num = $primes[int(rand(scalar(@primes)))];
  @primes = grep {$_ != $num} @primes;
  my $den = $primes[int(rand(scalar(@primes)))];

  @primes = Math::Prime::XS::sieve_primes(2,100);
  my $sqrt = $primes[int(rand(scalar(@primes)))];

  my $pyramid_step = 1 + int(rand(20));
  if ($pyramid_step > 12) {
    $pyramid_step = 2;  # most of the time
  }

  my $path_wider = int(rand(30));
  if ($path_wider > 20) {
    $path_wider = 0; # most of the time
  }

  my @prime_quadratic = ('all','primes');
  my $prime_quadratic = $primes[int(rand(scalar(@prime_quadratic)))];

  return (@{$choices[int(rand(scalar(@choices)))]},
          scale     => $scale,
          fraction  => "$num/$den",
          polygonal => (int(rand(20)) + 5), # skip 3=triangular, 4=squares
          sqrt      => $sqrt,
          aronson_conjunctions => int(rand(2)),
          prime_quadratic => $prime_quadratic,
          path_wider   => $path_wider,
          pyramid_step => $pyramid_step,
         );
}

sub get_xpm_string {
  my ($self) = @_;
  my $image = $self->get_Image_Base('Image::Xpm');
  return App::MathImage::Image::Base::Other::save_string($image);
}
sub get_Image_Base {
  my ($self, $image_class) = @_;
  return ($self->{"Image_Base.$image_class"} ||= do {
    $image_class ||= 'Image::Text';
    require Module::Load;
    Module::Load::load ($image_class);
    my $image = $image_class->new
      (-width  => $self->{'width'} * $self->{'scale'},
       -height => $self->{'height'} * $self->{'scale'});
    $self->draw_Image;
    $image
  });
}

sub n_pixels {
  my ($self) = @_;
  ### n_pixels(): $self->{'width'}, $self->{'height'}
  return $self->{'width'} * $self->{'height'};
}

sub path_object {
  my ($self) = @_;
  return ($self->{'path_object'} ||= do {

    my $offset = int ($self->{'scale'} / 2);

    require Module::Load;
    my $path_class = $self->{'path'};
    ### $path_class
    unless ($path_class =~ /::/) {
      foreach my $try_class ("Math::PlanePath::$path_class",
                             "App::MathImage::$path_class") {
        if (eval { Module::Load::load ($try_class); 1 }) {
          $path_class = $try_class;
          last;
        } else {
          ### cannot load: $@
        }
      }
    }

    my $path_object = $path_class->new
      (width  => int($self->{'width'} / $self->{'scale'}),
       height => int($self->{'height'} / $self->{'scale'}),
       step   => $self->{'pyramid_step'},
       wider  => $self->{'path_wider'});

    my $invert = ($self->{'path'} eq 'Rows' || $self->{'path'} eq 'Columns'
                  ? -1
                  : -1);
    my $x_origin = ($path_object->x_negative
                    ? int ($self->{'width'} / 2)
                    : $offset);
    my $y_origin = ($path_object->y_negative
                    ? int ($self->{'height'} / 2)
                    : $invert > 0 ? $offset
                    : $self->{'height'} - $self->{'scale'} + $offset);
    ### x_negative: $path_object->x_negative
    ### y_negative: $path_object->y_negative
    ### $x_origin
    ### $y_origin

    require App::MathImage::Coord;
    $self->{'coord'} = App::MathImage::Coord->new
      (x_origin => $x_origin,
       y_origin => $y_origin,
       x_scale  => $self->{'scale'},
       y_scale  => $self->{'scale'} * $invert);

    ### $path_class
    $path_object
  });
}

sub values_make_expression {
  my ($self, $lo, $hi) = @_;
  require Math::Symbolic;
  my $tree = Math::Symbolic->parse_from_string($self->{'expression'});
  if (! defined $tree) {
    croak "Cannot parse expression: $self->{'expression'}";
  }
  $tree = $tree->simplify;
  my @vars = $tree->signature;
  if (@vars != 1) {
    croak "More than one variable in expression: $self->{'expression'}\n(simplified to $tree)";
  }
  ### code: $tree->to_code
  my ($subr) = $tree->to_sub(\@vars);
  ### $subr

  my $i = 0;
  my $above = 0;
  return sub {
    if ($above >= 10 || $i > $hi) {
      return undef;
    }
    my $n = $subr->($i++);
    ### expression result: $n
    if ($n > $hi) {
      $above++;
    }
    return $n;
  };
}

sub values_make_aronson {
  my ($self, $lo, $hi) = @_;
  require App::MathImage::Aronson;
  my $aronson = App::MathImage::Aronson->new
    (conjunctions => $self->{'aronson_conjunctions'},
     hi => $hi);
  return sub { $aronson->next };
}

# Champernowne sequence in binary 1s and 0s
#   http://www.research.att.com/~njas/sequences/A030190
#
# as integer positions
#   http://www.research.att.com/~njas/sequences/A030310
#
# 1 10  11 100 101  110 111
# 1 2  4,5 6   9,11 12,13 15,16,17,
#
sub values_make_champernowne_binary_lsb {
  my ($self, $lo, $hi) = @_;

  my $val = 0;
  my $bitmask = 1;
  my $n = 0;
  return sub {
    ### $n
    ### $val
    ### $bitmask
    for (;;) {
      if ($bitmask > $val) {
        $val++;
        $bitmask = 1;
        ### $val
      }
      $n++;
      if ($bitmask & $val) {
        $bitmask <<= 1;
        return $n;
      }
      $bitmask <<= 1;
    }
  };
}

# http://www.research.att.com/~njas/sequences/A030303
sub values_make_champernowne_binary {
  my ($self, $lo, $hi) = @_;

  my $val = 0;
  my $bitmask = 0;
  my $n = 0;
  return sub {
    ### $n
    ### $val
    ### $bitmask
    for (;;) {
      if ($bitmask == 0) {
        $val++;
        $bitmask = 1;
        while ($bitmask <= $val) {
          $bitmask <<= 1;
        }
        $bitmask >>= 1;
        ### $val
        ### $bitmask
      }
      $n++;
      if ($bitmask & $val) {
        $bitmask >>= 1;
        return $n;
      }
      $bitmask >>= 1;
    }
  };
}

# http://www.research.att.com/~njas/sequences/A026147
# bit count per example in perlfunc unpack()
sub values_make_thue_morse_evil {
  my ($self, $lo, $hi) = @_;
  my $i = $lo-1;
  return sub {
    for (;;) {
      $i++;
      ### $i
      ### pack: pack('I', $i)
      ### bits: unpack('%32b*', pack('I', $i))
      unless (1 & unpack('%32b*', pack('I', $i))) {
        ### yes
        return $i;
      }
    }
  };
}
# http://www.research.att.com/~njas/sequences/A000069
sub values_make_thue_morse_odious {
  my ($self, $lo, $hi) = @_;
  my $i = $lo-1;
  return sub {
    for (;;) {
      $i++;
      if (1 & unpack('%32b*', pack('I', $i))) {
        return $i;
      }
    }
  };
}

# binary form gets too big to prime check
# sub values_make_binary_primes {
#   my ($self, $lo, $hi) = @_;
# 
#   require Math::Prime::XS;
#   Math::Prime::XS->VERSION (0.020_001);
#   my $i = 1;
#   return sub {
#     for (;;) {
#       $i += 2;
#       if (Math::Prime::XS::is_prime($i)) {
#         return $i;
#       }
#     }
#   };
# }

use constant iter_empty => undef;
sub make_iter_arrayref {
  my ($arrayref) = @_;
  my $i = 0;
  return sub {
    return $arrayref->[$i++];
  };
}

sub values_make_fraction_bits {
  my ($self, $lo, $hi) = @_;
  ### values_make_fraction_bits()
  ### $lo
  ### $hi
  my ($num, $den) = ($self->{'fraction'} =~ m{^\s*(\d+)\s*/\s*(\d+)\s*$})
    or return \&iter_empty;

  if ($num == 0) {
    return \&iter_empty;
  }
  while ($num > $den) {
    $den *= 2;
  }
  my $i = $lo;
  return sub {
    for (;;) {
      ### frac: "$num / $den"
      $i++;
      if ($num >= $den) {
        $num -= $den;
        $num *= 2;
        return $i;
      } else {
        $num *= 2;
      }
    }
  };
}

sub values_make_polygonal {
  my ($self, $lo, $hi) = @_;
  ### values_make_polygonal()
  ### $lo
  ### $hi
  my $k = $self->{'polygonal'};
  if ($k < 3) {
    return make_iter_arrayref ([1]);
  }
  my $i = 0;
  return sub {
    $i++;
    return ($k-2)*$i*($i+1)/2 - ($k-3)*$i;
  };
}

sub values_make_squares {
  my ($self, $lo, $hi) = @_;
  my $i = POSIX::ceil (sqrt (max(0,$lo)));
  return sub {
    return $i++ ** 2;
  };
}

sub values_make_prime_quadratic_euler {
  my ($self, $lo, $hi) = @_;
  my $i = -1;
  return _prime_quadratic_filter ($self, $hi, sub {
                                    $i++;
                                    return ($i + 1)*$i + 41;
                                  });
}
# http://www.research.att.com/~njas/sequences/A007641  (the prime values)
sub values_make_prime_quadratic_legendre {
  my ($self, $lo, $hi) = @_;
  my $i = -1;
  return _prime_quadratic_filter ($self, $hi, sub {
    $i++;
    return 2*$i*$i + 29;
  });
}
# http://www.research.att.com/~njas/sequences/A048988
sub values_make_prime_quadratic_honaker {
  my ($self, $lo, $hi) = @_;
  my $i = -1;
  return _prime_quadratic_filter ($self, $hi, sub {
    $i++;
    return 4*($i + 1)*$i + 59;
  });
}

sub _prime_quadratic_filter {
  my ($self, $hi, $subr) = @_;
  if ($self->{'prime_quadratic'} eq 'primes') {
    require Math::Prime::XS;
    Math::Prime::XS->VERSION (0.020_001);
    my @primes = Math::Prime::XS::sieve_primes (2, $hi);

    my $target = 0;
    return sub {
      for (;;) {
        if (! @primes) { return; }
        if ($primes[0] == $target) {
          $target = $subr->();
          return shift @primes;
        }
        if ($primes[0] > $target) {
          $target = $subr->();
        } else {
          shift @primes;
        }
      }
    };
  }
  # 'all'
  return $subr;
}

sub values_make_multiples {
  my ($self, $lo, $hi) = @_;
  my $i = -1;
  my $m = abs($self->{'multiples'});
  return sub {
    $i++;
    return $self->{'multiples'} * $i;
  };
}

sub values_make_cubes {
  my ($self, $lo, $hi) = @_;
  require Math::Libm;
  my $i = POSIX::ceil (Math::Libm::cbrt (max(0,$lo)));
  return sub {
    return $i++ ** 3;
  };
}
sub values_make_tetrahedral {
  my ($self, $lo, $hi) = @_;
  require Math::Libm;
  my $i = 0;
  return sub {
    $i++;
    return $i*($i+1)*($i+2)/6;
  };
}

sub values_make_triangular {
  my ($self, $lo, $hi) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(1.012); # for Tri()
  my $i = Math::TriangularNumbers::Tri($lo);
  return sub {
    return Math::TriangularNumbers::T($i++);
  };
}

sub values_make_pentagonal {
  my ($self, $lo, $hi) = @_;
  my $i = 0;
  return sub {
    $i++;
    return (3*$i-1)*$i/2;
  };
}
sub values_make_pentagonal_second {
  my ($self, $lo, $hi) = @_;
  my $i = 0;
  return sub {
    $i++;
    return (3*$i+1)*$i/2;
  };
}
sub values_make_pentagonal_generalized {
  my ($self, $lo, $hi) = @_;
  my $i = 0;
  my $neg = 0;
  return sub {
    $neg = ! $neg;
    if ($neg) {
      $i++;
      return (3*-$i+1)*-$i/2;
    } else {
      return (3*$i+1)*$i/2;
    }
  };
}

sub values_make_pronic {
  my ($self, $lo, $hi) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(1.012); # for Tri()

  my $i = pronic_inverse_ceil($lo);
  return sub {
    return 2 * Math::TriangularNumbers::T($i++);
  };
}
sub pronic_inverse_ceil {
  my ($n) = @_;
  require Math::TriangularNumbers;
  Math::TriangularNumbers->VERSION(1.012); # for Tri()
  return Math::TriangularNumbers::Tri(POSIX::ceil($n/2));
}

sub values_make_fibonacci {
  my ($self, $lo, $hi) = @_;
  my $f0 = 1;
  my $f1 = 1;
  return sub {
    (my $ret, $f0, $f1) = ($f0, $f1, $f0+$f1);
    return $ret;
  };
}
sub values_make_lucas_numbers {
  my ($self, $lo, $hi) = @_;
  my $f0 = 1;
  my $f1 = 3;
  return sub {
    (my $ret, $f0, $f1) = ($f0, $f1, $f0+$f1);
    return $ret;
  };
}

sub values_make_perrin {
  my ($self, $lo, $hi) = @_;
  my $p0 = 3;
  my $p1 = 0;
  my $p2 = 2;
  return sub {
    (my $ret, $p0, $p1, $p2) = ($p0, $p1, $p2, $p0+$p1);
    return $ret;
  };
}
sub values_make_padovan {
  my ($self, $lo, $hi) = @_;
  my $p0 = 1;
  my $p1 = 1;
  my $p2 = 1;
  return sub {
    (my $ret, $p0, $p1, $p2) = ($p0, $p1, $p2, $p0+$p1);
    return $ret;
  };
}

sub values_make_all {
  my ($self, $lo, $hi) = @_;
  ### values_make_all()
  ### $lo
  ### $hi
  return sub {
    return $lo++;
  };
}
sub values_make_odd {
  my ($self, $lo, $hi) = @_;
  unless ($lo & 1) { $lo++; }
  $lo -= 2;
  return sub {
    return ($lo += 2);
  };
}
sub values_make_even {
  my ($self, $lo, $hi) = @_;
  if ($lo & 1) { $lo++; }
  $lo -= 2;
  return sub {
    return ($lo += 2);
  };
}

sub values_make_primes {
  my ($self, $lo, $hi) = @_;
  ### values_make_primes(): $lo, $hi
  if ($hi < $lo) {
    return \&iter_empty;
  }
  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);

  # sieve_primes() in 0.20_01 doesn't allow hi==lo
  if ($hi == $lo) {
    if (Math::Prime::XS::is_prime($hi)) {
      return make_iter_arrayref ([$hi]);
    } else {
      return \&iter_empty;
    }
  }
  return make_iter_arrayref([Math::Prime::XS::sieve_primes ($lo, $hi)]);
}
sub values_make_twin_primes {
  my ($self, $lo, $hi) = @_;

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);
  my @primes = Math::Prime::XS::sieve_primes ($lo - 2, $hi);

  my $to = 0;
  for (my $i = 0; $i < $#primes; $i++) {
    if ($primes[$i]+2 == $primes[$i+1]
        || $primes[$i]-2 == $primes[$i-1]) {
      $primes[$to++] = $primes[$i];
    }
  }
  $#primes = $to - 1;
  my $i = 0;
  return sub {
    return $primes[$i++];
  };
}
sub values_make_twin_primes_1 {
  my ($self, $lo, $hi) = @_;

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);
  my @primes = Math::Prime::XS::sieve_primes ($lo, $hi+2);

  my $to = 0;
  foreach my $i (0 .. $#primes - 1) {
    if ($primes[$i]+2 == $primes[$i+1]) {
      $primes[$to++] = $primes[$i];
    }
  }
  $#primes = $to - 1;
  my $i = 0;
  return sub {
    return $primes[$i++];
  };
}

sub values_make_twin_primes_2 {
  my ($self, $lo, $hi) = @_;

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);
  my @primes = Math::Prime::XS::sieve_primes ($lo-2, $hi+2);

  my $to = 0;
  foreach my $i (0 .. $#primes - 1) {
    if ($primes[$i]+2 == $primes[$i+1]) {
      $primes[$to++] = $primes[$i+1];
    }
  }
  $#primes = $to - 1;
  my $i = 0;
  return sub {
    return $primes[$i++];
  };
}

sub values_make_semi_primes {
  my ($self, $lo, $hi) = @_;
  ### values_make_semi_primes(): $lo, $hi
  return _semi_primes ($lo, $hi, 2);
}
sub values_make_semi_primes_odd {
  my ($self, $lo, $hi) = @_;
  return _semi_primes ($lo, $hi, 3);
}
sub _semi_primes {
  my ($lo, $hi, $prime_base) = @_;
  if ($hi < $lo || $hi < $prime_base*$prime_base) {
    return \&iter_empty;
  }
  require Bit::Vector;
  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.020_001);

  my @primes = Math::Prime::XS::sieve_primes ($prime_base,
                                              int($hi/$prime_base));
  my $vec = Bit::Vector->new($hi+1);
  foreach my $i (0 .. $#primes) {
    my $p1 = $primes[$i];
    # $i==$j includes the prime squares
    foreach my $j ($i .. $#primes) {
      if ((my $prod = $p1 * $primes[$j]) <= $hi) {
        $vec->Bit_On($prod);
      } else  {
        last;
      }
    }
  }
  return make_iter_arrayref ([ $vec->Index_List_Read ]);
}

use constant::defer bigint => sub {
  require Math::BigInt;
  Math::BigInt->import (try => 'GMP');
  undef;
};

# FIXME: although this converges much too slowly
sub values_make_ln3 {
  my ($self, $lo, $hi) = @_;

  bigint();
  my $calcbits = int($hi * 1.5 + 20);
  ### $calcbits
  my $total = Math::BigInt->new(0);
  my $num = Math::BigInt->new(1);
  $num->blsft ($calcbits);
  for (my $k = 0; ; $k++) {
    my $den = 2*$k + 1;
    my $q = $num / $den;
    $total->badd ($q);
    #     printf("1 / 4**%-2d * %2d   %*s\n", $k, 2*$k+1,
    #            $calcbits/4+3, $q->as_hex);
    $num->brsft(2);
    if ($num < $den) {
      last;
    }
  }
  #   print $total->as_hex,"\n";
  #   print $total,"\n";
  #   print $total->numify / 2**$bits,"\n";
  return binary_positions($total, $hi);
}

sub values_make_sqrt_bits {
  my ($self, $lo, $hi) = @_;

  my ($s) = ($self->{'sqrt'} =~ m{^\s*(\d+)\s*$})
    or return \&iter_empty;

  bigint();
  my $calcbits = int(2*$hi + 32);
  my $total = Math::BigInt->new(0);
  $s = Math::BigInt->new($s);
  $s->blsft ($calcbits);
  $s->bsqrt();
  return binary_positions($s, $hi);
}

sub binary_positions {
  my ($bignum, $hi) = @_;
  my $str = $bignum->as_bin;
  $str = substr ($str, 2); # trim 0b
  my $pos = -1;
  return sub {
    $pos++;
    for (;;) {
      return if $pos >= length($str);
      if (substr ($str,$pos++,1)) {
        return $pos;
      }
    }
  };
}

sub values_make_pi_bits {
  my ($self, $lo, $hi) = @_;
  return $self->make_gz ($lo, $hi, 'pi');
}
sub values_make_ln2_bits {
  my ($self, $lo, $hi) = @_;
  return $self->make_gz ($lo, $hi, 'ln2');
}
sub make_gz {
  my ($self, $lo, $hi, $file) = @_;

  require Compress::Zlib;
  my $dir = List::Util::first {-e "$_/App/MathImage/$file.gz"} @INC
    or croak "Oops, $file.gz not found";
  my $gz = Compress::Zlib::gzopen("$dir/App/MathImage/$file.gz", "r");

  my $n = 0;
  my $i = 0;
  my $buf = '';
  return sub {
    if ($i >= length($buf)) {
      return if ($gz->gzread($buf) <= 0);
      $i = 0;
    }
    return ($n += ord(substr($buf,$i++,1)));
  };
}

use constant _POINTS_CHUNKS     => 2000;  # 1000 of X,Y
use constant _RECTANGLES_CHUNKS => 2000;  # 500 of X1,Y1,X2,Y2

sub draw_Image_start {
  my ($self, $image) = @_;

  my $width  = $image->get('-width');
  my $height = $image->get('-height');
  my $scale = $self->{'scale'};

  my $foreground = $self->{'foreground'};
  my $background = $self->{'background'};
  if ($image->can('add_colours')) {
    $image->add_colours ($foreground, $background);
  } else {
    ### image cannot add_colours(): ref $image
  }

  # clear
  $image->rectangle (0, 0, $width-1, $height-1, $background, 1);

  my $path = $self->path_object;
  my $coord = $self->{'coord'};

  my ($x1, $y1) = $coord->untransform (-$scale, -$scale);
  my ($x2, $y2) = $coord->untransform ($self->{'width'} + $scale,
                                       $self->{'height'} + $scale);
  ### limits around:
  ### $x1
  ### $x2
  ### $y1
  ### $y2

  my ($n_lo, $n_hi) = $path->rect_to_n_range ($x1,$y1, $x2,$y2);
  ### $n_lo
  ### $n_hi
  $self->{'upto_n'} = $n_lo;
  $self->{'n_hi'} = $n_hi;

  # origin point
  if ($scale >= 3) {
    $image->xy ($coord->transform(0,0), $foreground);
  }

  if ($self->{'values'} ne 'lines') {
    my $values_method = "values_make_$self->{'values'}";
    ### $values_method
    $self->{'values_iter'} = $self->$values_method ($n_lo, $n_hi);
    ### iter: $self->{'values_iter'}
  }
}

sub draw_Image_steps {
  my ($self, $image, $steps) = @_;
  ### draw_Image_steps: $steps
  $steps = (defined $steps ? int($steps)+1 : -1);

  my $width  = $image->get('-width');
  my $height = $image->get('-height');
  ### $width
  ### $height
  my $foreground = $self->{'foreground'};
  my $background = $self->{'background'};
  my $scale = $self->{'scale'};

  my $path = $self->path_object;
  my $figure = ($scale == 1 ? 'point' : $path->figure);
  my $coord = $self->{'coord'};
  my $transform = $coord->transform_proc;

  my @points;
  my @rectangles;

  my $n_hi = $self->{'n_hi'};
  ### $n_hi

  my $more = 0;
  if ($self->{'values'} eq 'lines') {
    my $n = $self->{'upto_n'};

    for ( ; $n < $n_hi; $n++) {
      if ($steps-- == 0) {
        $more = 1;
        last;
      }

      my ($x2, $y2) = $transform->($path->n_to_xy($n));
      $x2 = POSIX::floor ($x2 + 0.5);
      $y2 = POSIX::floor ($y2 + 0.5);

      if (my ($x1, $y1) = $transform->($path->n_to_xy($n-0.499))) {
        $x1 = POSIX::floor ($x1 + 0.5);
        $y1 = POSIX::floor ($y1 + 0.5);
        _image_line_clipped ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground);
      }

      my ($x3, $y3) = $transform->($path->n_to_xy($n+0.499));
      $x3 = POSIX::floor ($x3 + 0.5);
      $y3 = POSIX::floor ($y3 + 0.5);
      _image_line_clipped ($image, $x2,$y2, $x3,$y3, $width,$height, $foreground)
    }
    $self->{'upto_n'} = $n;

  } else {

    my $offset = int($scale/2);
    my $iter = $self->{'values_iter'};
    my $n;
    for (;;) {
      if ($steps-- == 0) {
        $more = 1;
        last;
      }
      defined ($n = $iter->()) && $n <= $n_hi
        or last;
      ### $n
      my ($x, $y) = $path->n_to_xy($n) or next;
      ### path: "$x,$y"

      ($x, $y) = $transform->($x, $y);
      $x = POSIX::floor ($x - $offset + 0.5);
      $y = POSIX::floor ($y - $offset + 0.5);
      ### $x
      ### $y

      if ($figure eq 'point') {
        next if $x < 0 || $y < 0 || $x >= $width || $y >= $height;
        push @points, $x, $y;

        if (@points >= _POINTS_CHUNKS) {
          App::MathImage::Image::Base::Other::xy_points
              ($image, $foreground, @points);
          @points = ();
        }

      } elsif ($figure eq 'square') {
        push @rectangles, rect_clipper ($x, $y, $x+$scale-1, $y+$scale-1,
                                        $width,$height);

        if (@rectangles >= _RECTANGLES_CHUNKS) {
          App::MathImage::Image::Base::Other::rectangles
              ($image, $foreground, 1, @rectangles);
          @rectangles = ();
        }

      } else {
        if (my @coords = ellipse_clipper ($x,$y, $x+$scale-1,$y+$scale-1,
                                          $width,$height)) {
          $image->ellipse (@coords, $foreground);
        }
      }
    }
  }

  ### @points
  App::MathImage::Image::Base::Other::xy_points
      ($image, $foreground, @points);
  App::MathImage::Image::Base::Other::rectangles
      ($image, $foreground, 1, @rectangles);

  return $more;
}

sub draw_Image {
  my ($self, $image) = @_;
  $self->draw_Image_start ($image);
  $self->draw_Image_steps ($image);
}


# draw $image->line() but clipped to width x height
sub _image_line_clipped {
  my ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground) = @_;
  ### _image_line_clipped(): "$x1,$y1 $x2,$y2  ${width}x${height}"
  if (($x1,$y1, $x2,$y2) = line_clipper ($x1,$y1, $x2,$y2, $width,$height)) {
    ### clipped draw: "$x1,$y1 $x2,$y2"
    $image->line ($x1,$y1, $x2,$y2, $foreground);
  }
}

sub ellipse_clipper {
  my ($x1,$y1, $x2,$y2, $width, $height) = @_;

  # Image::Xpm and Xbm have trouble partially off-screen
  return if ($x1 < 0 || $x1 >= $width
             || $x2 < 0 || $x2 >= $width
             || $y1 < 0 || $y1 >= $height
             || $y2 < 0 || $y2 >= $height);
  return ($x1,$y1, $x2,$y2);
}

sub rect_clipper {
  my ($x1,$y1, $x2,$y2, $width,$height) = @_;

  return if ($x1 < 0 && $x2 < 0)
    || ($x1 >= $width && $x2 >= $width)
      || ($y1 < 0 && $y2 < 0)
        || ($y1 >= $height && $y2 >= $height);

  return (max($x1,0),
          max($y1,0),
          min($x2,$width-1),
          min($y2,$height-1));
}

sub line_clipper {
  my ($x1,$y1, $x2,$y2, $width, $height) = @_;

  return if ($x1 < 0 && $x2 < 0)
    || ($x1 >= $width && $x2 >= $width)
      || ($y1 < 0 && $y2 < 0)
        || ($y1 >= $height && $y2 >= $height);

  my $x1new = $x1;
  my $y1new = $y1;
  my $x2new = $x2;
  my $y2new = $y2;
  my $xlen = ($x1 - $x2);
  my $ylen = ($y1 - $y2);

  if ($x1new < 0) {
    $x1new = 0;
    $y1new = POSIX::floor (0.5 + ($y1 * (-$x2)
                                  + $y2 * ($x1)) / $xlen);
    ### x1 neg: "y1new to $x1new,$y1new"
  } elsif ($x1new >= $width) {
    $x1new = $width-1;
    $y1new = POSIX::floor (0.5 + ($y1 * ($x1new-$x2)
                                  + $y2 * ($x1 - $x1new)) / $xlen);
    ### x1 big: "y1new to $x1new,$y1new"
  }
  if ($y1new < 0) {
    $y1new = 0;
    $x1new = POSIX::floor (0.5 + ($x1 * (-$y2)
                                  + $x2 * ($y1)) / $ylen);
    ### y1 neg: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
    ### x1new to: $x1new
  } elsif ($y1new >= $height) {
    $y1new = $height-1;
    $x1new = POSIX::floor (0.5 + ($x1 * ($y1new-$y2)
                                  + $x2 * ($y1 - $y1new)) / $ylen);
    ### y1 big: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
  }
  if ($x1new < 0 || $x1new >= $width) {
    ### x1new outside
    return;
  }

  if ($x2new < 0) {
    $x2new = 0;
    $y2new = POSIX::floor (0.5 + ($y2 * ($x1)
                                  + $y1 * (-$x2)) / $xlen);
    ### x2 neg: "y2new to $x2new,$y2new"
  } elsif ($x2new >= $width) {
    $x2new = $width-1;
    $y2new = POSIX::floor (0.5 + ($y2 * ($x1-$x2new)
                                  + $y1 * ($x2new-$x2)) / $xlen);
    ### x2 big: "y2new to $x2new,$y2new"
  }
  if ($y2new < 0) {
    $y2new = 0;
    $x2new = POSIX::floor (0.5 + ($x2 * ($y1)
                                  + $x1 * (-$y2)) / $ylen);
    ### y2 neg: "x2new to $x2new,$y2new"
  } elsif ($y2new >= $height) {
    $y2new = $height-1;
    $x2new = POSIX::floor (0.5 + ($x2 * ($y1-$y2new)
                                  + $x1 * ($y2new-$y2)) / $ylen);
    ### y2 big: "x2new $x2new,$y2new"
  }
  if ($x2new < 0 || $x2new >= $width) {
    ### x2new outside
    return;
  }

  return ($x1new,$y1new, $x2new,$y2new);
}


1;
__END__
