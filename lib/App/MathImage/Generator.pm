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
use POSIX 'floor', 'ceil';
use Module::Load;
use Module::Util;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';
use App::MathImage::Image::Base::Other;

# uncomment this to run the ### lines
#use Smart::Comments '###','####';

use vars '$VERSION';
$VERSION = 26;

use constant default_options => {
                                 values       => 'Primes',
                                 path         => 'SquareSpiral',
                                 scale        => 1,
                                 width        => 10,
                                 height       => 10,
                                 foreground   => 'white',
                                 background   => 'black',
                                 fraction     => '5/29',
                                 sqrt         => '2',
                                 polygonal    => 5,
                                 multiples    => 90,
                                 aronson_lang         => 'en',
                                 aronson_letter       => '',
                                 aronson_conjunctions => 1,
                                 aronson_lying        => 0,
                                 pyramid_step  => 2,
                                 rings_step    => 6,
                                 path_wider    => 0,
                                 path_rotation => 'phi',
                                 expression    => '3*x^2 + x + 2',
                                 filter        => 'All',
                                };

sub new {
  my $class = shift;
  ### Generator new(): @_
  my $self = bless { %{$class->default_options()}, @_ }, $class;
  if (! defined $self->{'undrawnground'}) {
    $self->{'undrawnground'} = $self->{'background'};
  }
  return $self;
}

# columns_of_pythagoras
use constant values_choices => do {
  my %choices;
  foreach my $module (Module::Util::find_in_namespace
                      ('App::MathImage::Values')) {
    (my $choice = $module) =~ s/^App::MathImage::Values:://;
    $choices{$choice} = 1;
  }
  if (! defined (Module::Util::find_installed('Math::Aronson'))) {
    delete $choices{'Aronson'};
  }
  if (! defined (Module::Util::find_installed('Math::Symbolic'))) {
    delete $choices{'Expression'};
  }
  my @choices;
  foreach my $prefer (qw(Primes
                         CountPrimeFactors
                         TwinPrimes
                         TwinPrimes1
                         TwinPrimes2
                         SophieGermainPrimes
                         SafePrimes
                         SemiPrimes
                         SemiPrimesOdd
                         Squares
                         Pronic
                         Triangular
                         Pentagonal
                         PentagonalSecond
                         PentagonalGeneralized
                         Polygonal
                         Cubes
                         Tetrahedral
                         Perrin
                         Padovan
                         Fibonacci
                         LucasNumbers
                         PellNumbers
                         FractionBits
                         PiBits
                         Ln2Bits
                         SqrtBits
                         Odd
                         Even
                         All
                         Aronson
                         ThueMorseEvil
                         ThueMorseOdious
                         ChampernowneBinary
                         ChampernowneBinaryLsb
                         BinaryLengths
                         PrimeQuadraticEuler
                         PrimeQuadraticLegendre
                         PrimeQuadraticHonaker
                         Multiples
                         Base4Without3
                         TernaryWithout2
                         RepdigitBase10
                         RepdigitAnyBase
                         MobiusFunction
                       )) {
    if (delete $choices{$prefer}) {
      push @choices, $prefer;
    }
  }
  delete $choices{'Lines'};
  push @choices, sort keys %choices;
  push @choices, 'Lines';
  @choices
};

sub values_class {
  my ($class, $values) = @_;
  my $values_class = "App::MathImage::Values::$values";
  Module::Load::load ($values_class);
  return $values_class;
}

use constant path_choices => qw(SquareSpiral
                                SacksSpiral
                                VogelFloret
                                TheodorusSpiral
                                MultipleRings

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
                                Columns

                                ArchimedeanSpiral
                                ReplicatingSquares
                                RotFloret
                              );

