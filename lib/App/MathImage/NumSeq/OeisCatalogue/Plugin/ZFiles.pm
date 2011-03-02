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

package App::MathImage::NumSeq::OeisCatalogue::Plugin::ZFiles;
use 5.004;
use strict;
use File::Spec;
use App::MathImage::NumSeq::Sequence::OEIS::File;

use vars '@ISA';
use App::MathImage::NumSeq::OeisCatalogue::Base;
@ISA = ('App::MathImage::NumSeq::OeisCatalogue::Base');

use vars '$VERSION';
$VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

sub _make_info {
  my ($num) = @_;
  return { num => $num,
           class => 'App::MathImage::NumSeq::Sequence::OEIS::File',
           parameters_hashref => { oeis_number => $num } };
}

sub num_to_info {
  my ($class, $num) = @_;
  ### Catalogue-ZFiles num_to_info(): @_

  my $dir = App::MathImage::NumSeq::Sequence::OEIS::File::oeis_dir();
  foreach my $basename
    (App::MathImage::NumSeq::Sequence::OEIS::File::num_to_html($num),
     App::MathImage::NumSeq::Sequence::OEIS::File::num_to_html($num,'.html'),
     App::MathImage::NumSeq::Sequence::OEIS::File::num_to_bfile($num),
     App::MathImage::NumSeq::Sequence::OEIS::File::num_to_bfile($num,'a')) {
    my $filename = File::Spec->catfile ($dir, $basename);
    if (-e $filename) {
      return _make_info($num);
    }
  }
  return undef;
}

sub info_arrayref {
  my ($class) = @_;
  my $dir = App::MathImage::NumSeq::Sequence::OEIS::File::oeis_dir();
  ### $dir
  my @ret;
  my %seen;
  if (! opendir DIR, $dir) {
    ### cannot opendir: $!
    return [];
  }
  while (defined (my $basename = readdir DIR)) {
    ### $basename
    if ($basename =~ /^A([0-9]{6,})\.html?$/i
        || $basename =~ /^[ab]([0-9]{6,})\.txt?$/i) {
      my $num = $1;
      $num =~ s/^0+//;
      unless ($seen{$num}++) {
        push @ret, _make_info($num);
      }
    }
  }
  closedir DIR or die "Error closing $dir: $!";
  return \@ret;
}


1;
__END__

