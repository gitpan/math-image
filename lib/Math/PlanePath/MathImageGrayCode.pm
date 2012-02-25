# N as gray
# X,Y change by one bit each time





# Copyright 2011, 2012 Kevin Ryde

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



# math-image --path=MathImageGrayCode,encode_type=N --all --output=numbers_dash --size=28x19
# math-image --path=MathImageGrayCode,radix=3 --all --output=numbers

# A105529,A105530 ternary gray code, in decimal
# A006068 gray code inverse, in decimal
# A003188 gray code, in decimal
# A014550 gray code, in binary


package Math::PlanePath::MathImageGrayCode;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 95;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_min = \&Math::PlanePath::_min;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

use Math::PlanePath::ZOrderCurve;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant n_start => 0;
use constant class_x_negative => 0;
use constant class_y_negative => 0;

use constant parameter_info_array =>
  [
   { name      => 'encode_type',
     type      => 'enum',
     default   => 'N',
     choices   => ['N','XY','Z_N','Z_XY'],
   },
   # { name      => 'gray_type',
   #   type      => 'enum',
   #   default   => 'reversed',
   #   choices   => ['reversed','cyclic'],
   # },
   # { name      => 'radix',
   #   share_key => 'radix_2',
   #   type      => 'integer',
   #   minimum   => 2,
   #   default   => 2,
   #   width     => 3,
   # },
  ];

my %n_func = (N  => \&_to_gray,
              XY => \&_from_gray);
my %xy_func = (Z_N  => \&_to_gray,
               Z_NXY => \&_from_gray);
my %inverse_n_func = (N  => \&_from_gray,
                      XY => \&_to_gray);