sub random_options {
  my @choices;
  foreach my $path (App::MathImage::Generator->path_choices) {
    foreach my $values (App::MathImage::Generator->values_choices) {
      if ($values eq 'All' || $values eq 'Odd' || $values eq 'Even') {
        next unless $path eq 'SacksSpiral' || $path eq 'VogelFloret';
      }

      # next if $values eq 'Perrin' || $values eq 'Padovan';

      if ($values eq 'Squares') {
        next if $path eq 'Corner'; # just a line across the bottom
      }
      if ($values eq 'Pronic') {
        next if $path eq 'PyramidSides' # just a vertical
          || $path eq 'PyramidRows';    # just a vertical
      }
      if ($values eq 'Triangular') {
        next if
          $path eq 'Diagonals' # just a line across the bottom
            || $path eq 'DiamondSpiral';  # just a centre horizontal line
      }

      push @choices, [ path => $path, values => $values ];
    }
  }

  my @scales = (1, 3, 5, 10, 15, 20);
  my $scale = _rand_of_array(\@scales);

  require Math::Prime::XS;
  Math::Prime::XS->VERSION (0.021);
  my @primes = Math::Prime::XS::sieve_primes(10,100);
  my $num = _rand_of_array(\@primes);
  @primes = grep {$_ != $num} @primes;
  my $den = _rand_of_array(\@primes);

  @primes = Math::Prime::XS::sieve_primes(2,100);
  my $sqrt = _rand_of_array(\@primes);

  my $pyramid_step = 1 + int(rand(20));
  if ($pyramid_step > 12) {
    $pyramid_step = 2;  # most of the time
  }

  my $rings_step = int(rand(20));
  if ($rings_step > 15) {
    $rings_step = 6;  # more often
  }

  my $path_wider = _rand_of_array([(0) x 10,   # 0 most of the time
                                   1 .. 20]);

  my $rotation = _rand_of_array(['phi',
                                 'pi',
                                 'sqrt2','sqrt2', # bias extra
                                 'sqrt3',
                                 'sqrt5',
                                 'sqrt7']);

  return (@{_rand_of_array(\@choices)},
          scale     => $scale,
          fraction  => "$num/$den",
          polygonal => (int(rand(20)) + 5), # skip 3=triangular, 4=squares
          sqrt      => $sqrt,
          aronson_lang         => _rand_of_array(['en','fr']),
          aronson_conjunctions => int(rand(2)),
          aronson_lying        => (rand() < .25), # less likely
          filter           => _rand_of_array(['All','All','All',
                                              'All','All','All',
                                              'Odd','Even','Primes']),
          path_wider      => $path_wider,
          path_rotation   => $rotation,
          pyramid_step    => $pyramid_step,
          rings_step      => $rings_step,
         );
}

sub _rand_of_array {
  my ($aref) = @_;
  return $aref->[int(rand(scalar(@$aref)))];
}

use vars '%pathname_has_wider';
%pathname_has_wider = (SquareSpiral       => 1,
                       HexSpiral          => 1,
                       HexSpiralSkewed    => 1,
                       ReplicatingSquares => 1);

sub description {
  my ($self) = @_;
  my $ret = $self->{'path'};
  if ($pathname_has_wider{$self->{'path'}}) {
    if ($self->{'path_wider'}) {
      $ret .= " wider $self->{'path_wider'}";
    }
  } elsif ($self->{'path'} eq 'PyramidRows') {
    $ret .= " step $self->{'pyramid_step'}";
  }

  $ret .= ' ' . $self->values_class($self->{'values'})->name;
  if ($self->{'values'} eq 'Fraction') {
    $ret .= " $self->{'fraction'}";
  } elsif ($self->{'values'} eq 'Expression') {
    $ret .= " $self->{'expression'}";
  } elsif ($self->{'values'} eq 'SqrtBits') {
    $ret .= " $self->{'sqrt'}";
  } elsif ($self->{'values'} eq 'Polygonal') {
    $ret .= " $self->{'polygonal'}";
  } elsif ($self->{'values'} eq 'Multiples') {
    $ret .= " $self->{'multiples'}";
  } elsif ($self->{'values'} eq 'Aronson') {
    my $lang = $self->{'aronson_lang'};
    if ($lang ne default_options()->{'aronson_lang'}) {
      $ret .= " $lang";
    }
    my $default_letter = ($lang eq 'en' ? 'T'
                          : $lang eq 'fr' ? 'E'
                          : '');
    my $letter = $self->{'aronson_letter'};
    if ($letter ne '' && $letter ne $default_letter) {
      $ret .= " \U$letter";
    }
  }
  if ($self->{'filter'} ne 'All') {
    $ret .= __x(" filtered {name}",
                name => $self->values_class($self->{'filter'})->name);
  }

  return $ret . " $self->{'width'}x$self->{'height'} scale $self->{'scale'}";
}

sub path_choice_to_class {
  my ($self, $path) = @_;
  foreach my $class ("Math::PlanePath::$path",
                     "App::MathImage::PlanePath::$path") {
    if (Module::Util::find_installed ($class)) {
      return $class;
    }
  }
  return undef;
}

