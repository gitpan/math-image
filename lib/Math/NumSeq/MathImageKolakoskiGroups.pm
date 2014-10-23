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


package Math::NumSeq::MathImageKolakoskiGroups;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 90;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::Kolakoski;

# uncomment this to run the ### lines
#use Smart::Comments;


# use constant description =>
#   Math::NumSeq::__('...');

use constant characteristic_increasing => 0;
sub characteristic_integer {
  my ($self) = @_;
  return (($self->{'length'} % 2) == 1);  # odd lengths are integers
}
use constant values_min => 1;
use constant values_max => 2;
use constant i_start => 1;
use constant parameter_info_array =>
  [
   { name      => 'length',
     display   => Math::NumSeq::__('Group Length'),
     share_key => 'length_groups',
     type      => 'integer',
     default   => '3',
     minimum   => 1,
     description => Math::NumSeq::__('Group size for majority.'),
   },
  ];

my @oeis_anum;
$oeis_anum[7] = 'A074295';
# OEIS-Catalogue: A074295 length=7
#
# A074292 - groups 3, starts n=0
# A074293 - groups 5, starts n=0
# # $oeis_anum[3] = 'A074292';
# # $oeis_anum[5] = 'A074293';
# # OEIS-Catalogue: A074292
# # OEIS-Catalogue: A074293 length=5


sub oeis_anum {
  my ($self) = @_;
  ### $self
  return $oeis_anum[$self->{'length'}];
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
  $self->{'kolseq'} = Math::NumSeq::Kolakoski->new;
}

sub next {
  my ($self, $i) = @_;
  ### KolakoskiGroups ith(): $i

  my @got = (undef, 0,0);
  foreach (1 .. $self->{'length'}) {
    my ($ki,$value) = $self->{'kolseq'}->next;
    $got[$value]++;
  }
  ### @got
  return ($self->{'i'}++, (($got[2] <=> $got[1]) + 3)/2);
}

1;
__END__


  # my $pending = $self->{'pending'};
  # # unless (@$pending) {
  # #   push @$pending, ($self->{'digit'}) x $self->{'digit'};
  # #   # ($self->{'digit'} ^= 3);
  # # }
  # my $ret = shift @$pending;
  # ### $ret
  # ### append: ($self->{'digit'} ^ 3)
  # 
  # push @$pending, (($self->{'digit'} ^= 3) x $ret);
  # 
  # # A025142
  # # push @$pending, (($self->{'digit'}) x $ret);
  # # $self->{'digit'} ^= 3;
  # 
  # ### now pending: @$pending
  # return ($self->{'i'}++, $ret);


=for stopwords Ryde Math-NumSeq Kolakoski

=head1 NAME

Math::NumSeq::MathImageKolakoskiGroups -- majority value in groups of Kolakoski values

=head1 SYNOPSIS

 use Math::NumSeq::MathImageKolakoskiGroups;
 my $seq = Math::NumSeq::MathImageKolakoskiGroups->new (length => 3);
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is the majority value in the Kolakoski sequence grouped into threes, or
a given C<length> runs.

    Kolakoski: 1,2,2, 1,1,2, 1,2,2, 1,2,2, ...

    majority:    2,     1,     2,     2,

Groups of length 1 will just give the Kolakoski itself.

In the current code groups of an even length are allowed, and if there's an
equal number of 1s and 2s in a group then the "majority" is reckoned as 1.5,
half way between the two.  Is that a good idea?  Don't depend on even
lengths just yet.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageKolakoskiGroups-E<gt>new (length =E<gt> $integer)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Kolakoski>

=cut

# Local variables:
# compile-command: "math-image --values=KolakoskiGroups"
# End:
