# Copyright 2010, 2011 Kevin Ryde

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


# characteristic('monotonic')      strictly non-decreasing
# characteristic('monotonic_from_i')   beyond a given value or i


# ->add ->sub   of sequence or constant
# ->mul
# ->mod($k)    of constant
# overloads
# ->shift
# ->inverse  some with known ways to calculate
# ->is_subset_of
#
# ->value_to_i_floor
# ->pred undef if unknown ?


# lo,hi   i or value
# lo_value,hi_value

# Sequence::Array from arrayref
# Derived::Interleave




package App::MathImage::NumSeq::Sequence;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';

use vars '$VERSION';
$VERSION = 61;

# uncomment this to run the ### lines
#use Smart::Comments;

sub name {
  my ($class_or_self) = @_;
  my $name = ref($class_or_self) || $class_or_self;
  $name =~ s/^App::MathImage::NumSeq::Sequence:://;
  return $name;
}

use constant description => undef;
use constant parameter_list => ();
use constant oeis_anum => undef;
use constant i_start => 0;
sub values_min {
  my ($self) = @_;
  return $self->{'values_min'};
}
sub values_max {
  my ($self) = @_;
  return $self->{'values_max'};
}
sub characteristic {
  my $self = shift;
  my $type = shift;
  if (my $href = $self->{'characteristic'}) {
    if (exists $href->{$type}) {
      return $href->{$type};
    }
  }
  if (my $subr = $self->can("characteristic_${type}")) {
    return $self->$subr (@_);
  }
  return undef;
}
use constant finish => undef;

my %parameter_hash;
sub parameter_hash {
  my ($class_or_self) = @_;
  my $class = (ref $class_or_self || $class_or_self);
  return ($parameter_hash{$class}
          ||= { map {($_->{'name'} => $_)} $class_or_self->parameter_list });
}
sub parameter_default {
  my ($class_or_self, $name) = @_;
  ### NumSeq parameter_default: @_
  ### info: $class_or_self->parameter_hash->{$name}
  my $info;
  return (($info = $class_or_self->parameter_hash->{$name})
          && $info->{'default'});
}

use constant parameter_common_pairs =>
  { name    => 'pairs',
    display => __('Pairs'),
    type    => 'enum',
    default => 'first',
    choices => ['first','second','both'],
    choices_display => [__('First'),__('Second'),__('Both')],
    description => __('Which of a pair of values to show.'),
  };

sub new {
  my ($class, %self) = @_;
  ### Sequence new(): $class
  $self{'lo'} ||= 0;
  my $self = bless \%self, $class;

  foreach my $pinfo ($self->parameter_list) {
    my $pname = $pinfo->{'name'};
    if (! defined $self->{$pname}) {
      ### default: $pname
      $self->{$pname} = $pinfo->{'default'};
    }
  }
  $self->rewind;
  return $self;
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::Sequence -- base class for number sequences

=head1 SYNOPSIS

 # only a base class, use one of the actual classes such as

 use App::MathImage::NumSeq::Sequence::Squares;
 my $seq = App::MathImage::NumSeq::Sequence::Squares->new;
 my ($i, $square) = $seq->next;

=head1 DESCRIPTION

This is a base class for number sequences.

=head1 FUNCTIONS

The following is a 

=over 4

=item C<$seq = App::MathImage::NumSeq::Sequence::Foo-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<($i, $value) = $seq-E<gt>next()>

Return the next index and value in the sequence.

=item C<$seq-E<gt>rewind()>

Return the sequence to its starting point.

=item C<$str = $seq-E<gt>description()>

A human-readable description of the sequence.

=item C<$value = $seq-E<gt>values_min()>

=item C<$value = $seq-E<gt>values_max()>

Return the minimum or maximum value taken by values in the sequence, or
C<undef> if unknown.  Currently if the maximum is infinity then the return
is C<undef> too, but perhaps it should be a floating point infinity, if
there is one.

=item C<$ret = $seq-E<gt>characteristic($type)>

Return true if the sequence is of the given C<$type> (a string).  This is
intended as a loose set of types or properties a sequence might have.  The
following types exist currently,

    count   sequence is a count of something
    pn1     sequence is values +1, -1, 0
    digits  sequence is digits in a given radix

=item C<@infos = $seq-E<gt>parameter_list()>

=back

=head2 Optional Methods

The following methods are only implemented for some sequences.

=over

=item C<$value = $seq-E<gt>ith($i)>

Return the C<$i>'th value in the sequence.  Only some sequence classes
implement this method.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence.  For example for the
squares this would return true if C<$value> is a perfect square or false if
not.

=back

=head1 SEE ALSO

L<Math::Sequence> and L<Math::Series>, symbolic recursive definitions like
Fibonacci

L<math-image>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut




# =item C<$i = $seq-E<gt>i_start()>
# 
# Return the first index C<$i> in the sequence.  This is the position
# C<rewind> returns to.