sub path_object {
  my ($self) = @_;
  return ($self->{'path_object'} ||= do {

    my $scale = $self->{'scale'};
    my $offset = int ($self->{'scale'} / 2);

    my $path_class = $self->{'path'};
    #### $path_class
    my $err = '';
    unless ($path_class =~ /::/) {
      $path_class = $self->path_choice_to_class ($path_class);
    }
    unless (eval { Module::Load::load ($path_class); 1 }) {
      ### cannot load: $@
      croak $err;
    }

    my $path_object = $path_class->new
      (width    => ceil($self->{'width'} / $scale),
       height   => ceil($self->{'height'} / $scale),
       step     => ($path_class eq 'Math::PlanePath::PyramidRows'
                    ? $self->{'pyramid_step'}
                    : $self->{'rings_step'}),
       wider    => $self->{'path_wider'},
       rotation => $self->{'path_rotation'});
    ### $path_object

    my $invert = ($self->{'path'} eq 'Rows' || $self->{'path'} eq 'Columns'
                  ? -1
                  : -1);
    my $x_origin
      = (defined $self->{'x_left'} ? - $self->{'x_left'} * $scale
         : $path_object->x_negative || $self->{'path'} eq 'MultipleRings'
         ? int ($self->{'width'} / 2)
         : $offset);
    my $y_origin
      = (defined $self->{'y_bottom'} ? $self->{'y_bottom'} * $scale + $self->{'height'}
         : $path_object->y_negative || $self->{'path'} eq 'MultipleRings'
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


# binary form gets too big to prime check
# sub values_make_binary_primes {
#   my ($self, $lo, $hi) = @_;
# 
#   require Math::Prime::XS;
#   Math::Prime::XS->VERSION (0.021);
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

sub make_iter_empty {
  my ($self) = @_;
  return $self->make_iter_arrayref([]);
}
sub make_iter_arrayref {
  my ($self, $arrayref) = @_;
  $self->{'iter_arrayref'} = $arrayref;
  my $i = 0;
  return sub {
    return $arrayref->[$i++];
  };
}

# http://www.research.att.com/~njas/sequences/A001333
#    -- sqrt(2) convergents numerators
# http://www.research.att.com/~njas/sequences/A000129
#    -- Pell numbers, sqrt(2) convergents numerators
# http://www.research.att.com/~njas/sequences/A002965
#    -- interleaved
#
# $values_info{'columns_of_pythagoras'} =
#   { subr => \&values_make_columns_of_pythagoras,
#     name => __('Columns of Pythagoras'),
#     # description => __('The ....'),
#   };
sub values_make_columns_of_pythagoras {
  my ($self, $lo, $hi) = @_;
  my $a = 1;
  my $b = 1;
  my $c;
  return sub {
    if (! defined $c) {
      $c = $a + $b;
      return $c;
    } else {
      $b = $a + $c;
      $a = $c;
      undef $c;
      return $b;
    }
  };
}

# prime to test much too big too quickly without some special strategy ...
#
# $values_info{'binary_primes'} =
#   { subr => \&values_make_binary_primes,
#     pred => \&is_binary_prime,
#     name => __('Binary is Decimal Prime'),
#     description => __('Numbers which when written out in binary are a decimal prime.  For example 185 is 10011101 which in decimal is a prime.'),
#   };
# sub values_make_binary_primes {
#   my ($self, $lo, $hi) = @_;
#   require Math::Prime::XS;
#   Math::Prime::XS->VERSION (0.021);
#   my $n = $lo-1;
#   return sub {
#     for (;;) {
#       if (++$n > $hi) {
#         return undef;
#       }
#       if ($self->is_binary_prime($n)) {
#         ### return: $n
#         return $n;
#       }
#     }
#   };
#   # require Math::BaseCnv;
#   # ### primes hi: sprintf('%b', $hi+1)
#   # my @array = map {Math::BaseCnv::cnv($_,2,10)}
#   #   grep {/^[01]+$/}
#   #   Math::Prime::XS::sieve_primes (sprintf('%b', $lo),
#   #                                  sprintf('%b', $hi+1));
#   # @array = @array;
#   # return $self->make_iter_arrayref (\@array);
# }
# sub is_binary_prime {
#   my ($self, $n) = @_;
#   ### $n
#   ### binary: sprintf('%b',$n)
#   # my $p = Math::Prime::XS::is_prime(sprintf('%b',$n));
#   # ### isprime: $p
#   return Math::Prime::XS::is_prime(sprintf('%b',$n))
# }

# use constant::defer bigint => sub {
#   require Math::BigInt;
#   Math::BigInt->import (try => 'GMP');
#   undef;
# };
# 
# # FIXME: although this converges much too slowly
# sub values_make_ln3 {
#   my ($self, $lo, $hi) = @_;
# 
#   bigint();
#   my $calcbits = int($hi * 1.5 + 20);
#   ### $calcbits
#   my $total = Math::BigInt->new(0);
#   my $num = Math::BigInt->new(1);
#   $num->blsft ($calcbits);
#   for (my $k = 0; ; $k++) {
#     my $den = 2*$k + 1;
#     my $q = $num / $den;
#     $total->badd ($q);
#     #     printf("1 / 4**%-2d * %2d   %*s\n", $k, 2*$k+1,
#     #            $calcbits/4+3, $q->as_hex);
#     $num->brsft(2);
#     if ($num < $den) {
#       last;
#     }
#   }
#   #   print $total->as_hex,"\n";
#   #   print $total,"\n";
#   #   print $total->numify / 2**$bits,"\n";
#   return binary_positions($total, $hi);
# }

use constant _POINTS_CHUNKS     => 2000;  # 1000 of X,Y
use constant _RECTANGLES_CHUNKS => 2000;  # 500 of X1,Y1,X2,Y2

sub _path_covers_quads {
  my ($path_object) = @_;

  foreach my $class (qw(PyramidRows)

                     # qw(SquareSpiral
                     #                         PyramidSpiral
                     #                         TriangleSpiral
                     #                         TriangleSpiralSkewed
                     #                         DiamondSpiral
                     #                         PentSpiralSkewed
                     #                         HexSpiral
                     #                         HexSpiralSkewed
                     #                         HeptSpiralSkewed
                     #                         KnightSpiral
                     #
                     #                         Diagonals
                     #                         Corner
                     #                         PyramidSides)
                    ) {
    if ($path_object->isa("Math::PlanePath::$class")) {
      return 0;
    }
  }
  return 1;
}

sub covers_plane {
  my ($self) = @_;
  return ($self->{'background'} eq $self->{'undrawnground'}
          || do {
            my $path = $self->path_object;
            ($path->figure eq 'circle'
             || _path_covers_quads($path))
          });
}

sub colours_grey_exp {
  my ($self) = @_;
  my $colours = $self->{'colours'} = [];
  my @foreground = colour_to_rgb($self->{'foreground'});
  my @background = colour_to_rgb($self->{'background'});
  if (! @foreground) { @foreground = (1.0, 1.0, 1.0); }
  if (! @background) { @background = (0, 0, 0); }
  my $f = 1.0;
  for (;;) {
    push @$colours, sprintf '#%02X%02X%02X',
      map {
        int (0.5 + 255 * ($foreground[$_]*$f + $background[$_]*(1-$f)));
      } 0,1,2;
    last if ($f < 1/255);
    $f = 0.6 * $f;
  }
  ### colours: $self->{'colours'}
}
sub colours_grey_linear {
  my ($self, $n) = @_;
  my $colours = $self->{'colours'} = [];
  foreach my $i (reverse 0 .. $n-1) {
    my $c = 255 * $i / ($n-1);
    push @$colours, sprintf '#%02X%02X%02X', $c, $c, $c;
  }
  ### colours: $self->{'colours'}
}

# seven colours
sub colours_rainbow {
  my ($self) = @_;
  # ROYGBIV
  $self->{'colours'} = [ 'red', 'orange', 'yellow', 'green', 'blue', 'purple', 'violet' ];
  ### colours: $self->{'colours'}
}

# ENHANCE-ME: two shades of each to make radix==6
sub colours_rgb {
  my ($self) = @_;
  $self->{'colours'} = [ 'red', 'green', 'blue' ];
  ### colours: $self->{'colours'}
}

sub colour_to_rgb {
  my ($colour) = @_;
  my $scale;
  if ($colour =~ /^#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})$/i) {
    $scale = 255;
  } elsif ($colour =~ /^#([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})$/i) {
    $scale = 65535;
  } elsif (eval { require Color::Library }
           && (my $c = Color::Library->color($colour))) {
    return map {$_/255} $c->rgb;
  }
  return (hex($1)/$scale, hex($2)/$scale, hex($3)/$scale);
}

sub draw_Image_start {
  my ($self, $image) = @_;

  $self->{'image'} = $image;
  my $width  = $self->{'width'}  = $image->get('-width');
  my $height = $self->{'height'} = $image->get('-height');
  my $scale = $self->{'scale'};
  ### $width
  ### $height

  my $path = $self->path_object;
  my $foreground    = $self->{'foreground'};
  my $background    = $self->{'background'};
  my $undrawnground = $self->{'undrawnground'};
  my $covers = $self->covers_plane;

  my @colours = ($foreground, $background);
  if ($covers) {
    $undrawnground = $background;
  } else {
    push @colours, $undrawnground;
  }

  # clear
  $image->rectangle (0, 0, $width-1, $height-1, $undrawnground, 1);

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
  $self->{'n_prev'} = $n_lo - 1;
  $self->{'upto_n'} = $n_lo;
  $self->{'n_hi'}   = $n_hi;
  $self->{'count_total'}   = 0;
  $self->{'count_outside'} = 0;
  ### $n_lo
  ### $n_hi

  # origin point
  if ($scale >= 3) {
    $image->xy ($coord->transform(0,0), $foreground);
  }

  if ($self->{'values'} ne 'Lines') {
    my $values_class = $self->values_class($self->{'values'});
    my $values_obj = $self->{'values_obj'}
      = $values_class->new (%$self,
                            lo => $n_lo,
                            hi => $n_hi);

    if ($values_obj->type eq 'count1') {
      $self->{'use_count1_iter'} = 1;
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours_offset'} = 0;
        $self->{'colours'} = [ 0 .. 9 ];
      } else {
        $self->{'colours_offset'} = 1;
        # $self->colours_grey_linear(8);
        $self->colours_grey_exp ($self);
      }
      push @colours, @{$self->{'colours'}};
    }
    ### values_obj: $self->{'values_obj'}

    my $filter = $self->{'filter'};
    $self->{'filter_obj'} = $filter &&
      $self->values_class($filter)->new (lo => $n_lo,
                                         hi => $n_hi);
  }

  if ($image->can('add_colours')) {
    $image->add_colours (@colours);
  } else {
    ### image doesn't have add_colours(): ref($image)
  }
}

sub draw_Image_steps {
  my ($self, $steps_limit) = @_;
  #### draw_Image_steps: $steps_limit
  my $steps = 0;

  my $image  = $self->{'image'};
  my $width  = $self->{'width'};
  my $height = $self->{'height'};
  my $foreground = $self->{'foreground'};
  my $background = $self->{'background'};
  my $scale = $self->{'scale'};
  ### $scale

  my $path = $self->path_object;
  my $covers = $self->covers_plane;
  my $coord = $self->{'coord'};
  my $values_obj = $self->{'values_obj'};
  my $filter_obj = $self->{'filter_obj'};

  my $transform = $coord->transform_proc;

  my %points_by_colour;
  my %rectangles_by_colour;
  my $flush = sub {
    #### drawing rectangles flush
    foreach my $colour (keys %points_by_colour) {
      my $aref = delete $points_by_colour{$colour};
      App::MathImage::Image::Base::Other::xy_points
          ($image, $colour, @$aref);
    }
    foreach my $colour (keys %rectangles_by_colour) {
      my $aref = delete $rectangles_by_colour{$colour};
      App::MathImage::Image::Base::Other::rectangles
          ($image, $colour, 1, @$aref);
    }
  };

  my $n_hi = $self->{'n_hi'};

  my $more = 0;
  if ($self->{'values'} eq 'Lines') {
    my $n = $self->{'upto_n'};

    for ( ; $n < $n_hi; $n++) {
      if (defined $steps_limit) {
        if (++$steps > $steps_limit) {
          $more = 1;
          last;
        }
      }

      my ($x2, $y2) = $transform->($path->n_to_xy($n))
        or next;

      if (my ($x1, $y1) = $transform->($path->n_to_xy($n-0.499))) {
        $x1 = floor ($x1 + 0.5);
        $y1 = floor ($y1 + 0.5);
        _image_line_clipped ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground);
      }

      if (my ($x3, $y3) = $transform->($path->n_to_xy($n+0.499))) {
        $x3 = floor ($x3 + 0.5);
        $y3 = floor ($y3 + 0.5);
        _image_line_clipped ($image, $x2,$y2, $x3,$y3, $width,$height, $foreground)
      }
    }
    $self->{'upto_n'} = $n;
    return $more;
  }

  my $n_prev = $self->{'n_prev'};
  my $offset = int($scale/2);
  my $count_total = $self->{'count_total'};
  my $count_outside = $self->{'count_outside'};
  my $figure = ($scale == 1 ? 'point' : $path->figure);
  ### $figure

  my $background_fill_proc;
  if (! $covers && $figure eq 'point') {
    $background_fill_proc = sub {
      my ($n_to) = @_;
      ### background fill
      foreach my $n ($n_prev+1 .. $n_to) {
        $steps++;
        $count_total++;
        my ($x, $y) = $path->n_to_xy($n) or do {
          $count_outside++;
          next;
        };
        ($x, $y) = $transform->($x, $y);
        $x = floor ($x - $offset + 0.5);
        $y = floor ($y - $offset + 0.5);
        ### back_point: $n
        ### $x
        ### $y
        next if ($x < 0 || $y < 0 || $x >= $width || $y >= $height);

        push @{$points_by_colour{$background}}, $x, $y;
        if (@{$points_by_colour{$background}} >= _POINTS_CHUNKS) {
          $flush->();
        }
      }
    };
  } elsif (! $covers && $figure eq 'square') {
    $background_fill_proc = sub {
      my ($n_to) = @_;
      ### background fill
      foreach my $n ($n_prev+1 .. $n_to) {
        $steps++;
        my ($x, $y) = $path->n_to_xy($n) or next;
        ($x, $y) = $transform->($x, $y);
        ### back_rectangle: $n
        ### $x
        ### $y
        $x = floor ($x - $offset + 0.5);
        $y = floor ($y - $offset + 0.5);
        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$scale-1, $y+$scale-1,
                                 $width,$height)
          or do {
            $count_outside++;
            next;
          };
        push @{$rectangles_by_colour{$background}}, @rect;
        if (@{$rectangles_by_colour{$background}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }
      }
    };
  } else {
    ### background_fill_proc is noop
    $background_fill_proc = \&_noop;
  }

  if ($self->{'use_xy'}) {
    my $colours = $self->{'colours'};
    my $colours_offset = $self->{'colours_offset'};
    my $x    = $self->{'x'};
    my $x_hi = $self->{'x_hi'};
    my $y    = $self->{'y'};
    my $type_count1 = $values_obj->type eq 'count1';
    my $colour = $foreground;
    my $n;
    #### draw by xy: $type_count1, $values_obj->type
    #### xy from: "$x,$y"

    for (;;) {
      ### use_xy: "$x,$y"
      if (defined $steps_limit) {
        if (++$steps > $steps_limit) {
          $more = 1;
          last;
        }
      }
      if (++$x > $x_hi) {
        if (++$y > $self->{'y_hi'}) {
          last;
        }
        $x = $self->{'x_lo'};
        #### next row: "$x,$y"
      }

      if (! defined ($n = $path->xy_to_n ($x, $y))) {
        next; # no N for this x,y
      }
      #### path: "$x,$y  $n"

      my $count1 = $values_obj->pred($n);
      #### $count1
      if (! $count1 || ! $filter_obj->pred($n)) {
        if (! $covers) {
          ##### background fill

          my ($wx, $wy) = $transform->($x, $y);
          $wx = floor ($wx - $offset + 0.5);
          $wy = floor ($wy - $offset + 0.5);
          ### win: "$wx,$wy"

          if ($figure eq 'point') {
            push @{$points_by_colour{$background}}, $wx, $wy;
            if (@{$points_by_colour{$background}} >= _POINTS_CHUNKS) {
              $flush->();
            }
          } else { # $figure eq 'square'
            push @{$rectangles_by_colour{$background}},
              rect_clipper ($wx, $wy,
                            $wx+$scale-1, $wy+$scale-1,
                            $width,$height);
            if (@{$rectangles_by_colour{$background}} >= _RECTANGLES_CHUNKS) {
              $flush->();
            }
          }
        }
        next;
      }

      my ($wx, $wy) = $transform->($x, $y);
      $wx = floor ($wx - $offset + 0.5);
      $wy = floor ($wy - $offset + 0.5);
      ### win: "$wx,$wy"

      if ($type_count1) {
        $colour = $colours->[min ($#$colours,
                                  max (0, $count1 - $colours_offset))];
        #### $colour
      }
      if ($figure eq 'point') {
        push @{$points_by_colour{$colour}}, $wx, $wy;
        if (@{$points_by_colour{$colour}} >= _POINTS_CHUNKS) {
          $flush->();
        }

      } else { # $figure eq 'square'
        push @{$rectangles_by_colour{$colour}},
          rect_clipper ($wx, $wy,
                        $wx+$scale-1, $wy+$scale-1,
                        $width,$height);
        if (@{$rectangles_by_colour{$colour}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }
      }
    }
    $self->{'x'} = $x;
    $self->{'y'} = $y;

  } elsif ($self->{'use_count1_iter'}) {
    #### draw by count1_iter
    my $colours = $self->{'colours'};
    my $colours_offset = $self->{'colours_offset'};
    # my $xy_bitvector = $self->{'xy_bitvector'};;

    for (;;) {
      if (defined $steps_limit) {
        if (++$steps > $steps_limit) {
          $more = 1;
          last;
        }
      }
      my ($n, $count1) = $values_obj->next
        or last;
      last if $n > $n_hi;
      #### $n
      #### $count1
      next if ! defined $count1;

      if ($count1 && ! $filter_obj->pred($n)) {
        next;
      }

      my ($x, $y) = $path->n_to_xy($n) or next;
      #### path: "$x, $y"

      ($x, $y) = $transform->($x, $y);
      $x = floor ($x - $offset + 0.5);
      $y = floor ($y - $offset + 0.5);
      #### transformed: "$x, $y"

      my $colour = $colours->[min ($#$colours,
                                   max (0, $count1 - $colours_offset))];
      #### $colour

      if ($figure eq 'point') {
        $count_total++;
        if ($x < 0 || $y < 0 || $x >= $width || $y >= $height) {
          $count_outside++;
          next;
        }
        $image->xy ($x, $y, $colour);

      } elsif ($figure eq 'square') {
        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$scale-1, $y+$scale-1,
                                 $width,$height)
          or do {
            $count_outside++;
            next;
          };
        push @{$rectangles_by_colour{$colour}}, @rect;
        if (@{$rectangles_by_colour{$colour}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }

      } else { # circle
        if (my @coords = ellipse_clipper ($x,$y, $x+$scale-1,$y+$scale-1,
                                          $width,$height)) {
          $image->ellipse (@coords, $colour);
        }
      }
    }

    ##### $count_total
    ##### $count_outside
    if ($figure ne 'circle'
        && $count_total > 1000
        && $count_outside > .5 * $count_total
        && $values_obj->can('pred')
       ) {
      #### use_xy from now on
      $self->use_xy($image);
    } else {
      # $self->{'n_prev'} = $n;
      $self->{'count_total'} = $count_total;
      $self->{'count_outside'} = $count_outside;
    }

  } else {
    #### draw by N
    my $n;

    for (;;) {
      if (defined $steps_limit) {
        if (++$steps > $steps_limit) {
          $more = 1;
          last;
        }
      }
      ($n, undef) = $values_obj->next;
      ### $n_prev
      ### $n
      if (! defined $n || $n > $n_hi) {
        ### final background fill
        $background_fill_proc->($n_hi);
        last;
      }
      $filter_obj->pred($n)
        or next;
      my ($x, $y) = $path->n_to_xy($n) or next;
      ### path: "$x,$y"

      ($x, $y) = $transform->($x, $y);
      $x = floor ($x - $offset + 0.5);
      $y = floor ($y - $offset + 0.5);
      ### $x
      ### $y

      if ($figure eq 'point') {
        $background_fill_proc->($n-1);

        $count_total++;
        if ($x < 0 || $y < 0 || $x >= $width || $y >= $height) {
          $count_outside++;
          next;
        }
        push @{$points_by_colour{$foreground}}, $x, $y;
        if (@{$points_by_colour{$foreground}} >= _POINTS_CHUNKS) {
          $flush->();
        }

      } elsif ($figure eq 'square') {
        $background_fill_proc->($n-1);

        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$scale-1, $y+$scale-1,
                                 $width,$height)
          or do {
            $count_outside++;
            next;
          };
        push @{$rectangles_by_colour{$foreground}}, @rect;
        if (@{$rectangles_by_colour{$foreground}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }

      } else {
        if (my @coords = ellipse_clipper ($x,$y, $x+$scale-1,$y+$scale-1,
                                          $width,$height)) {
          $image->ellipse (@coords, $foreground);
        }
      }

      $n_prev = $n;
    }

    ##### $count_total
    ##### $count_outside
    if ($figure ne 'circle'
        && $count_total > 1000
        && $count_outside > .5 * $count_total
        && $values_obj->can('pred')
       ) {
      ### use_xy from now on
      $self->use_xy($image);
    } else {
      $self->{'n_prev'} = $n_prev;
      $self->{'count_total'} = $count_total;
      $self->{'count_outside'} = $count_outside;
    }
  }

  $flush->();
  ### $more
  return $more;
}

sub use_xy {
  my ($self, $image) = @_;
  # print "use_xy from now on\n";
  $self->{'use_xy'} = 1;

  my $coord = $self->{'coord'};
  my $width  = $image->get('-width');
  my $height = $image->get('-height');

  my ($x_lo, $y_hi) = $coord->untransform (0,0);
  my ($x_hi, $y_lo) = $coord->untransform ($width,$height);
  $x_lo = floor($x_lo);
  $y_lo = floor($y_lo);
  $x_hi = ceil($x_hi);
  $y_hi = ceil($y_hi);
  my $path_obj = $self->path_object;
  if (! $path_obj->x_negative) {
    $x_lo = max (0, $x_lo);
    $x_hi = max (0, $x_hi);
  }
  if (! $path_obj->y_negative) {
    $y_lo = max (0, $y_lo);
    $y_hi = max (0, $y_hi);
  }
  $self->{'x_lo'} = $x_lo;
  $self->{'y_lo'} = $y_lo;
  $self->{'x_hi'} = $x_hi;
  $self->{'y_hi'} = $y_hi;

  $self->{'x'} = $x_lo - 1;
  $self->{'y'} = $y_lo;
  #### x: "$x_lo to $x_hi start $self->{'x'}"
  #### y: "$y_lo to $y_hi start $self->{'y'}"

  my $x_width = $self->{'x_width'} = $x_hi - $x_lo + 1;
  $self->{'xy_total'} = ($y_hi - $y_lo + 1) * $x_width;
}

sub _noop {}

sub draw_progress_fraction {
  my ($self) = @_;
  if ($self->{'use_xy'}) {
    return (($self->{'x'} - $self->{'x_lo'})
            + ($self->{'y'} - $self->{'y_lo'}) * $self->{'x_width'})
      / $self->{'xy_total'};
  } else {
    return $self->{'n_prev'} / $self->{'n_hi'};
  }
}

sub draw_Image {
  my ($self, $image) = @_;
  $self->draw_Image_start ($image);
  $self->draw_Image_steps;
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
    $y1new = floor (0.5 + ($y1 * (-$x2)
                                  + $y2 * ($x1)) / $xlen);
    ### x1 neg: "y1new to $x1new,$y1new"
  } elsif ($x1new >= $width) {
    $x1new = $width-1;
    $y1new = floor (0.5 + ($y1 * ($x1new-$x2)
                                  + $y2 * ($x1 - $x1new)) / $xlen);
    ### x1 big: "y1new to $x1new,$y1new"
  }
  if ($y1new < 0) {
    $y1new = 0;
    $x1new = floor (0.5 + ($x1 * (-$y2)
                                  + $x2 * ($y1)) / $ylen);
    ### y1 neg: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
    ### x1new to: $x1new
  } elsif ($y1new >= $height) {
    $y1new = $height-1;
    $x1new = floor (0.5 + ($x1 * ($y1new-$y2)
                                  + $x2 * ($y1 - $y1new)) / $ylen);
    ### y1 big: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
  }
  if ($x1new < 0 || $x1new >= $width) {
    ### x1new outside
    return;
  }

  if ($x2new < 0) {
    $x2new = 0;
    $y2new = floor (0.5 + ($y2 * ($x1)
                                  + $y1 * (-$x2)) / $xlen);
    ### x2 neg: "y2new to $x2new,$y2new"
  } elsif ($x2new >= $width) {
    $x2new = $width-1;
    $y2new = floor (0.5 + ($y2 * ($x1-$x2new)
                                  + $y1 * ($x2new-$x2)) / $xlen);
    ### x2 big: "y2new to $x2new,$y2new"
  }
  if ($y2new < 0) {
    $y2new = 0;
    $x2new = floor (0.5 + ($x2 * ($y1)
                                  + $x1 * (-$y2)) / $ylen);
    ### y2 neg: "x2new to $x2new,$y2new"
  } elsif ($y2new >= $height) {
    $y2new = $height-1;
    $x2new = floor (0.5 + ($x2 * ($y1-$y2new)
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