my %inverse_xy_func = (Z_N  => \&_from_gray,
                       Z_NXY => \&_to_gray);

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 2;
  }

  $self->{'encode_type'} ||= 'N';
  ### encode_type: $self->{'encode_type'}

  $self->{'n_func'} = $n_func{$self->{'encode_type'}};
  $self->{'xy_func'} = $xy_func{$self->{'encode_type'}};
  $self->{'inverse_n_func'} = $inverse_n_func{$self->{'encode_type'}};
  $self->{'inverse_xy_func'} = $inverse_xy_func{$self->{'encode_type'}};
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### GrayCode n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: N and N+1 differ by not much ...
    my $int = int($n);
    ### $int
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      ### $frac
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  if (my $func = $self->{'n_func'}) {
    $n = &$func($n);
  }
  if (my $func = $self->{'xy_func'}) {
    my ($x,$y) = $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
    return (&$func($x), &$func($y));
  } else {
    return $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
  }


  # $x = _to_gray($x);
  # $y = _to_gray($y);
  # return ($x,$y);
  # # 160 161 165 164 181 180 176 177 245 244 240
  # # 168 169 173 172 189 188 184 185 253 252 248
  # # 170 171 175 174 191 190 186 187 255 254 250
  # #  34  35  39  38  55  54  50  51 119 118 114
  # #  32  33  37  36  53  52  48  49 117 116 112
  # #  40  41  45  44  61  60  56  57 125 124 120
  # #  42  43  47  46  63  62  58  59 127 126 122
  # #   8   9  13  12  29  28  24  25  93  92  88
  # #  10  11  15  14  31  30  26  27  95  94  90
  # #   2   3   7   6  23  22  18  19  87  86  82
  # #   0   1   5   4  21  20  16  17  85  84  80
  # 
  # my ($x,$y) = $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
  # $x = _from_gray($x);
  # $y = _from_gray($y);
  # return ($x,$y);
  # # 170 171 175 174 190 191 187 186 250 251 255
  # # 162 163 167 166 182 183 179 178 242 243 247
  # # 160 161 165 164 180 181 177 176 240 241 245
  # #  32  33  37  36  52  53  49  48 112 113 117
  # #  34  35  39  38  54  55  51  50 114 115 119
  # #  42  43  47  46  62  63  59  58 122 123 127
  # #  40  41  45  44  60  61  57  56 120 121 125
  # #   8   9  13  12  28  29  25  24  88  89  93
  # #  10  11  15  14  30  31  27  26  90  91  95
  # #   2   3   7   6  22  23  19  18  82  83  87
  # #   0   1   5   4  20  21  17  16  80  81  85
  # 
  # # Gray F
  # $n = _to_gray($n);
  # my ($x,$y) = $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
  # $x = _from_gray($x);
  # $y = _from_gray($y);
  # return ($x,$y);
  # # 204 205 202 203 212 213 210 211 172 173 170
  # # 195 194 197 196 219 218 221 220 163 162 165
  # # 192 193 198 199 216 217 222 223 160 161 166
  # #  63  62  57  56  39  38  33  32  95  94  89
  # #  60  61  58  59  36  37  34  35  92  93  90
  # #  51  50  53  52  43  42  45  44  83  82  85
  # #  48  49  54  55  40  41  46  47  80  81  86
  # #  15  14   9   8  23  22  17  16 111 110 105
  # #  12  13  10  11  20  21  18  19 108 109 106
  # #   3   2   5   4  27  26  29  28  99  98 101
  # #   0   1   6   7  24  25  30  31  96  97 102
  # 
  # # Gray B same as F
  # $n = _from_gray($n);
  # my ($x,$y) = $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
  # return ($x,$y);
  # # 204 205 202 203 212 213 210 211 172 173 170
  # # 195 194 197 196 219 218 221 220 163 162 165
  # # 192 193 198 199 216 217 222 223 160 161 166
  # #  63  62  57  56  39  38  33  32  95  94  89
  # #  60  61  58  59  36  37  34  35  92  93  90
  # #  51  50  53  52  43  42  45  44  83  82  85
  # #  48  49  54  55  40  41  46  47  80  81  86
  # #  15  14   9   8  23  22  17  16 111 110 105
  # #  12  13  10  11  20  21  18  19 108 109 106
  # #   3   2   5   4  27  26  29  28  99  98 101
  # #   0   1   6   7  24  25  30  31  96  97 102
  # 
  # # Gray A
  # $n = _to_gray($n);
  # my ($x,$y) = $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);
  # return ($x,$y);
  # # 240 241 247 246 239 238 232 233 143 142 136
  # # 252 253 251 250 227 226 228 229 131 130 132
  # # 255 254 248 249 224 225 231 230 128 129 135
  # #  51  50  52  53  44  45  43  42  76  77  75
  # #  48  49  55  54  47  46  40  41  79  78  72
  # #  60  61  59  58  35  34  36  37  67  66  68
  # #  63  62  56  57  32  33  39  38  64  65  71
  # #  12  13  11  10  19  18  20  21 115 114 116
  # #  15  14   8   9  16  17  23  22 112 113 119
  # #   3   2   4   5  28  29  27  26 124 125 123
  # #   0   1   7   6  31  30  24  25 127 126 120
  # 
  # 
  # $n = _from_gray($n);
  # return $self->Math::PlanePath::ZOrderCurve::n_to_xy($n);



  # my $radix = $self->{'radix'};
  # my @digits;
  # while ($n) {
  #   push @digits, ($n % $radix);
  #   $n = int($n/$radix);
  #   push @digits, ($n % $radix);
  #   $n = int($n/$radix);
  # }
  # 
  # my $x = my $y = ($n * 0);  # inherit bignum 0
  # my $rev = 0;
  # my $radix_minus_1 = $radix - 1;
  # 
  # while (@digits) {
  #   {
  #     my $digit = pop @digits;  # high to low
  #     if ($rev & 1) {
  #       $y = $y * $radix + $radix_minus_1 - $digit;
  #     } else {
  #       $y = $y * $radix + $digit;
  #     }
  #     $rev ^= $digit;
  #   }
  #   {
  #     my $digit = pop @digits;
  #     if ($rev & 1) {
  #       $x = $x * $radix + $radix_minus_1 - $digit;
  #     } else {
  #       $x = $x * $radix + $digit;
  #     }
  #     $rev ^= $digit;
  #   }
  # }
  # return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### GrayCode xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  if (my $func = $self->{'inverse_xy_func'}) {
    $x = &$func($x);
    $y = &$func($y);
  }
  my $n = $self->Math::PlanePath::ZOrderCurve::xy_to_n($x,$y);
  if (my $func = $self->{'inverse_n_func'}) {
    return &$func($n);
  } else {
    return $n;
  }
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  my $radix = $self->{'radix'};
  my ($pow_max) = _round_down_pow (_max($x2,$y2),
                                   $radix);
  $pow_max *= $radix;
  return (0,
          $pow_max*$pow_max - 1);
}

