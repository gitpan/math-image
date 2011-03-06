# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::Sequence::OEIS;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 47;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('OEIS');
use constant description => __('OEIS sequence, by its A-number.  There\'s code for some sequences, others look in ~/OEIS directory for a b123456.txt download (or A123456.html for just the first few values).');
sub parameter_list {
  require App::MathImage::NumSeq::OeisCatalogue;
  return  ({
            name    => 'oeis_number',
            display => __('A-number'),
            width   => 8,
            type         => 'integer',
            type_special => 'oeis',
            minimum => App::MathImage::NumSeq::OeisCatalogue->num_first,
            maximum => App::MathImage::NumSeq::OeisCatalogue->num_last,
            default => 290, # Squares
           });
}
### parameter_list: parameter_list()
sub oeis {
  my ($class_or_self) = @_;
  if (ref $class_or_self) {
    return $class_or_self->{'oeis_number'};
  }
  return undef;
}

sub new {
  my ($class, %options) = @_;
  ### NumSeq-OEIS: @_

  require App::MathImage::NumSeq::OeisCatalogue;
  my $oeis_number = $options{'oeis_number'};
  if (defined $oeis_number) {
    $oeis_number =~ s/^A0*//;
  } else {
    $oeis_number = (parameter_list)[0]->{'default'};
  }
  ### $oeis_number

  my $info = App::MathImage::NumSeq::OeisCatalogue->num_to_info($oeis_number)
    || croak 'Unknown OEIS sequence ',$oeis_number;
  ### $info

  my $numseq_class = $info->{'class'};
  my $parameters_href = $info->{'parameters_href'};
  require Module::Load;
  Module::Load::load($numseq_class);
  return $numseq_class->new (%options, %{$info->{'parameters_hashref'}});
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::Sequence::OEIS -- sequence of integers by OEIS number

=head1 SYNOPSIS

 use App::MathImage;
 my $seq = App::MathImage::NumSeq::Sequence::OEIS->new (oeis_number => 32);
 my ($i, $value) = $seq->next;
 $value = $seq->ith(6);

=head1 DESCRIPTION

This module creates a NumSeq for a given OEIS sequence number.  If there's a
NumSeq module implementing the sequence then that's used, otherwise
downloaded OEIS files are read.

OEIS files are sought in an F<OEIS> directory under the user's home
directory.  It can have a B-file or A-file C<b000032.txt> or C<a000032.txt>,
and/or the "internal" format info page F<A000032.internal>.

    ~/OEIS/b000032.txt
    ~/OEIS/a000032.txt
    ~/OEIS/A000032.internal

    downloaded from:
    http://oeis.org/A000032/b000032.txt
    http://oeis.org/A000032/a000032.txt
    http://oeis.org/A000032/internal

There's only a few F<a.txt> files but when available they have lots of
values.  Not every sequence has a F<b.txt> file and in that case the 30 or
40 sample values from the "internal" page are used.  For many sequences this
will be no more than a taste, but for fast growing sequences it may be
enough.

=head1 SEE ALSO

L<App::MathImage::NumSeq>

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