sub _to_gray {
  my ($n) = @_;
  ### _to_gray(): $n
  return ($n >> 1) ^ $n;
}

sub _from_gray {
  my ($n) = @_;
  ### _from_gray(): $n
  my $shift = 1; 
  for (;;) {
    my $xor = ($n >> $shift) || return $n;
    $n ^= $xor;
    $shift *= 2;
  }

  # my @digits;
  # while ($n) {
  #   push @digits, $n & 1;
  #   $n >>= 1;
  # }
  # my $xor = 0;
  # my $ret = 0;
  # while (@digits) {
  #   my $digit = pop @digits;
  #   $ret <<= 1;
  #   $ret |= $digit^$xor;
  #   $xor ^= $digit;
  # }
  # return $ret;
}

1;
__END__

=for stopwords Ryde Math-PlanePath eg Radix radix ie

=head1 NAME

Math::PlanePath::MathImageGrayCode -- Gray code coordinates

=head1 SYNOPSIS

 use Math::PlanePath::MathImageGrayCode;

 my $path = Math::PlanePath::MathImageGrayCode->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress...>

N

      7  |  63-62 57-56 39-38 33-32
         |      |  |        |  |   
      6  |  60-61 58-59 36-37 34-35
         |                         
      5  |  51-50 53-52 43-42 45-44
         |      |  |        |  |   
      4  |  48-49 54-55 40-41 46-47
         |                         
      3  |  15-14  9--8 23-22 17-16
         |      |  |        |  |   
      2  |  12-13 10-11 20-21 18-19
         |                         
      1  |   3--2  5--4 27-26 29-28
         |      |  |        |  |   
     Y=0 |   0--1  6--7 24-25 30-31
         |
         +-------------------------
           X=0  1  2  3  4  5  6  7

=head2 XY

For the XY form the X and Y coordinates are Gray codes generated from N.
Integer N is converted to its Gray code and that code is split by bits to
give X and Y.

      7  |  51-50 52-53 44-45 43-42
         |      |     |     |     |
      6  |  48-49 55-54 47-46 40-41
         |                         
      5  |  60-61 59-58 35-34 36-37
         |      |     |     |     |
      4  |  63-62 56-57 32-33 39-38
         |                         
      3  |  12-13 11-10 19-18 20-21
         |      |     |     |     |
      2  |  15-14  8--9 16-17 23-22
         |                         
      1  |   3--2  4--5 28-29 27-26
         |      |     |     |     |
     Y=0 |   0--1  7--6 31-30 24-25
         |  
         +-------------------------
           X=0  1  2  3  4  5  6  7

A change N to N+1 is a single bit change in its Gray code, and therefore a
single bit change in one of X or Y.  For example N=19 to N=20 is a change
from X=4 to X=6, a single bit change.  An increment can also turn off a bit,
as for example N=23 to N=24 changes from Y=2 to Y=0.


Z_N

      7  | 34-35 39-38 55-54 50-51
         |   \     /     /     \  
      6  | 32-33 37-36 53-52 48-49
         |                        
      5  | 40-41 45-44 61-60 56-57
         |   /     \     \     /  
      4  | 42-43 47-46 63-62 58-59
         |                        
      3  |  8--9 13-12 29-28 24-25
         |   /     \     \     /  
      2  | 10-11 15-14 31-30 26-27
         |                        
      1  |  2--3  7--6 23-22 18-19
         |   \     /     /     \  
     Y=0 |  0--1  5--4 21-20 16-17
         |
         +-------------------------
           X=0 1  2  3  4  5  6  7

Z_XY

      7  | 42-43 46-47 58-59 62-63
         |   \  \  \     \  \  \  
      6  | 40-41 44-45 56-57 60-61
         |                        
      5  | 34-35 38-39 50-51 54-55
         |   \  \  \     \  \  \  
      4  | 32-33 36-37 48-49 52-53
         |                        
      3  | 10-11 14-15 26-27 30-31
         |   \  \  \     \  \  \  
      2  |  8--9 12-13 24-25 28-29
         |                        
      1  |  2--3  6--7 18-19 22-23
         |   \  \  \     \  \  \  
     Y=0 |  0--1  4--5 16-17 20-21
         |
         +-------------------------
           X=0 1  2  3  4  5  6  7

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageGrayCode-E<gt>new ()>

Create and return a new path object.  The optional C<radix> parameter gives
the base for digit splitting (the default is binary, radix 2).

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=cut
